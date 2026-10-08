---
name: codebase-standards-assessment-full
description: Exhaustively assesses every in-scope file in the project codebase against documented standards and best practices. Enumerates the full tree (not a sample). Detects frontend vs backend repo type.
triggers:
  - assess the codebase
  - assess the entire project
  - assess the whole codebase
  - evaluate my project
  - evaluate the entire codebase
  - evaluate the whole project
  - full codebase audit
  - complete standards review
  - exhaustive health check
  - review standards across the repo
  - how healthy is this codebase
  - codebase health check
---

# Codebase Standards Assessment (Full)

Evaluate **every in-scope file** in the workspace against project standards. Findings must be evidence-based, severity-ranked, and focused on actionable signal.

Shared standards live in [../references/](../references/).

## Before assessing

1. Complete **Step 0 — Classify repository** (below).
2. Read [standards-sources.md](../references/standards-sources.md) to locate repo-specific docs.
3. Read applicable standards files for the classified type.
4. Skim [reference.md](../references/reference.md) for severity levels, [lint verification](../references/reference.md#lint-verification), and low-signal exclusions.
5. If the user points to a specific standards document, treat it as authoritative.

## Scope and exclusions

**In scope:** Every hand-written source, test, config, CI/CD, and docs file in the repository, subject to exclusions below.

**Enumerate all files** matching in-scope patterns. Build a complete file list before reviewing (e.g. `find`, glob, or recursive directory listing). Track progress: `reviewed N / total M`.

**Exclude** from enumeration unless the user asks otherwise (see [reference.md](../references/reference.md)).

When a finding originates from excluded paths, note it briefly or omit it unless it indicates a process failure.

## Assessment workflow

```
Assessment progress:
- [ ] Step 0: Classify repository type
- [ ] Step 1: Load standards documents
- [ ] Step 2: Map repo structure and conventions
- [ ] Step 3: Enumerate and review every in-scope file
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

### Step 2 — Map structure

Identify entry points, module boundaries, test layout, config files, and documentation surfaces.

### Step 3 — Enumerate and review every in-scope file

**This is a full assessment — do not sample.**

1. **Build the file list** — Recursively list all files under the repo root (or scoped package). Apply exclusions from [reference.md](../references/reference.md). Record total count.
2. **Review systematically** — Work directory by directory. Read each in-scope file and evaluate against loaded standards.
3. **Track coverage** — Report `files reviewed / files in scope` and **Coverage** (`complete` or `partial`) in the final output. Do not skip directories without noting them.
4. **Co-located tests** — When reviewing a component, handler, or module, check for a paired test file in the same pass **only if** Step 1 loaded a requirement for it — from applicable `standards-*.md` rules (e.g. **FE-001**, **BE-004**) or repo **README** / docs per [standards-sources.md](../references/standards-sources.md). Some repos require co-located tests; others do not. Do not flag missing paired tests when loaded standards and repo docs are silent on co-location.
5. **Context-limit fallback (partial coverage only)** — If context limits prevent reading every in-scope file, this is **not** a true full assessment and weakens the "do not sample" guarantee. Still **enumerate** the complete file list (`M` total). Review as many files as possible in priority order (`src/`, tests, config, CI before assets). Set report **Coverage** to `partial`, surface limitations prominently in **Coverage limitations** (see output template), and do not imply repo-wide certainty for unreviewed paths.

### Step 4 — Run lint and evaluate dimensions

**Lint:** Follow [Lint verification](../references/reference.md#lint-verification).

| Dimension             | What to check                                                           |
| --------------------- | ----------------------------------------------------------------------- |
| Maintainability       | Complexity, duplication, coupling, naming, file size, dead code         |
| Testing               | Co-located tests, mock vs integration boundaries, e2e/workflow coverage |
| Security              | Secrets, auth, injection, unsafe APIs, dependency risk                  |
| Documentation         | README accuracy, setup guides, inline docs for non-obvious logic        |
| Configuration hygiene | Lint/format/CI consistency, env handling, build and deploy config       |

Apply only rules from loaded standards files. Cite file paths, line ranges, and **rule IDs** (`GEN-###`, `BE-###`, `FE-###`). For repo-only conventions not in `standards-*.md`, cite **`README`** with the section name.

### Step 5 — Rank findings

Assign severity using [reference.md](../references/reference.md). Sort by severity within each section.

### Step 6 — Report

Use the output template below. For the **Lint errors** section, use the [Lint errors output template](../references/reference.md#lint-errors-output-template).

## Output template

```markdown
# Codebase Standards Assessment (Full) — [project name]

**Repository type:** [frontend | backend | full-stack | unclear] — [confidence: high/medium/low]
**Assessment mode:** Full enumeration
**Coverage:** [complete | partial — context limits]
**Files reviewed:** [N] / [M] in scope
**Standards reviewed:** [list repo docs + skill standards files read]
**Scope:** Entire repository [or package path]; exclusions noted
**Date:** [today]

## Executive summary

[2–4 sentences: overall health, top 3 risks, strongest areas. **If Coverage is `partial`, state that explicitly in the first sentence** — e.g. "Partial assessment (N/M files reviewed due to context limits)."]

## Coverage limitations

_Include this section when **Coverage** is `partial`. Omit when **Coverage** is `complete`._

**Reason:** [e.g. context limits prevented reading all in-scope files]

**Unreviewed files / directories:** [enumerated list, or summary grouped by path — must account for every file not in the reviewed count]

**Review priority applied:** [e.g. completed `src/`, tests, config, CI; deferred assets / vendored paths]

**Impact on findings:** Findings reflect reviewed files only. Do not treat unreviewed areas as compliant or debt-free.

---

## Code quality and maintainability

| Severity | Layer | Finding | Evidence    | Rule     |
| -------- | ----- | ------- | ----------- | -------- |
| ...      | ...   | ...     | `path:line` | `BE-009` |

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

_[Use Lint errors output template from reference.md]_

---

## Recommended improvements

### P0 — Critical

1. **[BE-009]** … — Effort: S/M/L — Rationale — Action

### P1 — High

1. ...

### P2 — Medium

1. ...

### P3 — Low / informational

1. ...

---

## Assumptions and limitations

[Monorepo packages not assessed, `pnpm lint` not run or incomplete. When **Coverage** is `partial`, do not repeat the unreviewed-file list here — reference **Coverage limitations** above.]
```

Omit the **Layer** column when repo type is not full-stack.

## Quality bar

- **Exhaustive:** Enumerate all in-scope files; do not substitute sampling for full coverage. When context limits force partial review, set **Coverage** to `partial` and surface gaps prominently in **Coverage limitations** — never present partial results as a complete audit.
- **Evidence-driven:** No invented files, APIs, or rules.
- **Standards-linked:** Cite rule ID (`GEN-###`, `BE-###`, `FE-###`) for skill standards; cite `README` (section) for repo-only rules; cite `engineering risk` only when no documented rule applies.
- **Type-appropriate:** Apply frontend/backend rules only for the classified type.
- **Actionable:** Recommendations must be specific enough to implement or ticket.

## Additional resources

| File                                                         | Purpose                                                    |
| ------------------------------------------------------------ | ---------------------------------------------------------- |
| [standards-sources.md](../references/standards-sources.md)   | Discover repo-specific docs                                |
| [standards-general.md](../references/standards-general.md)   | Cross-cutting rules                                        |
| [standards-frontend.md](../references/standards-frontend.md) | UI conventions                                             |
| [standards-backend.md](../references/standards-backend.md)   | API/service conventions                                    |
| [reference.md](../references/reference.md)                   | Repository classification, severity rubric, and exclusions |
