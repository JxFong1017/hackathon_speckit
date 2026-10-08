#!/usr/bin/env bash
# Project-context extension: run hook-time triage for target codebase repo(s).
#
# Usage: run-project-context-triage-hook.sh <event_name> [--target PATH] [--json]
#   e.g.: run-project-context-triage-hook.sh before_specify --json
#         run-project-context-triage-hook.sh before_plan --target /path/to/sidekicker-ui

set -euo pipefail

EVENT_NAME="${1:-}"
if [[ -z "$EVENT_NAME" ]]; then
    echo "Usage: $0 <event_name> [--target PATH] [--json]" >&2
    exit 1
fi
shift

TARGET_OVERRIDE=""
JSON_MODE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --target)
            TARGET_OVERRIDE="${2:-}"
            shift 2
            ;;
        --json)
            JSON_MODE=true
            shift
            ;;
        *)
            echo "ERROR: Unknown option '$1'" >&2
            exit 2
            ;;
    esac
done

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

_find_speckit_root() {
    local dir="$1"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.specify/extensions" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

SPECKIT_ROOT="$(_find_speckit_root "$SCRIPT_DIR")" || SPECKIT_ROOT="$(pwd)"
cd "$SPECKIT_ROOT"

CONFIG_FILE="$SPECKIT_ROOT/.specify/extensions/project-context/project-context-config.yml"
_enabled=false
_triage_all=true
_targets=()

_parse_bool() {
    local val
    val="$(echo "$1" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')"
    [[ "$val" == "true" ]]
}

_parse_triage_hooks() {
    local _in_section=false
    local _in_event=false
    local _default_enabled=false

    [[ -f "$CONFIG_FILE" ]] || return 0

    while IFS= read -r _line; do
        if echo "$_line" | grep -q '^triage_hooks:'; then
            _in_section=true
            _in_event=false
            continue
        fi

        if $_in_section && echo "$_line" | grep -Eq '^[a-z]'; then
            break
        fi

        if $_in_section; then
            if echo "$_line" | grep -Eq '^[[:space:]]+default:[[:space:]]'; then
                _val=$(echo "$_line" | sed 's/^[^:]*:[[:space:]]*//')
                _parse_bool "$_val" && _default_enabled=true
            fi

            if echo "$_line" | grep -Eq "^[[:space:]]+${EVENT_NAME}:"; then
                _in_event=true
                continue
            fi

            if $_in_event; then
                if echo "$_line" | grep -Eq '^[[:space:]]{2}[a-z]' && ! echo "$_line" | grep -Eq '^[[:space:]]{4}'; then
                    _in_event=false
                    continue
                fi
                if echo "$_line" | grep -Eq '[[:space:]]+enabled:'; then
                    _val=$(echo "$_line" | sed 's/^[^:]*:[[:space:]]*//')
                    if _parse_bool "$_val"; then
                        _enabled=true
                    else
                        _enabled=false
                    fi
                fi
            fi
        fi
    done < "$CONFIG_FILE"

    if [[ "$_enabled" == "false" ]] && $_default_enabled; then
        if ! grep -q "^[[:space:]]*${EVENT_NAME}:" "$CONFIG_FILE" 2>/dev/null; then
            _enabled=true
        fi
    fi
}

_parse_targets() {
    local _in_targets=false
    [[ -f "$CONFIG_FILE" ]] || return 0

    while IFS= read -r _line; do
        if echo "$_line" | grep -q '^targets:'; then
            _in_targets=true
            continue
        fi
        if $_in_targets; then
            if echo "$_line" | grep -Eq '^[a-z]'; then
                break
            fi
            if echo "$_line" | grep -Eq '^[[:space:]]+-[[:space:]]'; then
                local entry
                entry=$(echo "$_line" | sed -E 's/^[[:space:]]+-[[:space:]]*//' | sed -E 's/^["'\'']|["'\'']$//g')
                [[ -n "$entry" ]] && _targets+=("$entry")
            fi
        fi
    done < "$CONFIG_FILE"
}

_parse_triage_all() {
    [[ -f "$CONFIG_FILE" ]] || return 0
    local line
    line=$(grep -E '^triage_all_targets:' "$CONFIG_FILE" 2>/dev/null | head -1 || true)
    if [[ -n "$line" ]]; then
        local val
        val=$(echo "$line" | sed 's/^[^:]*:[[:space:]]*//')
        if ! _parse_bool "$val"; then
            _triage_all=false
        fi
    fi
}

_resolve_target_path() {
    local spec="$1"
    local resolved=""

    if [[ -z "$spec" ]]; then
        return 1
    fi

    if [[ "$spec" == /* ]] && [[ -d "$spec" ]]; then
        echo "$(CDPATH="" cd "$spec" && pwd)"
        return 0
    fi

    if [[ -d "$SPECKIT_ROOT/$spec" ]]; then
        echo "$(CDPATH="" cd "$SPECKIT_ROOT/$spec" && pwd)"
        return 0
    fi

    local parent base
    parent="$(dirname "$SPECKIT_ROOT")"
    base="$(basename "$spec")"
    if [[ -d "$parent/$base" ]]; then
        echo "$(CDPATH="" cd "$parent/$base" && pwd)"
        return 0
    fi

    if [[ -d "$parent/$spec" ]]; then
        echo "$(CDPATH="" cd "$parent/$spec" && pwd)"
        return 0
    fi

    return 1
}

_find_check_script() {
    local candidate="$SPECKIT_ROOT/.specify/scripts/bash/triage-project-context.sh"
    if [[ -f "$candidate" ]]; then
        echo "$candidate"
        return 0
    fi
    return 1
}

_json_get_action() {
    local json="$1"
    if command -v jq >/dev/null 2>&1; then
        echo "$json" | jq -r '.ACTION // "full_regen"'
    else
        echo "$json" | sed -n 's/.*"ACTION":"\([^"]*\)".*/\1/p' | head -1
    fi
}

_parse_triage_hooks
_parse_targets
_parse_triage_all

if [[ "$_enabled" != "true" ]]; then
    if $JSON_MODE; then
        printf '{"EVENT":"%s","SPECKIT_PROJECT_ROOT":"%s","SKIPPED":true,"REASON":"triage disabled for event in config"}\n' \
            "$EVENT_NAME" "$SPECKIT_ROOT"
    else
        echo "[specify] project-context triage skipped for $EVENT_NAME (disabled in config)" >&2
    fi
    exit 0
fi

resolved_targets=()

if [[ -n "$TARGET_OVERRIDE" ]]; then
    if resolved="$(_resolve_target_path "$TARGET_OVERRIDE")"; then
        resolved_targets+=("$resolved")
    else
        echo "[specify] ERROR: Could not resolve target path: $TARGET_OVERRIDE" >&2
        exit 1
    fi
elif [[ -n "${TARGET_REPO_ROOT:-}" ]] && resolved="$(_resolve_target_path "$TARGET_REPO_ROOT")"; then
    resolved_targets+=("$resolved")
elif [[ ${#_targets[@]} -gt 0 ]]; then
    for t in "${_targets[@]}"; do
        if resolved="$(_resolve_target_path "$t")"; then
            resolved_targets+=("$resolved")
            if [[ "$_triage_all" != "true" ]]; then
                break
            fi
        fi
    done
else
    # Single-repo layout: Spec Kit project is the codebase
    resolved_targets+=("$SPECKIT_ROOT")
fi

if [[ ${#resolved_targets[@]} -eq 0 ]]; then
    if $JSON_MODE; then
        printf '{"EVENT":"%s","SPECKIT_PROJECT_ROOT":"%s","SKIPPED":true,"REASON":"no resolvable target; configure targets in project-context-config.yml or pass --target"}\n' \
            "$EVENT_NAME" "$SPECKIT_ROOT"
    else
        echo "[specify] project-context triage skipped: no target codebase resolved." >&2
        echo "[specify] Set targets in .specify/extensions/project-context/project-context-config.yml or pass --target PATH." >&2
    fi
    exit 0
fi

CHECK_SCRIPT="$(_find_check_script)" || {
    echo "[specify] ERROR: triage-project-context.sh not found under $SPECKIT_ROOT/.specify/scripts/bash/" >&2
    exit 1
}

overall_action="quality_pass"
targets_json="["
first_target=true

for target_root in "${resolved_targets[@]}"; do
    label="$(basename "$target_root")"
    triage_json=""
    if ! triage_json="$(cd "$target_root" && bash "$CHECK_SCRIPT" --json 2>/dev/null)"; then
        triage_json='{"REPO_ROOT":"'"$target_root"'","ACTION":"full_regen","ERROR":"triage script failed"}'
    fi

    action="$(_json_get_action "$triage_json")"
    [[ -z "$action" ]] && action="full_regen"

    if [[ "$action" == "full_regen" ]]; then
        overall_action="full_regen"
    fi

    if ! $JSON_MODE; then
        echo "[specify] project-context triage ($EVENT_NAME): $label → $action" >&2
        if [[ "$action" == "full_regen" ]]; then
            echo "[specify] Suggest: /speckit-project-context for $label (or TARGET_REPO_ROOT=$target_root)" >&2
        fi
    fi

    if $JSON_MODE && command -v jq >/dev/null 2>&1; then
        triage_compact=""
        if triage_compact="$(printf '%s' "$triage_json" | jq -c . 2>/dev/null)"; then
            :
        else
            triage_compact="{}"
        fi
        if $first_target; then first_target=false; else targets_json+=","; fi
        targets_json+=$(jq -nc \
            --arg label "$label" \
            --arg target_root "$target_root" \
            --arg action "$action" \
            --argjson triage "$triage_compact" \
            '{label: $label, TARGET_REPO_ROOT: $target_root, ACTION: $action, triage: $triage}')
    fi
done

if $JSON_MODE; then
    if command -v jq >/dev/null 2>&1; then
        targets_json+="]"
        jq -n \
            --arg event "$EVENT_NAME" \
            --arg speckit_root "$SPECKIT_ROOT" \
            --arg overall_action "$overall_action" \
            --argjson targets "$targets_json" \
            '{EVENT: $event, SPECKIT_PROJECT_ROOT: $speckit_root, ACTION: $overall_action, TARGETS: $targets}'
    else
        printf '{"EVENT":"%s","SPECKIT_PROJECT_ROOT":"%s","ACTION":"%s","TARGET_COUNT":%d}\n' \
            "$EVENT_NAME" "$SPECKIT_ROOT" "$overall_action" "${#resolved_targets[@]}"
    fi
else
    if [[ "$overall_action" == "quality_pass" ]]; then
        echo "[specify] project-context is current for ${#resolved_targets[@]} target(s); continuing $EVENT_NAME." >&2
    fi
fi

exit 0
