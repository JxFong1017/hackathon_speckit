---
name: codebase-standards-assessment-changes
description: Assesses only new or modified code (uncommitted and/or committed changes) against documented standards and best practices. Detects frontend vs backend repo type.
triggers:
  - assess my changes
  - assess my diff
  - evaluate my changes
  - evaluate what I changed
  - review my changes against standards
  - review my diff against standards
  - standards check before PR
  - pre-PR standards check
  - review branch diff
  - review staged files
  - review uncommitted work
  - check my changes against standards
---

# Codebase Standards Assessment (Changes)

Evaluate **only changed files** against project standards. Findings must be evidence-based, severity-ranked, and focused on actionable signal.

Shared standards live in [../references/](../references/).

## Before assessing

1. Complete **Step 0 — Classify repository** (below).
2. Read [standards-sources.md](../references/standards-sources.md) to locate repo-specific docs.
3. Read applicable standards files for the classified type.
4. Skim [reference.md](../references/reference.md) for severity levels, [lint verification](../references/reference.md#lint-verification), and low-signal exclusions.
5. If the user points to a specific standards document, treat it as authoritative.

## Scope

**In scope:** Files that are new or modified in the selected change set (see Step 3).

**Also check when a changed file implies a convention obligation:**

- New component/page/handler → paired test file exists or was added in the same change set **only if** Step 1 loaded a co-location requirement — from applicable `standards-*.md` rules (e.g. **FE-001**, **BE-004**) or repo **README** / docs per [standards-sources.md](../references/standards-sources.md)
- Changed `package.json` → dependency hygiene rules
- Changed config or CI → configuration hygiene rules

**Out of scope:** Unchanged files elsewhere in the repo (do not review the full codebase).

**Exclude** changed paths matching low-signal patterns in [reference.md](../references/reference.md) unless the change itself is suspicious (e.g. secrets in generated output).

## Assessment workflow

```
Assessment progress:
- [ ] Step 0: Classify repository type
- [ ] Step 1: Load standards documents
- [ ] Step 2: Determine change set
- [ ] Step 3: Review every changed file
- [ ] Step 4: Run `pnpm lint` and evaluate each dimension against standards
- [ ] Step 5: Rank findings by severity/impact
- [ ] Step 6: Produce structured report
```

### Step 0 — Classify repository

Follow [repository classification](../references/reference.md#repository-classification) in [reference.md](../references/reference.md). State the classification and confidence in the report.

### Step 1 — Load standards

1. Discover repo-specific docs per [standards-sources.md](../references/standards-sources.md).
2. Load skill standards files for the classified type.
3. Extract explicit MUST/SHOULD rules and implicit conventions. Note each rule's **ID** for use in the report Rule column.

### Step 2 — Determine change set

Run git commands to build the file list. State which mode was used in the report.

| Mode                                                            | When to use                         | Commands                                                                            |
| --------------------------------------------------------------- | ----------------------------------- | ----------------------------------------------------------------------------------- |
| **Uncommitted** (default if user says "staged" / "uncommitted") | Working tree and index              | `git status --short`, `git diff --name-only`, `git diff --cached --name-only`       |
| **Committed**                                                   | Branch vs base, or specific commits | `git merge-base HEAD main` (or `master`), then `git diff --name-only <base>...HEAD` |
| **Both** (default if unspecified or if user says "my changes")  | Full pre-PR review                  | Union of uncommitted + committed file lists (see deduplication below)               |

**Base branch:** Default to `main`, then `master`, then upstream tracking branch. User may specify base branch or commit range (e.g. `abc123..HEAD`).

**Deduplicate by final file path.** A path that appears in committed, staged, and unstaged lists counts once. Include added, modified, and renamed files. Note deleted files only if deletion violates conventions (e.g. removed tests without replacement).

When the same file changed in multiple git states, **review it once** using the **final effective diff** for that mode — the cumulative change from the comparison point to the current working tree, not separate partial diffs per state.

| Mode            | Effective diff per file (`<base>` = merge-base or user-specified start commit) |
| --------------- | ------------------------------------------------------------------------------ |
| **Uncommitted** | `git diff HEAD -- <path>` — staged + unstaged combined vs `HEAD`               |
| **Committed**   | `git diff <base>...HEAD -- <path>` — branch commits only                       |
| **Both**        | `git diff <base> -- <path>` — branch commits + staged + unstaged vs `<base>`   |

Resolve `<base>` once per assessment: `git merge-base HEAD main` (or `master`), or the start of a user-specified range (e.g. `abc123` for `abc123..HEAD`).

If there are **no changes**, report that and stop — do not assess the wider codebase.

### Step 3 — Review every changed file

**Review the complete change set — do not sample within it.**

1. List every file from Step 2.
2. For each file: read the **effective diff** for the assessment mode (see Step 2 table) and the resulting file content where needed.
3. Evaluate each change against loaded standards.
4. Check convention obligations triggered by the change (e.g. missing paired test for a new component/handler when loaded standards or repo README require co-location; barrel index added, etc.) even if the obligation file itself was not modified. Do not flag missing paired tests when loaded standards and repo docs are silent on co-location.

### Step 4 — Run lint and evaluate dimensions

**Lint:** Follow [Lint verification](../references/reference.md#lint-verification), including the changes-assessment addendum.

| Dimension             | What to check                                            |
| --------------------- | -------------------------------------------------------- |
| Maintainability       | Complexity, duplication, naming introduced by the change |
| Testing               | New/changed code has tests; mock boundaries respected    |
| Security              | Secrets, auth, injection introduced in the diff          |
| Documentation         | Docs updated when behaviour or setup changes             |
| Configuration hygiene | Manifest, CI, env config changes                         |

Cite file paths, line ranges, and **rule IDs** (`GEN-###`, `BE-###`, `FE-###`). For repo-only conventions not in `standards-*.md`, cite **`README`** with the section name.

### Step 5 — Rank findings

Assign severity using [reference.md](../references/reference.md).

### Step 6 — Report

Use the output template below. For the **Lint errors** section, use the [Lint errors output template](../references/reference.md#lint-errors-output-template) (changes-assessment variant).

## Output template

```markdown
# Codebase Standards Assessment (Changes) — [project name]

**Repository type:** [frontend | backend | full-stack | unclear] — [confidence]
**Assessment mode:** Changes only
**Change set:** [uncommitted | committed | both]
**Base branch / range:** [e.g. main, or abc123..HEAD]
**Files changed:** [count] — [list or summary by directory]
**Standards reviewed:** [list]
**Date:** [today]

## Executive summary

[2–4 sentences focused on this change set]

---

## Code quality and maintainability

| Severity | Layer | Finding | Evidence | Rule |
| -------- | ----- | ------- | -------- | ---- |

## Architectural or structural concerns

| Severity | Layer | Finding | Evidence | Rule |
| -------- | ----- | ------- | -------- | ---- |

## Testing gaps

| Severity | Layer | Finding | Evidence | Rule |
| -------- | ----- | ------- | -------- | ---- |

## Security and risky patterns

| Severity | Layer | Finding | Evidence | Rule |
| -------- | ----- | ------- | -------- | ---- |

## Dependency and configuration hygiene

| Severity | Layer | Finding | Evidence | Rule |
| -------- | ----- | ------- | -------- | ---- |

## Documentation and repo guidance quality

| Severity | Layer | Finding | Evidence | Rule |
| -------- | ----- | ------- | -------- | ---- |

## Adherence to repo or team conventions

| Severity | Layer | Finding | Evidence | Rule |
| -------- | ----- | ------- | -------- | ---- |

## Lint errors (`pnpm lint`)

_[Use Lint errors output template (changes-assessment variant) from reference.md]_

---

## Recommended improvements

### P0 — Critical

1. ...

### P1 — High

1. ...

### P2 — Medium

1. ...

### P3 — Low / informational

1. ...

---

## Assumptions and limitations

[Change set scope, files not reviewed outside diff, `pnpm lint` not run or incomplete]
```

Omit the **Layer** column when repo type is not full-stack.

## Quality bar

- **Change-scoped:** Do not review unchanged files outside the change set.
- **Complete within scope:** Review every changed file — no sampling within the diff.
- **Evidence-driven:** Reference diff hunks and paths; state when git state could not be read.
- **Standards-linked:** Cite rule ID (`GEN-###`, `BE-###`, `FE-###`) for skill standards; cite `README` (section) for repo-only rules; cite `engineering risk` only when no documented rule applies.
- **Actionable:** Recommendations must be specific enough to fix before merge.

## Additional resources

| File                                                         | Purpose                                                    |
| ------------------------------------------------------------ | ---------------------------------------------------------- |
| [standards-sources.md](../references/standards-sources.md)   | Discover repo-specific docs                                |
| [standards-general.md](../references/standards-general.md)   | Cross-cutting rules                                        |
| [standards-frontend.md](../references/standards-frontend.md) | UI conventions                                             |
| [standards-backend.md](../references/standards-backend.md)   | API/service conventions                                    |
| [reference.md](../references/reference.md)                   | Repository classification, severity rubric, and exclusions |
