#!/usr/bin/env bash
# Copy a Cursor skill bundle from this repo into a target project.
#
# Usage: ./install-skill.sh <skill-dir-name> <target-project-path>
#
# Installs to: <target-project>/.cursor/skills/<skill-dir-name>/
# Overwrites existing files so the target stays in sync with this copy.

set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

usage() {
    sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'
    echo ""
    echo "Example:"
    echo "  $0 codebase-standards-assessment ../my-api-repo"
    echo "  $0 speckit-project-context /Users/me/projects/my-app"
}

if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ $# -ne 2 ]]; then
    usage >&2
    exit 1
fi

SKILL_DIR_NAME="$1"
TARGET_PROJECT="$2"

if [[ "$SKILL_DIR_NAME" == */* ]] || [[ "$SKILL_DIR_NAME" == ..* ]] || [[ "$SKILL_DIR_NAME" == . ]]; then
    echo "ERROR: Invalid skill directory name: $SKILL_DIR_NAME" >&2
    exit 1
fi

REPO_ROOT="$(get_repo_root)" || {
    echo "ERROR: Not a Spec Kit project (.specify/ not found)." >&2
    exit 1
}

SOURCE_DIR="$REPO_ROOT/.cursor/skills/$SKILL_DIR_NAME"

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "ERROR: Skill bundle not found: $SOURCE_DIR" >&2
    exit 1
fi

if [[ ! -d "$TARGET_PROJECT" ]]; then
    echo "ERROR: Target path is not a directory: $TARGET_PROJECT" >&2
    exit 1
fi

TARGET_PROJECT="$(CDPATH="" cd "$TARGET_PROJECT" && pwd)"
DEST="$TARGET_PROJECT/.cursor/skills/$SKILL_DIR_NAME"

mkdir -p "$DEST"

if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$SOURCE_DIR/" "$DEST/"
else
    find "$DEST" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    cp -R "$SOURCE_DIR/." "$DEST/"
fi

echo "Installed $SKILL_DIR_NAME to $DEST"
file_count="$(find "$DEST" -type f | wc -l | tr -d ' ')"
echo "Synced $file_count file(s)."
