#!/usr/bin/env bash
# Sync Spec Kit toolkit files from SPECKIT_UPDATE_REPO.
# Does NOT use the current project's git remote origin.
# This template has no default upstream. Set SPECKIT_UPDATE_REPO to this
# template's own remote before syncing. Do not point it at another team's Spec Kit.
#
# Usage: ./speckit-update.sh [--dry-run] [--json]
#
# Environment:
#   SPECKIT_UPDATE_REPO  Required git URL (SSH tried first, then HTTPS)
#   SPECKIT_UPDATE_REF   Override branch/ref (default: remote HEAD symref, else main)

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

DRY_RUN=false
JSON_MODE=false

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --json) JSON_MODE=true ;;
        -h|--help)
            sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "Unknown option: $arg (use --dry-run, --json, --help)" >&2
            exit 2
            ;;
    esac
done

REPO_ROOT="$(get_repo_root)" || {
    echo "[speckit-update] ERROR: Not a Spec Kit project (.specify/ not found)." >&2
    exit 1
}

SOURCE_REPO=""
SOURCE_TRANSPORT=""
CANDIDATE_REPOS=()

_to_ssh_url() {
    local url="$1"
    case "$url" in
        git@*)
            echo "$url"
            ;;
        https://github.com/* | http://github.com/*)
            local path="${url#https://github.com/}"
            path="${path#http://github.com/}"
            path="${path%.git}"
            echo "git@github.com:${path}.git"
            ;;
        *)
            return 1
            ;;
    esac
}

_to_https_url() {
    local url="$1"
    case "$url" in
        https://* | http://*)
            local normalized="$url"
            [[ "$normalized" == *.git ]] || normalized="${normalized}.git"
            echo "$normalized"
            ;;
        git@github.com:*)
            local path="${url#git@github.com:}"
            path="${path%.git}"
            echo "https://github.com/${path}.git"
            ;;
        *)
            return 1
            ;;
    esac
}

_build_repo_candidates() {
    if [[ -z "${SPECKIT_UPDATE_REPO:-}" ]]; then
        echo "[speckit-update] ERROR: SPECKIT_UPDATE_REPO is not set." >&2
        echo "[speckit-update] This template does not sync from another Spec Kit repo." >&2
        echo "[speckit-update] Set SPECKIT_UPDATE_REPO to this template's git URL when a canonical remote exists." >&2
        exit 1
    fi

    local base_url="$SPECKIT_UPDATE_REPO"
    local ssh_url="" https_url=""

    if ssh_url="$(_to_ssh_url "$base_url" 2>/dev/null)"; then :; else ssh_url=""; fi
    if https_url="$(_to_https_url "$base_url" 2>/dev/null)"; then
        :
    else
        https_url="$base_url"
    fi

    CANDIDATE_REPOS=()
    if [[ -n "$ssh_url" ]]; then
        CANDIDATE_REPOS+=("$ssh_url")
    fi
    if [[ -n "$https_url" && "$https_url" != "$ssh_url" ]]; then
        CANDIDATE_REPOS+=("$https_url")
    fi
}

# Paths under REPO_ROOT that are never overwritten from upstream.
readonly -a PRESERVE_REL=(
    ".specify/memory/constitution.md"
    ".specify/feature.json"
)

# Directory roots to sync (relative to REPO_ROOT).
readonly -a SYNC_ROOTS=(
    ".specify"
    ".cursor/skills"
    ".cursor/rules"
)

_should_exclude() {
    local rel="$1"
    case "$rel" in
        README.md | catalog-info.yaml) return 0 ;;
        .github | .github/*) return 0 ;;
        docs | docs/*) return 0 ;;
    esac
    return 1
}

_should_preserve() {
    local rel="$1"
    if _should_exclude "$rel"; then
        return 0
    fi
    local p
    for p in "${PRESERVE_REL[@]}"; do
        if [[ "$rel" == "$p" ]]; then
            return 0
        fi
    done
    case "$rel" in
        .specify/memory | .specify/memory/*) return 0 ;;
    esac
    return 1
}

_is_under_sync_root() {
    local rel="$1"
    local root
    for root in "${SYNC_ROOTS[@]}"; do
        if [[ "$rel" == "$root" ]] || [[ "$rel" == "$root"/* ]]; then
            return 0
        fi
    done
    return 1
}

SOURCE_REF="${SPECKIT_UPDATE_REF:-}"

_resolve_source_access() {
    local url err_file detail
    _build_repo_candidates

    if ((${#CANDIDATE_REPOS[@]} == 0)); then
        echo "[speckit-update] ERROR: No source repository URLs to try." >&2
        exit 1
    fi

    for url in "${CANDIDATE_REPOS[@]}"; do
        err_file="$(mktemp)"
        if git ls-remote --exit-code "$url" HEAD >"$err_file" 2>&1; then
            SOURCE_REPO="$url"
            case "$url" in
                git@*) SOURCE_TRANSPORT="ssh" ;;
                *) SOURCE_TRANSPORT="https" ;;
            esac
            rm -f "$err_file"
            return 0
        fi
        detail="$(tr '\n' ' ' <"$err_file")"
        rm -f "$err_file"
        echo "[speckit-update] Failed ($url): ${detail:-unknown error}" >&2
    done

    echo "[speckit-update] ERROR: Cannot access source repository (tried SSH, then HTTPS)." >&2
    printf '  %s\n' "${CANDIDATE_REPOS[@]}" >&2
    echo "[speckit-update]   Ensure you have network access and credentials for this repository." >&2
    exit 1
}

_resolve_default_ref() {
    if [[ -n "$SOURCE_REF" ]]; then
        echo "$SOURCE_REF"
        return 0
    fi
    local symref
    symref="$(git ls-remote --symref "$SOURCE_REPO" HEAD 2>/dev/null | awk '/^ref:/ {print $2}' | sed 's|refs/heads/||')"
    if [[ -n "$symref" ]]; then
        echo "$symref"
        return 0
    fi
    echo "main"
}

TMPDIR=""
cleanup() {
    if [[ -n "$TMPDIR" && -d "$TMPDIR" ]]; then
        rm -rf "$TMPDIR"
    fi
}
trap cleanup EXIT

UPDATED=()
ADDED=()
UNCHANGED=()
SKIPPED=()

readonly SPECIFY_RULES_REL=".cursor/rules/specify-rules.md"

# When syncing specify-rules.md, keep the project-specific active-feature line from the
# local file instead of overwriting it with the upstream default.
_merge_specify_rules_preserve_project() {
    local local_file="$1"
    local upstream_file="$2"
    local out_file="$3"

    if [[ ! -f "$local_file" ]]; then
        cp "$upstream_file" "$out_file"
        return 0
    fi

    local active_line="" line
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^\*\*Active\ feature\*\*: ]]; then
            active_line="$line"
        fi
    done <"$local_file"

    : >"$out_file"
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^\*\*Active\ feature\*\*: ]] && [[ -n "$active_line" ]]; then
            printf '%s\n' "$active_line" >>"$out_file"
        else
            printf '%s\n' "$line" >>"$out_file"
        fi
    done <"$upstream_file"
}

_effective_upstream_file() {
    local rel="$1"
    local upstream_file="$2"
    local local_file="$3"
    local merged_tmp=""

    if [[ "$rel" == "$SPECIFY_RULES_REL" && -f "$local_file" ]]; then
        merged_tmp="$(mktemp)"
        _merge_specify_rules_preserve_project "$local_file" "$upstream_file" "$merged_tmp"
        printf '%s' "$merged_tmp"
        return 0
    fi

    printf '%s' "$upstream_file"
}

_compare_and_apply() {
    local rel="$1"
    local upstream_file="$2"
    local local_file="$REPO_ROOT/$rel"
    local effective_upstream="" merged_tmp=""

    if _should_preserve "$rel"; then
        SKIPPED+=("$rel (preserved)")
        return 0
    fi

    if [[ ! -f "$upstream_file" ]]; then
        return 0
    fi

    effective_upstream="$(_effective_upstream_file "$rel" "$upstream_file" "$local_file")"
    if [[ "$effective_upstream" != "$upstream_file" ]]; then
        merged_tmp="$effective_upstream"
    fi

    if [[ -f "$local_file" ]]; then
        if cmp -s "$local_file" "$effective_upstream" 2>/dev/null; then
            UNCHANGED+=("$rel")
            if [[ -n "$merged_tmp" ]]; then
                rm -f "$merged_tmp"
            fi
            return 0
        fi
        if $DRY_RUN; then
            UPDATED+=("$rel")
        else
            mkdir -p "$(dirname "$local_file")"
            cp "$effective_upstream" "$local_file"
            UPDATED+=("$rel")
        fi
    else
        if $DRY_RUN; then
            ADDED+=("$rel")
        else
            mkdir -p "$(dirname "$local_file")"
            cp "$effective_upstream" "$local_file"
            ADDED+=("$rel")
        fi
    fi

    if [[ -n "$merged_tmp" ]]; then
        rm -f "$merged_tmp"
    fi
}

_json_escape() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

_emit_json() {
    local dry="false"
    if $DRY_RUN; then
        dry="true"
    fi
    printf '{'
    printf '"source_repo":"%s",' "$(_json_escape "$SOURCE_REPO")"
    printf '"source_transport":"%s",' "$(_json_escape "$SOURCE_TRANSPORT")"
    printf '"source_ref":"%s",' "$(_json_escape "$SOURCE_REF")"
    printf '"dry_run":%s,' "$dry"
    printf '"updated":['
    local i
    for i in "${!UPDATED[@]}"; do
        if ((i > 0)); then
            printf ','
        fi
        printf '"%s"' "$(_json_escape "${UPDATED[$i]}")"
    done
    printf '],"added":['
    for i in "${!ADDED[@]}"; do
        if ((i > 0)); then
            printf ','
        fi
        printf '"%s"' "$(_json_escape "${ADDED[$i]}")"
    done
    printf '],"unchanged_count":%d,' "${#UNCHANGED[@]}"
    printf '"skipped":['
    for i in "${!SKIPPED[@]}"; do
        if ((i > 0)); then
            printf ','
        fi
        printf '"%s"' "$(_json_escape "${SKIPPED[$i]}")"
    done
    printf ']}\n'
}

_resolve_source_access
SOURCE_REF="$(_resolve_default_ref)"

TMPDIR="$(mktemp -d)"
UPSTREAM_ROOT="$TMPDIR/upstream"
if ! git clone --quiet --depth 1 --branch "$SOURCE_REF" "$SOURCE_REPO" "$UPSTREAM_ROOT" 2>"$TMPDIR/clone.err"; then
    echo "[speckit-update] ERROR: Failed to clone $SOURCE_REPO (ref: $SOURCE_REF)." >&2
    if [[ -s "$TMPDIR/clone.err" ]]; then
        cat "$TMPDIR/clone.err" >&2
    fi
    exit 1
fi

for root in "${SYNC_ROOTS[@]}"; do
    upstream_dir="$UPSTREAM_ROOT/$root"
    [[ -d "$upstream_dir" ]] || continue
    while IFS= read -r -d '' upstream_file || [[ -n "$upstream_file" ]]; do
        rel="${upstream_file#"$UPSTREAM_ROOT"/}"
        if ! _is_under_sync_root "$rel" || _should_exclude "$rel"; then
            continue
        fi
        _compare_and_apply "$rel" "$upstream_file"
    done < <(find "$upstream_dir" -type f -print0)
done

if $JSON_MODE; then
    _emit_json
    exit 0
fi

echo "[speckit-update] Source: $SOURCE_REPO @ $SOURCE_REF ($SOURCE_TRANSPORT)"
echo "[speckit-update] Target: $REPO_ROOT"
if $DRY_RUN; then
    echo "[speckit-update] Mode: dry-run (no files written)"
fi

if ((${#UPDATED[@]})); then
    echo "[speckit-update] Updated (${#UPDATED[@]}):"
    printf '  %s\n' "${UPDATED[@]}"
fi
if ((${#ADDED[@]})); then
    echo "[speckit-update] Added (${#ADDED[@]}):"
    printf '  %s\n' "${ADDED[@]}"
fi
if ((${#SKIPPED[@]})); then
    echo "[speckit-update] Preserved (${#SKIPPED[@]}):"
    printf '  %s\n' "${SKIPPED[@]}"
fi
echo "[speckit-update] Unchanged: ${#UNCHANGED[@]} file(s)"

total_changes=$((${#UPDATED[@]} + ${#ADDED[@]}))
if $DRY_RUN && ((total_changes > 0)); then
    echo "[speckit-update] Re-run without --dry-run to apply changes."
elif ((total_changes == 0)); then
    echo "[speckit-update] Toolkit is already up to date."
fi

exit 0
