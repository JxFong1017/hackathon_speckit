---
name: "speckit-spectoissue"
description: "Export user stories to user-stories.csv from user-stories.md or spec.md (stories-first friendly)."
compatibility: "Requires spec-kit project structure with .specify/ directory"
metadata:
  author: "flex-hiring-and-adjacencies"
  source: ".specify/scripts/bash/spec-to-issue.sh"
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Current workspace only (mandatory)

- Run the export script against files that exist **now**; do not assume `spec.md` or `user-stories.md` from prior sessions.
- Let `spec-to-issue.sh` resolve the source (it ignores stale `feature.json` and prefers existing `spec.md` or `user-stories.md` on disk).
- Report `SOURCE_FILE` from script JSON output, not from memory.

## Outline

Export uses the bash script as the single source of truth. **Do not** re-implement parsing in the agent.

### Source file (stories-first)

The script reads user stories from **one** markdown file, in this order:

1. `--spec <path>` if the user passed `--spec` in `$ARGUMENTS`
2. `--user-stories <path>` if the user passed `--user-stories` in `$ARGUMENTS`
3. `<FEATURE_DIR>/spec.md` if it exists on disk
4. `<FEATURE_DIR>/user-stories.md` if it exists on disk
5. ERROR — neither file exists (suggest `/speckit-userstories` with a description, or `/speckit-specify`)

Missing `spec.md` alone is **not** an error when `user-stories.md` is present.

1. From the repository root, run:

```bash
bash .specify/scripts/bash/spec-to-issue.sh --json
```

Pass through any user arguments:

- `--output <path>` — custom CSV destination
- `--spec <path>` — force `spec.md` (or another markdown file with Spec Kit story headings)
- `--user-stories <path>` — force `user-stories.md` (or another compatible markdown file)

2. Parse JSON stdout for `OUTPUT_FILE`, `STORY_COUNT`, `FEATURE_DIR`, `SOURCE_FILE`, and `JIRA_EXPORT_CONFIG`.

3. Report to the user:
   - Number of user stories exported
   - Which file was used (`SOURCE_FILE`)
   - Which Jira export config was used (`JIRA_EXPORT_CONFIG`)
   - Absolute path to the CSV (default `<feature-dir>/user-stories.csv`)

4. Do **not** read `spec.md` yourself unless verifying the script failed; the script resolves the source.

## CSV columns (from `.specify/jira-export.json`)

The script reads `csv_columns` and `defaults` from `.specify/jira-export.json` (override with `--jira-export`). Requires `jq`.

| Column        | How it is populated                                                                                           |
| ------------- | ------------------------------------------------------------------------------------------------------------- |
| `Issue Type`  | `defaults["Issue Type"]` (e.g. `Story`)                                                                       |
| `Summary`     | `US{n} - {title}` from the user story heading                                                                 |
| `Description` | Multi-section text: user story, why priority, independent test, in/out of scope bullets, acceptance scenarios |
| `Labels`      | `defaults["Labels"]`                                                                                          |
| `Priority`    | `priority_map` in config if set; else `P{n}` → `Priority {n}`; else `defaults["Priority"]`                    |

Add or reorder columns by editing `csv_columns` in `jira-export.json`. Unknown column names use `defaults` only.

## Prerequisites

- Active feature directory (via `SPECIFY_FEATURE_DIRECTORY`, `.specify/feature.json`, or branch name)
- At least one of: `user-stories.md` or `spec.md` with Spec Kit headings: `### User Story N - Title (Priority: PN)`

## Errors

If the script exits non-zero, surface stderr. Common cases:

| Condition                               | Action                                                                                       |
| --------------------------------------- | -------------------------------------------------------------------------------------------- |
| Neither `spec.md` nor `user-stories.md` | Run `/speckit-userstories <description>` or `/speckit-specify`                               |
| File exists but no stories parsed       | Check `### User Story N - Title (Priority: PN)` headings under `## User Scenarios & Testing` |
| Both files exist, wrong source used     | Pass `--user-stories` or `--spec` explicitly                                                 |

## Workflow notes

- **Stories-first:** `/speckit-userstories` → `/speckit-spectoissue` (uses `user-stories.md`)
- **Spec-first:** `/speckit-specify` → `/speckit-spectoissue` (uses `spec.md` when present)
