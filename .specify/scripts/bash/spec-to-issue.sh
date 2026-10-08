#!/usr/bin/env bash
# Extract user stories from user-stories.md (or spec.md fallback) and write a Jira-import CSV.
#
# Column layout and defaults come from .specify/jira-export.json.
#
# Usage: spec-to-issue.sh [OPTIONS]
#
# OPTIONS:
#   --json              Output result metadata as JSON on stdout
#   --output PATH       CSV output path (default: <feature-dir>/user-stories.csv)
#   --spec PATH         Force spec.md (or compatible markdown) as input
#   --user-stories PATH Force user-stories.md (or compatible markdown) as input
#   --jira-export PATH  jira-export.json path (default: <repo>/.specify/jira-export.json)
#   --help, -h          Show help
#
# EXAMPLES:
#   ./spec-to-issue.sh
#   ./spec-to-issue.sh --json --output ./out.csv
#   SPECIFY_FEATURE=001-automated-candidate-sourcing ./spec-to-issue.sh

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

JSON_MODE=false
OUTPUT_PATH=""
SPEC_PATH=""
USER_STORIES_PATH=""
JIRA_EXPORT_PATH=""
SOURCE_PATH=""
FORCE_SPEC=false
FORCE_USER_STORIES=false

CSV_COLUMNS=()
EXPORTED_STORY_COUNT=0

usage() {
    cat <<'EOF'
Usage: spec-to-issue.sh [OPTIONS]

Extract user stories from user-stories.md (or spec.md fallback) and write user-stories.csv
using columns and defaults from .specify/jira-export.json.

Source resolution (unless --spec or --user-stories is set):
  1. <feature-dir>/user-stories.md if it exists
  2. <feature-dir>/spec.md if it exists
  3. ERROR if neither file exists

OPTIONS:
  --json              Output {"OUTPUT_FILE","STORY_COUNT","FEATURE_DIR","SOURCE_FILE","JIRA_EXPORT_CONFIG"} as JSON
  --output PATH       CSV file path (default: <feature-dir>/user-stories.csv)
  --spec PATH         Force input markdown (spec.md or compatible file)
  --user-stories PATH Force input markdown (user-stories.md or compatible file)
  --jira-export PATH  Jira export config (default: <repo>/.specify/jira-export.json)
  --help, -h          Show this message
EOF
}

args=("$@")
i=0
while [[ $i -lt ${#args[@]} ]]; do
    arg="${args[$i]}"
    case "$arg" in
        --json) JSON_MODE=true ;;
        --output)
            i=$((i + 1))
            OUTPUT_PATH="${args[$i]:?--output requires a path}"
            ;;
        --spec)
            i=$((i + 1))
            SPEC_PATH="${args[$i]:?--spec requires a path}"
            FORCE_SPEC=true
            ;;
        --user-stories)
            i=$((i + 1))
            USER_STORIES_PATH="${args[$i]:?--user-stories requires a path}"
            FORCE_USER_STORIES=true
            ;;
        --jira-export)
            i=$((i + 1))
            JIRA_EXPORT_PATH="${args[$i]:?--jira-export requires a path}"
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option '$arg'. Use --help for usage." >&2
            exit 1
            ;;
    esac
    i=$((i + 1))
done

_paths_output=$(get_feature_paths) || { echo "ERROR: Failed to resolve feature paths" >&2; exit 1; }
eval "$_paths_output"
unset _paths_output

if [[ -z "$JIRA_EXPORT_PATH" ]]; then
    JIRA_EXPORT_PATH="$REPO_ROOT/.specify/jira-export.json"
fi
[[ "$JIRA_EXPORT_PATH" != /* ]] && JIRA_EXPORT_PATH="$REPO_ROOT/$JIRA_EXPORT_PATH"

load_jira_export_config() {
    if [[ ! -f "$JIRA_EXPORT_PATH" ]]; then
        echo "ERROR: Jira export config not found: $JIRA_EXPORT_PATH" >&2
        exit 1
    fi
    if ! has_jq; then
        echo "ERROR: jq is required to read $JIRA_EXPORT_PATH" >&2
        exit 1
    fi
    if ! jq -e '.csv_columns | type == "array" and length > 0' "$JIRA_EXPORT_PATH" >/dev/null; then
        echo "ERROR: $JIRA_EXPORT_PATH must define a non-empty csv_columns array" >&2
        exit 1
    fi
    CSV_COLUMNS=()
    while IFS= read -r _col || [[ -n "$_col" ]]; do
        CSV_COLUMNS+=("$_col")
    done < <(jq -r '.csv_columns[]' "$JIRA_EXPORT_PATH")
    unset _col
}

resolve_source_path() {
    local candidate=""

    if $FORCE_SPEC; then
        candidate="$SPEC_PATH"
    elif $FORCE_USER_STORIES; then
        candidate="$USER_STORIES_PATH"
    elif [[ -f "$FEATURE_DIR/user-stories.md" ]]; then
        candidate="$FEATURE_DIR/user-stories.md"
    elif [[ -f "$FEATURE_SPEC" ]]; then
        candidate="$FEATURE_SPEC"
    else
        echo "ERROR: No user story source found in $FEATURE_DIR" >&2
        echo "Expected user-stories.md or spec.md. Run /speckit-userstories or /speckit-specify." >&2
        exit 1
    fi

    [[ "$candidate" != /* ]] && candidate="$REPO_ROOT/$candidate"

    if [[ ! -f "$candidate" ]]; then
        echo "ERROR: User story source not found: $candidate" >&2
        if $FORCE_SPEC; then
            echo "Run /speckit-specify first, or pass --user-stories." >&2
        elif $FORCE_USER_STORIES; then
            echo "Run /speckit-userstories first, or pass --spec." >&2
        else
            echo "Run /speckit-userstories or /speckit-specify." >&2
        fi
        exit 1
    fi

    SOURCE_PATH="$candidate"
}

resolve_source_path
load_jira_export_config

if [[ -z "$OUTPUT_PATH" ]]; then
    OUTPUT_PATH="$FEATURE_DIR/user-stories.csv"
fi
[[ "$OUTPUT_PATH" != /* ]] && OUTPUT_PATH="$REPO_ROOT/$OUTPUT_PATH"

mkdir -p "$(dirname "$OUTPUT_PATH")"

# RFC 4180-style CSV field quoting
csv_field() {
    local value="${1:-}"
    value="${value//$'\r'/}"
    value="${value//\"/\"\"}"
    printf '"%s"' "$value"
}

trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

jira_default() {
    local column="$1"
    jq -r --arg col "$column" '.defaults[$col] // ""' "$JIRA_EXPORT_PATH"
}

resolve_priority() {
    local spec_priority="${1:-}"
    local mapped=""

    if [[ -n "$spec_priority" ]]; then
        mapped="$(jq -r --arg p "$spec_priority" '.priority_map[$p] // empty' "$JIRA_EXPORT_PATH")"
        if [[ -n "$mapped" && "$mapped" != "null" ]]; then
            printf '%s' "$mapped"
            return 0
        fi
        if [[ "$spec_priority" =~ ^P([0-9]+)$ ]]; then
            printf 'Priority %s' "${BASH_REMATCH[1]}"
            return 0
        fi
    fi

    jira_default "Priority"
}

# Convert ATX markdown headings (# .. ######) to Jira wiki (h1. .. h6.). Description column only.
md_headings_to_jira_wiki() {
    local text="${1:-}"
    [[ -z "$text" ]] && return 0
    printf '%s' "$text" | sed -E \
        -e 's/^(######)[[:space:]]+(.+)[[:space:]]*$/h6. \2/' \
        -e 's/^(#####)[[:space:]]+(.+)[[:space:]]*$/h5. \2/' \
        -e 's/^(####)[[:space:]]+(.+)[[:space:]]*$/h4. \2/' \
        -e 's/^(###)[[:space:]]+(.+)[[:space:]]*$/h3. \2/' \
        -e 's/^(##)[[:space:]]+(.+)[[:space:]]*$/h2. \2/' \
        -e 's/^([#])[[:space:]]+(.+)[[:space:]]*$/h1. \2/'
}

append_description_section() {
    local heading="$1"
    local content="$2"

    [[ -z "$content" ]] && return 0
    if [[ -n "$DESCRIPTION_BODY" ]]; then
        DESCRIPTION_BODY="${DESCRIPTION_BODY}

"
    fi
    DESCRIPTION_BODY="${DESCRIPTION_BODY}h3. ${heading}
${content}"
}

append_bullet_section() {
    local heading="$1"
    shift
    local item bullets=""

    (("$#" == 0)) && return 0
    for item in "$@"; do
        bullets="${bullets}- ${item}
"
    done
    bullets="${bullets%$'\n'}"
    append_description_section "$heading" "$bullets"
}

build_description() {
    local scenario index=1 scenarios=""

    DESCRIPTION_BODY=""
    append_description_section "User story" "$STORY_DESC"
    append_description_section "Why this priority" "$STORY_WHY"
    append_description_section "Independent test" "$STORY_TEST"
    if ((${#STORY_IN_SCOPE[@]} > 0)); then
        append_bullet_section "In scope" "${STORY_IN_SCOPE[@]}"
    fi
    if ((${#STORY_OUT_OF_SCOPE[@]} > 0)); then
        append_bullet_section "Out of scope" "${STORY_OUT_OF_SCOPE[@]}"
    fi

    if ((${#STORY_SCENARIOS[@]} > 0)); then
        for scenario in "${STORY_SCENARIOS[@]}"; do
            scenarios="${scenarios}${index}. ${scenario}
"
            index=$((index + 1))
        done
        scenarios="${scenarios%$'\n'}"
        append_description_section "Acceptance scenarios" "$scenarios"
    fi

    printf '%s' "$(md_headings_to_jira_wiki "$DESCRIPTION_BODY")"
}

# Map a #### or normalized bold label to parser section (why, test, in_scope, out_of_scope, scenarios).
normalize_section_label() {
    local label
    label="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
    label="${label%:}"
    label="$(trim "$label")"
    case "$label" in
        "why this priority") printf 'why' ;;
        "independent test") printf 'test' ;;
        "in scope") printf 'in_scope' ;;
        "out of scope") printf 'out_of_scope' ;;
        acceptance\ scenario|acceptance\ scenarios) printf 'scenarios' ;;
        *) printf '' ;;
    esac
}

story_column_value() {
    local column="$1"
    local value=""

    case "$column" in
        "Issue Type")
            value="$(jira_default "Issue Type")"
            ;;
        Summary)
            value="US${STORY_NUM} - ${STORY_TITLE}"
            ;;
        Description)
            value="$(build_description)"
            ;;
        Labels)
            value="$(jira_default "Labels")"
            ;;
        Priority)
            value="$(resolve_priority "$STORY_PRIORITY")"
            ;;
        *)
            value="$(jira_default "$column")"
            ;;
    esac

    csv_field "$value"
}

# State for current story block
STORY_NUM=""
STORY_TITLE=""
STORY_PRIORITY=""
STORY_DESC=""
STORY_WHY=""
STORY_TEST=""
STORY_SCENARIOS=()
STORY_IN_SCOPE=()
STORY_OUT_OF_SCOPE=()

reset_story() {
    STORY_NUM=""
    STORY_TITLE=""
    STORY_PRIORITY=""
    STORY_DESC=""
    STORY_WHY=""
    STORY_TEST=""
    STORY_SCENARIOS=()
    STORY_IN_SCOPE=()
    STORY_OUT_OF_SCOPE=()
}

append_to_var() {
    local target="$1"
    local line="$2"
    line="$(trim "$line")"
    [[ -z "$line" ]] && return 0
    case "$target" in
        STORY_DESC)
            if [[ -n "$STORY_DESC" ]]; then STORY_DESC="$STORY_DESC $line"; else STORY_DESC="$line"; fi
            ;;
        STORY_WHY)
            if [[ -n "$STORY_WHY" ]]; then STORY_WHY="$STORY_WHY $line"; else STORY_WHY="$line"; fi
            ;;
        STORY_TEST)
            if [[ -n "$STORY_TEST" ]]; then STORY_TEST="$STORY_TEST $line"; else STORY_TEST="$line"; fi
            ;;
    esac
}

append_scope_item() {
    local target="$1"
    local line="$2"
    line="$(trim "$line")"
    [[ -z "$line" ]] && return 0
    case "$target" in
        STORY_IN_SCOPE) STORY_IN_SCOPE+=("$line") ;;
        STORY_OUT_OF_SCOPE) STORY_OUT_OF_SCOPE+=("$line") ;;
    esac
}

write_csv_row() {
    local first=true
    local value

    for value in "$@"; do
        if $first; then
            first=false
        else
            printf ','
        fi
        printf '%s' "$value"
    done
    printf '\n'
}

write_csv_header() {
    local -a header=()
    local column

    for column in "${CSV_COLUMNS[@]}"; do
        header+=("$(csv_field "$column")")
    done
    write_csv_row "${header[@]}"
}

flush_story() {
    [[ -z "$STORY_NUM" ]] && return 0
    local column value
    local -a row=()

    for column in "${CSV_COLUMNS[@]}"; do
        value="$(story_column_value "$column")"
        row+=("$value")
    done
    write_csv_row "${row[@]}" >>"$CSV_TMP"
    EXPORTED_STORY_COUNT=$((EXPORTED_STORY_COUNT + 1))
}

parse_spec() {
    local spec_file="$1"
    local in_stories=false
    local section="" # description | why | test | in_scope | out_of_scope | scenarios

    reset_story

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Enter "User Scenarios & Testing" major section
        if [[ "$line" =~ ^##[[:space:]]User\ Scenarios ]]; then
            in_stories=true
            section=""
            continue
        fi

        # Leave user-stories region at next major section (## but not ###)
        if $in_stories && [[ "$line" =~ ^##[[:space:]] ]] && [[ ! "$line" =~ ^### ]]; then
            flush_story
            reset_story
            in_stories=false
            continue
        fi

        $in_stories || continue

        if [[ "$line" =~ ^###[[:space:]]User[[:space:]]Story[[:space:]]([0-9]+)[[:space:]]-[[:space:]](.+)[[:space:]]\(Priority:[[:space:]]*(P[0-9]+)\)[[:space:]]*$ ]]; then
            flush_story
            reset_story
            STORY_NUM="${BASH_REMATCH[1]}"
            STORY_TITLE="$(trim "${BASH_REMATCH[2]}")"
            STORY_PRIORITY="${BASH_REMATCH[3]}"
            section="description"
            continue
        fi

        [[ -z "$STORY_NUM" ]] && continue

        if [[ "$line" =~ ^---[[:space:]]*$ ]]; then
            section=""
            continue
        fi

        if [[ "$line" =~ ^\*\*Why\ this\ priority\*\*:[[:space:]]*(.*)$ ]]; then
            section="why"
            STORY_WHY="$(trim "${BASH_REMATCH[1]}")"
            continue
        fi

        if [[ "$line" =~ ^\*\*Independent\ Test\*\*:[[:space:]]*(.*)$ ]]; then
            section="test"
            STORY_TEST="$(trim "${BASH_REMATCH[1]}")"
            continue
        fi

        if [[ "$line" =~ ^\*\*In\ scope\*\*:[[:space:]]*(.*)$ ]]; then
            section="in_scope"
            local inline="${BASH_REMATCH[1]}"
            if [[ -n "$(trim "$inline")" ]]; then
                append_scope_item STORY_IN_SCOPE "$inline"
            fi
            continue
        fi

        if [[ "$line" =~ ^\*\*Out\ of\ scope\*\*:[[:space:]]*(.*)$ ]]; then
            section="out_of_scope"
            local inline="${BASH_REMATCH[1]}"
            if [[ -n "$(trim "$inline")" ]]; then
                append_scope_item STORY_OUT_OF_SCOPE "$inline"
            fi
            continue
        fi

        if [[ "$line" =~ ^\*\*Acceptance\ Scenarios\*\*:[[:space:]]*$ ]]; then
            section="scenarios"
            continue
        fi

        # user-stories.md template: #### Section title (optional trailing colon)
        if [[ "$line" =~ ^####[[:space:]]+(.+)[[:space:]]*$ ]]; then
            local h4_title h4_section
            h4_title="$(trim "${BASH_REMATCH[1]}")"
            h4_section="$(normalize_section_label "$h4_title")"
            if [[ -n "$h4_section" ]]; then
                section="$h4_section"
                continue
            fi
        fi

        if [[ "$line" =~ ^-[[:space:]]+(.*)$ ]]; then
            case "$section" in
                in_scope) append_scope_item STORY_IN_SCOPE "${BASH_REMATCH[1]}" ;;
                out_of_scope) append_scope_item STORY_OUT_OF_SCOPE "${BASH_REMATCH[1]}" ;;
            esac
            continue
        fi

        if [[ "$line" =~ ^[0-9]+\.[[:space:]]+(.*)$ ]] && [[ "$section" == "scenarios" ]]; then
            STORY_SCENARIOS+=("$(trim "${BASH_REMATCH[1]}")")
            continue
        fi

        # Skip story-level ### headings and unknown markdown headings
        if [[ "$line" =~ ^###[[:space:]]User[[:space:]]Story ]]; then
            continue
        fi
        if [[ "$line" =~ ^#{1,6}[[:space:]] ]]; then
            continue
        fi

        case "$section" in
            description)
                append_to_var STORY_DESC "$line"
                ;;
            why)
                append_to_var STORY_WHY "$line"
                ;;
            test)
                append_to_var STORY_TEST "$line"
                ;;
            in_scope|out_of_scope|scenarios)
                ;;
        esac
    done <"$spec_file"

    if $in_stories; then
        flush_story
    fi
}

CSV_TMP="$(mktemp "${TMPDIR:-/tmp}/spec-to-issue.XXXXXX")"
trap 'rm -f "$CSV_TMP"' EXIT

write_csv_header >"$CSV_TMP"

parse_spec "$SOURCE_PATH"

STORY_COUNT="$EXPORTED_STORY_COUNT"
if [[ "$STORY_COUNT" -lt 1 ]]; then
    echo "ERROR: No user stories found in $SOURCE_PATH" >&2
    echo "Expected headings like: ### User Story 1 - Title (Priority: P1)" >&2
    exit 1
fi

mv "$CSV_TMP" "$OUTPUT_PATH"
trap - EXIT

if $JSON_MODE; then
    if has_jq; then
        jq -cn \
            --arg output_file "$OUTPUT_PATH" \
            --arg feature_dir "$FEATURE_DIR" \
            --arg source_file "$SOURCE_PATH" \
            --arg jira_export_config "$JIRA_EXPORT_PATH" \
            --argjson story_count "$STORY_COUNT" \
            '{OUTPUT_FILE:$output_file,FEATURE_DIR:$feature_dir,SOURCE_FILE:$source_file,JIRA_EXPORT_CONFIG:$jira_export_config,STORY_COUNT:$story_count}'
    else
        printf '{"OUTPUT_FILE":"%s","FEATURE_DIR":"%s","SOURCE_FILE":"%s","JIRA_EXPORT_CONFIG":"%s","STORY_COUNT":%s}\n' \
            "$(json_escape "$OUTPUT_PATH")" \
            "$(json_escape "$FEATURE_DIR")" \
            "$(json_escape "$SOURCE_PATH")" \
            "$(json_escape "$JIRA_EXPORT_PATH")" \
            "$STORY_COUNT"
    fi
else
    echo "Wrote $STORY_COUNT user stories to $OUTPUT_PATH (columns from $JIRA_EXPORT_PATH)"
fi
