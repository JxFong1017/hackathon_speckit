#!/usr/bin/env bash
# Triage project-context staleness using structure fingerprints (State → Mechanics).
#
# Usage: ./triage-project-context.sh [OPTIONS]
#
# OPTIONS:
#   --json              Output triage result as JSON
#   --force             Recommend full_regen regardless of fingerprint
#   --write-state       Write project-context.state.json from current repo signals
#   --output PATH       Override output markdown path (default: resolved from repo)
#   --scan-scope SCOPE  Scan scope label stored in state (default: "whole repo")
#   --help, -h          Show help
#
# Exit 0 always on successful triage (use ACTION in JSON for branching).

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

JSON_MODE=false
FORCE=false
WRITE_STATE=false
OUTPUT_FILE=""
SCAN_SCOPE="whole repo"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --json) JSON_MODE=true; shift ;;
        --force) FORCE=true; shift ;;
        --write-state) WRITE_STATE=true; shift ;;
        --output)
            OUTPUT_FILE="${2:-}"
            shift 2
            ;;
        --scan-scope)
            SCAN_SCOPE="${2:-}"
            shift 2
            ;;
        --help|-h)
            sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option '$1'. Use --help for usage." >&2
            exit 2
            ;;
    esac
done

REPO_ROOT="$(get_repo_root)" || {
    echo "[triage-project-context] ERROR: Could not resolve repository root." >&2
    exit 1
}

_resolve_output_file() {
    if [[ -n "$OUTPUT_FILE" ]]; then
        if [[ "$OUTPUT_FILE" != /* ]]; then
            OUTPUT_FILE="$REPO_ROOT/$OUTPUT_FILE"
        fi
        printf '%s' "$OUTPUT_FILE"
        return 0
    fi
    if [[ -d "$REPO_ROOT/.specify" ]]; then
        printf '%s' "$REPO_ROOT/.specify/memory/project-context.md"
    elif [[ -d "$REPO_ROOT/docs" ]]; then
        printf '%s' "$REPO_ROOT/docs/project-context.md"
    else
        printf '%s' "$REPO_ROOT/project-context.md"
    fi
}

OUTPUT_FILE="$(_resolve_output_file)"
STATE_FILE="$(dirname "$OUTPUT_FILE")/project-context.state.json"

_sha256_file() {
    local f="$1"
    if [[ ! -f "$f" ]]; then
        return 0
    fi
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$f" | awk '{print $1}'
    elif command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$f" | awk '{print $1}'
    else
        cksum "$f" | awk '{print $1}'
    fi
}

_sha256_string() {
    local s="$1"
    if command -v shasum >/dev/null 2>&1; then
        printf '%s' "$s" | shasum -a 256 | awk '{print $1}'
    elif command -v sha256sum >/dev/null 2>&1; then
        printf '%s' "$s" | sha256sum | awk '{print $1}'
    else
        printf '%s' "$s" | cksum | awk '{print $1}'
    fi
}

_collect_top_level_dirs() {
    local root="$1"
    find "$root" -mindepth 1 -maxdepth 1 -type d \
        ! -name '.git' ! -name 'node_modules' ! -name '.turbo' ! -name 'dist' ! -name 'build' \
        2>/dev/null | sed "s|^$root/||" | LC_ALL=C sort
}

_collect_child_dirs() {
    local parent="$1"
    [[ -d "$parent" ]] || return 0
    find "$parent" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sed "s|^$parent/||" | LC_ALL=C sort
}

_collect_workspace_packages() {
    local ws="$REPO_ROOT/pnpm-workspace.yaml"
    if [[ -f "$ws" ]] && command -v python3 >/dev/null 2>&1; then
        if python3 -c "
import sys
try:
    import yaml
except ImportError:
    sys.exit(1)
with open(sys.argv[1]) as f:
    data = yaml.safe_load(f) or {}
pkgs = data.get('packages') or []
for p in sorted(pkgs):
    print(p)
" "$ws" 2>/dev/null; then
            return 0
        fi
    fi
    if [[ -d "$REPO_ROOT/packages" ]]; then
        _collect_child_dirs "$REPO_ROOT/packages" | sed 's|^|packages/|'
    fi
    if [[ -d "$REPO_ROOT/apps" ]]; then
        _collect_child_dirs "$REPO_ROOT/apps" | sed 's|^|apps/|'
    fi
}

_manifest_files=(
    "package.json"
    "pnpm-workspace.yaml"
    "pyproject.toml"
    "go.mod"
    "Cargo.toml"
    "pom.xml"
    "catalog-info.yaml"
    "sku.config.ts"
    "deploy.config.js"
    "docker-compose.yml"
    "Dockerfile"
)

_compute_manifest_digest() {
    local parts=""
    local rel
    for rel in "${_manifest_files[@]}"; do
        local f="$REPO_ROOT/$rel"
        if [[ -f "$f" ]]; then
            parts+="${rel}:$(_sha256_file "$f")"$'\n'
        fi
    done
    _sha256_string "$parts"
}

_scan_root_for_fingerprint() {
    if [[ "$SCAN_SCOPE" == subdirectory:* ]]; then
        local sub="${SCAN_SCOPE#subdirectory:}"
        sub="${sub# }"
        if [[ -n "$sub" && -d "$REPO_ROOT/$sub" ]]; then
            printf '%s' "$REPO_ROOT/$sub"
            return 0
        fi
    fi
    printf '%s' "$REPO_ROOT"
}

_compute_fingerprint() {
    local scan_root
    scan_root="$(_scan_root_for_fingerprint)"

    local payload=""
    payload+="scan_scope=$SCAN_SCOPE"$'\n'
    payload+="top_level_dirs="$'\n'
    while IFS= read -r d; do
        [[ -n "$d" ]] && payload+="$d"$'\n'
    done < <(_collect_top_level_dirs "$scan_root")
    payload+="src_modules="$'\n'
    while IFS= read -r d; do
        [[ -n "$d" ]] && payload+="$d"$'\n'
    done < <(_collect_child_dirs "$scan_root/src")
    payload+="workspace_packages="$'\n'
    while IFS= read -r p; do
        [[ -n "$p" ]] && payload+="$p"$'\n'
    done < <(_collect_workspace_packages)
    payload+="manifest_digest=$(_compute_manifest_digest)"$'\n'

    _sha256_string "$payload"
}

_read_stored_fingerprint() {
    [[ -f "$STATE_FILE" ]] || return 0
    local fp=""
    if command -v jq >/dev/null 2>&1; then
        fp=$(jq -r '.structure_fingerprint // empty' "$STATE_FILE" 2>/dev/null || true)
    elif command -v python3 >/dev/null 2>&1; then
        fp=$(python3 -c "
import json, sys
try:
    with open(sys.argv[1]) as f:
        d = json.load(f)
    print(d.get('structure_fingerprint') or '')
except Exception:
    print('')
" "$STATE_FILE" 2>/dev/null || true)
    else
        fp=$(grep -E '"structure_fingerprint"' "$STATE_FILE" 2>/dev/null | head -1 | sed -E 's/.*"structure_fingerprint"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' || true)
    fi
    printf '%s' "$fp"
}

_write_state_file() {
    local fp="$1"
    local generated_at
    generated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u)"

    local git_head=""
    if has_git; then
        git_head=$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || true)
    fi

    local rel_output="${OUTPUT_FILE#"$REPO_ROOT"/}"
    mkdir -p "$(dirname "$STATE_FILE")"

    if has_jq; then
        local top_dirs_json src_mods_json ws_pkgs_json
        top_dirs_json=$( _collect_top_level_dirs "$REPO_ROOT" | jq -R . | jq -s . )
        src_mods_json=$( _collect_child_dirs "$REPO_ROOT/src" | jq -R . | jq -s . )
        ws_pkgs_json=$( _collect_workspace_packages | jq -R . | jq -s . )
        jq -n \
            --arg schema_version "1" \
            --arg generated_at "$generated_at" \
            --arg scan_scope "$SCAN_SCOPE" \
            --arg output_file "$rel_output" \
            --arg structure_fingerprint "$fp" \
            --arg manifest_digest "$(_compute_manifest_digest)" \
            --arg git_head "$git_head" \
            --argjson top_level_dirs "$top_dirs_json" \
            --argjson src_modules "$src_mods_json" \
            --argjson workspace_packages "$ws_pkgs_json" \
            '{
                schema_version: $schema_version,
                generated_at: $generated_at,
                scan_scope: $scan_scope,
                output_file: $output_file,
                structure_fingerprint: $structure_fingerprint,
                signals: {
                    top_level_dirs: $top_level_dirs,
                    src_modules: $src_modules,
                    workspace_packages: $workspace_packages,
                    manifest_digest: $manifest_digest,
                    git_head: (if $git_head == "" then null else $git_head end)
                }
            }' >"$STATE_FILE"
    else
        {
            printf '{'
            printf '"schema_version":"1",'
            printf '"generated_at":"%s",' "$(json_escape "$generated_at")"
            printf '"scan_scope":"%s",' "$(json_escape "$SCAN_SCOPE")"
            printf '"output_file":"%s",' "$(json_escape "$rel_output")"
            printf '"structure_fingerprint":"%s",' "$(json_escape "$fp")"
            printf '"signals":{'
            printf '"manifest_digest":"%s",' "$(json_escape "$(_compute_manifest_digest)")"
            if [[ -n "$git_head" ]]; then
                printf '"git_head":"%s",' "$(json_escape "$git_head")"
            else
                printf '"git_head":null,'
            fi
            printf '"top_level_dirs":[],'
            printf '"src_modules":[],'
            printf '"workspace_packages":[]'
            printf '}'
            printf '}\n'
        } >"$STATE_FILE"
    fi
}

CURRENT_FINGERPRINT="$(_compute_fingerprint)"
STORED_FINGERPRINT="$(_read_stored_fingerprint)"

PROJECT_CONTEXT_EXISTS=false
PROJECT_CONTEXT_STATE_EXISTS=false
if [[ -f "$OUTPUT_FILE" ]]; then PROJECT_CONTEXT_EXISTS=true; fi
if [[ -f "$STATE_FILE" ]]; then PROJECT_CONTEXT_STATE_EXISTS=true; fi

STRUCTURE_STALE=false
STALE_REASONS=()

if $FORCE; then
    STRUCTURE_STALE=true
    STALE_REASONS+=("forced via --force")
elif [[ "$PROJECT_CONTEXT_EXISTS" != "true" ]]; then
    STRUCTURE_STALE=true
    STALE_REASONS+=("project-context.md missing")
elif [[ "$PROJECT_CONTEXT_STATE_EXISTS" != "true" ]]; then
    STRUCTURE_STALE=true
    STALE_REASONS+=("project-context.state.json missing")
elif [[ -z "$STORED_FINGERPRINT" ]]; then
    STRUCTURE_STALE=true
    STALE_REASONS+=("stored structure_fingerprint empty or unreadable")
elif [[ "$CURRENT_FINGERPRINT" != "$STORED_FINGERPRINT" ]]; then
    STRUCTURE_STALE=true
    STALE_REASONS+=("structure fingerprint changed")
fi

ACTION="quality_pass"
if $STRUCTURE_STALE; then
    ACTION="full_regen"
fi

if $WRITE_STATE; then
    _write_state_file "$CURRENT_FINGERPRINT"
    PROJECT_CONTEXT_STATE_EXISTS=true
    STORED_FINGERPRINT="$CURRENT_FINGERPRINT"
    STRUCTURE_STALE=false
    STALE_REASONS=()
    if $PROJECT_CONTEXT_EXISTS; then
        ACTION="quality_pass"
    fi
fi

REL_OUTPUT="${OUTPUT_FILE#"$REPO_ROOT"/}"
REL_STATE="${STATE_FILE#"$REPO_ROOT"/}"

if $JSON_MODE; then
    if has_jq; then
        reasons_json=$(printf '%s\n' "${STALE_REASONS[@]:-}" | sed '/^$/d' | jq -R . | jq -s .)
        jq -n \
            --arg repo_root "$REPO_ROOT" \
            --arg output_file "$REL_OUTPUT" \
            --arg state_file "$REL_STATE" \
            --argjson project_context_exists "$PROJECT_CONTEXT_EXISTS" \
            --argjson project_context_state_exists "$PROJECT_CONTEXT_STATE_EXISTS" \
            --argjson structure_stale "$STRUCTURE_STALE" \
            --argjson stale_reasons "$reasons_json" \
            --arg action "$ACTION" \
            --arg current_fingerprint "$CURRENT_FINGERPRINT" \
            --arg stored_fingerprint "$STORED_FINGERPRINT" \
            --arg scan_scope "$SCAN_SCOPE" \
            '{
                REPO_ROOT: $repo_root,
                OUTPUT_FILE: $output_file,
                STATE_FILE: $state_file,
                SCAN_SCOPE: $scan_scope,
                PROJECT_CONTEXT_EXISTS: $project_context_exists,
                PROJECT_CONTEXT_STATE_EXISTS: $project_context_state_exists,
                STRUCTURE_STALE: $structure_stale,
                STALE_REASONS: $stale_reasons,
                ACTION: $action,
                CURRENT_FINGERPRINT: $current_fingerprint,
                STORED_FINGERPRINT: $stored_fingerprint
            }'
    else
        reasons_json="[]"
        if [[ ${#STALE_REASONS[@]} -gt 0 ]]; then
            reasons_json="["
            local i
            for i in "${!STALE_REASONS[@]}"; do
                [[ $i -gt 0 ]] && reasons_json+=","
                reasons_json+="\"$(json_escape "${STALE_REASONS[$i]}")\""
            done
            reasons_json+="]"
        fi
        printf '{"REPO_ROOT":"%s","OUTPUT_FILE":"%s","STATE_FILE":"%s","SCAN_SCOPE":"%s","PROJECT_CONTEXT_EXISTS":%s,"PROJECT_CONTEXT_STATE_EXISTS":%s,"STRUCTURE_STALE":%s,"STALE_REASONS":%s,"ACTION":"%s","CURRENT_FINGERPRINT":"%s","STORED_FINGERPRINT":"%s"}\n' \
            "$(json_escape "$REPO_ROOT")" \
            "$(json_escape "$REL_OUTPUT")" \
            "$(json_escape "$REL_STATE")" \
            "$(json_escape "$SCAN_SCOPE")" \
            "$PROJECT_CONTEXT_EXISTS" \
            "$PROJECT_CONTEXT_STATE_EXISTS" \
            "$STRUCTURE_STALE" \
            "$reasons_json" \
            "$(json_escape "$ACTION")" \
            "$(json_escape "$CURRENT_FINGERPRINT")" \
            "$(json_escape "$STORED_FINGERPRINT")"
    fi
else
    echo "REPO_ROOT: $REPO_ROOT"
    echo "OUTPUT_FILE: $REL_OUTPUT"
    echo "STATE_FILE: $REL_STATE"
    echo "SCAN_SCOPE: $SCAN_SCOPE"
    echo "PROJECT_CONTEXT_EXISTS: $PROJECT_CONTEXT_EXISTS"
    echo "PROJECT_CONTEXT_STATE_EXISTS: $PROJECT_CONTEXT_STATE_EXISTS"
    echo "STRUCTURE_STALE: $STRUCTURE_STALE"
    echo "ACTION: $ACTION"
    echo "CURRENT_FINGERPRINT: $CURRENT_FINGERPRINT"
    echo "STORED_FINGERPRINT: $STORED_FINGERPRINT"
    if [[ ${#STALE_REASONS[@]} -gt 0 ]]; then
        echo "STALE_REASONS:"
        printf '  - %s\n' "${STALE_REASONS[@]}"
    fi
fi

exit 0
