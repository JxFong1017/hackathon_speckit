---
name: "speckit-userstories"
description: "Create or update user-stories.md from spec.md with prioritized user stories and per-story in/out scope. Requires spec.md."
compatibility: "Requires spec-kit project structure with .specify/ directory"
metadata:
  author: "flex-hiring-and-adjacencies"
  source: ".specify/templates/user-stories-template.md"
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Current workspace only (mandatory)

Before any other step:

Resolve paths **only** by running `.specify/scripts/bash/check-prerequisites.sh --require-spec` (see step 1 below). Treat its stdout/stderr and exit code as the **sole source of truth** for `FEATURE_DIR` and whether `spec.md` exists.

## Outline

The text the user typed after `/speckit-userstories` is an optional refinement description. Assume you always have it available in this conversation even if `$ARGUMENTS` appears literally below. Do not ask the user to repeat it unless they provided an empty command and you need clarification for a merge.

Given that, do this:

1. **Prerequisites check** (mandatory; do this before any other work):

   From the repository root, run:

   ```bash
   bash .specify/scripts/bash/check-prerequisites.sh --require-spec
   ```

   - **Non-zero exit** → **stop immediately**. Report the script’s stderr (and relevant stdout) as the ERROR. Do **not** create directories, copy templates, read `spec.md`, or continue the workflow.
   - **Zero exit** → parse `FEATURE_DIR` from the script’s text output (`FEATURE_DIR:` line). Do **not** override or second-guess this path.
   - Set `SPEC_FILE` to `<FEATURE_DIR>/spec.md` (the script’s `--require-spec` guarantees this file exists; do not re-validate with separate `test` or search).
   - Read `spec.md` for user story headings and acceptance scenarios.

2. **Set paths**:
   - `USER_STORIES_FILE` = `<FEATURE_DIR>/user-stories.md`

2b. **Existence probe** (mandatory before step 3; see `.cursor/rules/specify-rules.md`):

```bash
test -f "$FEATURE_DIR/user-stories.md"
```

- Exit **0** → set `USER_STORIES_EXISTS=true` (may `Read` `USER_STORIES_FILE`).
- Exit **1** → set `USER_STORIES_EXISTS=false`; do **not** `Read` `user-stories.md` until after step 4 creates it.

Use **only** `USER_STORIES_EXISTS` for the priority table—not `Read` success, glob, git status, or prior conversation.

3. **Choose content source** (strict order; stop at first match):

   | Priority | Source                                                                                                 | Action                                                                                                                 |
   | -------- | ------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------- |
   | 1        | Non-empty `$ARGUMENTS` and `USER_STORIES_EXISTS=true`                                                  | Merge refinements (scope, reprioritize, add stories) using `spec.md` as source of truth for story bodies and scenarios |
   | 2        | `USER_STORIES_EXISTS=true` and `$ARGUMENTS` is empty                                                   | Lightweight quality pass only; apply no structural changes unless stories fail the quality check                       |
   | 3        | `USER_STORIES_EXISTS=false` or file newly initialized from template (no `### User Story` headings yet) | Copy template, sync all `### User Story N` blocks from `spec.md`, add per-story **In scope** / **Out of scope**        |
   | 4        | None of the above applicable                                                                           | ERROR — see Errors table                                                                                               |

4. **Create or update `user-stories.md`**:
   - If the file does not exist: copy `.specify/templates/user-stories-template.md` to `USER_STORIES_FILE` (always include `**Related spec**: [spec.md](./spec.md)`)
   - If `user-stories.md` was just created from template (no story headings yet): sync from `spec.md` as in priority 3
   - If `user-stories.md` already exists and `$ARGUMENTS` is non-empty: merge edits against `spec.md` (add stories, reprioritize, refine per-story scope, etc.)
   - **Never** invent stories absent from `spec.md` — this command does not update `spec.md`. Use `$ARGUMENTS` only to refine per-story scope, priorities, or alignment with existing spec story blocks

5. **Fill the document** using the template structure:
   - Header metadata must match `.specify/templates/user-stories-template.md` exactly — do **not** add fields absent from the template (e.g. no `**Status**`, no feature branch line)
   - Allowed header fields: feature name (title), Feature Directory, Created, Input, **Related spec** (always — links to `spec.md`)
   - **Only** the `## User Scenarios & Testing` section and user story subsections — do **not** add requirements, success criteria, assumptions, or feature-wide Out of Scope from `spec-template.md`
   - Every user story **MUST** include, in this order after **Independent Test**:
     - `**In scope**:` — bullet list of what this story delivers
     - `**Out of scope**:` — bullet list of what this story explicitly does not cover (other stories, later phases, or adjacent feature areas)
   - Keep headings compatible with Spec Kit export: `### User Story N - Title (Priority: PN)`
   - Stories separated by `---` as in the spec template

6. **Per-story scope rules**:
   - In scope / Out of scope describe **this story's slice**, not the whole project
   - Out of scope for story A may be In scope for story B — call that out when useful
   - Do not duplicate the feature-level `## Out of Scope` section from `spec.md`; translate only what matters to each story's boundary

7. **Quality check** (lightweight, no separate checklist file):
   - Each story is independently testable and has at least one acceptance scenario
   - Priorities are assigned (P1, P2, …)
   - Every story has non-empty In scope and Out of scope lists
   - Story set is consistent with `spec.md` (same story headings and scenarios unless `$ARGUMENTS` explicitly refined scope only)
   - No implementation details (frameworks, APIs, schemas) unless already present in `spec.md` and required for testability

8. **Report completion** with:
   - `FEATURE_DIR`, `SPEC_FILE`, and `USER_STORIES_FILE` paths
   - `user-stories.md: created | updated | unchanged (verified with test -f at start)` — never “unchanged” unless `USER_STORIES_EXISTS` was true at step 2b
   - Story count and priority summary
   - Whether content was sourced from `spec.md`, `user-stories.md` (existing), user input refinements, or a combination
   - **Suggested next steps** (context-dependent):
     - `/speckit-clarify` if the spec has open questions
     - `/speckit-plan` when stories and scope are stable
     - `/speckit-spectoissue` when `user-stories.md` has `### User Story` headings (exports CSV)
     - Do **not** suggest `/speckit-spectoissue` if `user-stories.md` has no `### User Story` headings yet

## Prerequisites

- `.specify/templates/user-stories-template.md` must exist
- `bash .specify/scripts/bash/check-prerequisites.sh --require-spec` exits 0 (feature directory and `spec.md` validated by the script)

## Errors

| Condition                                             | Action                                                                                     |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `check-prerequisites.sh --require-spec` non-zero exit | **Stop.** Report script stderr as ERROR; do not continue                                   |
| `spec.md` exists but has no `### User Story` headings | ERROR — add user stories to `spec.md` via `/speckit-specify` or edit the spec, then re-run |
| Template missing                                      | ERROR — restore `.specify/templates/user-stories-template.md`                              |
| Referenced path from prior conversation               | **Forbidden** — re-run the prerequisite script or drop the reference                       |

## Quick Guidelines

- Run **after** `/speckit-specify`: `spec.md` → `/speckit-userstories` → `/speckit-clarify` (optional) → `/speckit-plan` → tasks
- Focus on **WHAT** each story delivers and **WHY**, not implementation
- Per-story Out of scope prevents scope creep during implementation and planning
- When syncing from `spec.md`, do not remove or weaken existing acceptance scenarios
