---
name: speckit-project-context
description: >-
  Scan a repository and produce a concise, structured project-context document for
  spec-driven development (SDD). Covers purpose, modules, entry points, integrations,
  data models, config, testing, and knowledge gaps. Use when the user runs
  /speckit-project-context, asks for a codebase overview for SDD, or needs reusable
  project context before /speckit-constitution or /speckit-specify.
disable-model-invocation: true
metadata:
  author: flex-hiring-and-adjacencies
  source: .specify/scripts/bash/triage-project-context.sh
---

# Speckit Project Context

Scan the target repository and write a structured **project context** artifact that downstream SDD commands can reuse as grounding input.

Uses **State → Mechanics → Action** triage: probe facts first, then branch — do not full-scan on every invocation.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider user input before proceeding (if not empty).

### Supported arguments

| Argument         | Effect                                                                 |
| ---------------- | ---------------------------------------------------------------------- |
| _(empty)_        | Triage; full scan only when stale or missing                           |
| `path/to/subdir` | Limit scan scope to that directory (must exist)                        |
| `--force`        | Skip triage; always run full discovery and rewrite                     |
| `--stdout-only`  | Run full discovery (3a-3d); print the document in chat; do not write   |
| `--dry-run`      | Run full discovery (3a-3d); report findings summary only; do not write |
| `OUTPUT=path`    | Override output file path (e.g. `OUTPUT=docs/context.md`)              |

If the user gives conflicting instructions, ask one clarifying question before scanning.

## Output path resolution

Resolve `OUTPUT_FILE` in this order:

1. `OUTPUT=` from `$ARGUMENTS` if set
2. If `.specify/` exists at repo root → `.specify/memory/project-context.md`
3. Else if `docs/` exists → `docs/project-context.md`
4. Else → `project-context.md` at repo root

`STATE_FILE` = same directory as `OUTPUT_FILE`, file name `project-context.state.json`.

Create parent directories as needed when writing.

## Workflow

Copy and track progress:

```
Project Context Progress:
- [ ] Step 1: Resolve target, output, and scan scope
- [ ] Step 1b: Existence probe (test -f)
- [ ] Step 1c: Staleness triage (triage-project-context.sh)
- [ ] Step 2: Choose action from priority table
- [ ] Step 3: Quality pass, dry-run, or stdout-only (skip 3a–3d when not full regen)
- [ ] Step 3a: Full regen — Orient
- [ ] Step 3b: Full regen — Discover
- [ ] Step 3c: Full regen — Synthesize
- [ ] Step 3d: Full regen — Validate and write
- [ ] Step 4: Write state after full regen
- [ ] Step 5: Report completion
```

### Step 1: Resolve target, output, and scan scope

1. Determine **repo root** (workspace root unless user passed a different project path).
2. Determine **scan scope**: whole repo or subdirectory from `$ARGUMENTS`. Record it in the document as **`whole repo`** or **`subdirectory: <relative-path>`** (paths relative to repo root). **Never** write absolute filesystem paths in the artifact.
3. Resolve `OUTPUT_FILE` and `STATE_FILE` (unless `--stdout-only`).

### Step 1b: Existence probe (mandatory; see `.cursor/rules/specify-rules.md`)

From repo root, after resolving `OUTPUT_FILE`:

```bash
test -f "<OUTPUT_FILE>"
```

- Exit **0** → set `PROJECT_CONTEXT_EXISTS=true` (may `Read` the file).
- Exit **1** → set `PROJECT_CONTEXT_EXISTS=false`; do **not** `Read` until after a write path creates it.

Use **only** this probe for existence — not `Read` success, glob, or git status.

### Step 1c: Staleness triage (Mechanics input)

From repo root (append `--force` when user passed `--force`):

```bash
bash .specify/scripts/bash/triage-project-context.sh --json \
  --scan-scope "<scan scope label>" \
  ${OUTPUT_FILE:+--output "<relative-or-absolute-output>"}
```

Parse JSON into:

- `ACTION` — `full_regen` or `quality_pass`
- `STRUCTURE_STALE`, `STALE_REASONS`
- `PROJECT_CONTEXT_STATE_EXISTS`
- `CURRENT_FINGERPRINT`, `STORED_FINGERPRINT`

Fingerprint signals: [../references/fingerprint-signals.md](../references/fingerprint-signals.md).

### Step 2: Choose action (priority table)

| Priority | Condition                                                                              | Action                                                    |
| -------- | -------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| 1        | `$ARGUMENTS` contains `--stdout-only`                                                  | Full discovery → print in chat; no file write; skip state |
| 2        | `$ARGUMENTS` contains `--dry-run`                                                      | Full discovery summary only; no write; skip state         |
| 3        | `ACTION=full_regen` from triage (includes `--force`, missing files, stale fingerprint) | **Full regen** — Steps Orient through Validate below      |
| 4        | `ACTION=quality_pass` and scoped refresh in `$ARGUMENTS` (subdir path, `OUTPUT=`)      | **Targeted regen** for that scope only                    |
| 5        | `ACTION=quality_pass` and empty/minimal args                                           | **Quality pass** — see below                              |
| 6        | None applicable                                                                        | ERROR — report triage JSON and ask user                   |

**Quality pass** (when priority 5):

1. `Read` existing `OUTPUT_FILE`.
2. Extract repo-relative paths from **Key Modules & Domains** (`Path(s)` column) and **Entry points** (`Location` column).
3. For each path, `test -f` or `test -d` from repo root.
4. If any **Entry points** path is missing, or any **Key Modules** path is missing → escalate to **full regen** (Steps 3a–3d and Step 4 write-state). Report `updated` after rewrite.
5. If all cited paths exist → leave document unchanged. Do **not** run full Phases 1–5 discovery.
6. Outcome: `unchanged` if all paths verified; `updated` only after escalation to full regen. Quality pass never applies partial **Stale risk** row patches.

### Step 3a: Full regen — Orient

Read [discovery-guide.md](../references/discovery-guide.md) and execute **Phase 1**.

Also read when present (do not require all):

- `README.md` (repo root and scan-scope root)
- Architecture docs under scan root using discovery order in `.cursor/rules/references/project-memory-paths.md` — surface path and short summary in Documentation & Knowledge; never invent architecture
- Primary manifest (`package.json`, `pyproject.toml`, `go.mod`, etc.)
- `.specify/memory/constitution.md` at `SPECKIT_PROJECT_ROOT` (existing governance — do not contradict; path per `.cursor/rules/specify-rules.md`)
- `.specify/init-options.json` (Spec Kit metadata)
- `catalog-info.yaml` (Backstage entity context)

### Step 3b: Full regen — Discover

Follow Phases 2–5 in [discovery-guide.md](../references/discovery-guide.md).

**Requirements**:

- Use search and targeted file reads — do not dump entire trees into context.
- Skip `node_modules/`, `.git/`, `dist/`, `build/`, `coverage/`, and large generated artifacts unless they are the only contract source.
- For monorepos: table each major package/app with path and role; trace one primary flow across the relevant package(s).
- Every non-obvious claim needs a **Confidence** value: `Verified`, `Inferred`, `Unknown`, or `Stale risk`.
- When business purpose is unclear from the repo, say so in **Confidence & Knowledge Gaps** — do not invent product marketing copy.
- For **primary users / actors** vs **owner / maintaining team**, follow [discovery-guide.md — Actors vs ownership](../references/discovery-guide.md#actors-vs-ownership).

### Step 3c: Full regen — Synthesize

Fill [output-template.md](../references/output-template.md) completely:

- Replace every `[placeholder]` with concrete content or explicit `Unknown`.
- Keep sections even when sparse (use "none found" rather than deleting headings).
- **Executive Summary** must be readable standalone in under 30 seconds.
- **Entry Points & Runtime Flow** must name real files/modules when verified.
- **SDD Reuse Notes** must list how `/speckit-constitution`, `/speckit-specify`, and `/speckit-plan` should consume this file.

### Step 3d: Full regen — Validate and write

Before writing, confirm:

| Check       | Pass criteria                                                              |
| ----------- | -------------------------------------------------------------------------- |
| Grounded    | Major claims cite paths or artifacts                                       |
| Honest gaps | At least one row in Confidence & Knowledge Gaps when anything was inferred |
| Actionable  | SDD Reuse Notes + up to 5 recommended follow-ups                           |
| Concise     | Full document typically 150–400 lines; trim repetition                     |
| No secrets  | No real secret values — only variable names and surfaces                   |
| Portable    | Scan scope uses repo-relative labels only — no absolute filesystem paths   |

Write to `OUTPUT_FILE` unless `--stdout-only` or `--dry-run`.

### Step 4: Write state (after full regen only)

After a successful full regen write, from repo root:

```bash
bash .specify/scripts/bash/triage-project-context.sh --write-state \
  --scan-scope "<scan scope label>" \
  ${OUTPUT_FILE:+--output "<OUTPUT_FILE>"}
```

Do **not** write state after quality pass or dry-run.

### Step 5: Report completion

Report:

- `OUTPUT_FILE` path (or "stdout only" / "dry run")
- `scan scope`
- **Triage**: `full_regen | quality_pass | forced | dry_run | stdout_only`
- `structure_fingerprint`: `unchanged | changed` (with `STALE_REASONS` when changed)
- Count of Verified vs Inferred vs Unknown items (approximate; full regen only)
- Top 3 knowledge gaps (full regen or dry-run)
- Suggested next SDD command:
  - No `.specify/` → suggest initializing Spec Kit, then `/speckit-constitution`
  - Has `.specify/` but no constitution → `/speckit-constitution`
  - Otherwise → `/speckit-specify` (reference this file when describing features)

**Completion probe** (when a file was written or quality pass ran):

```bash
test -f "<OUTPUT_FILE>"
```

State outcome (mandatory format per `specify-rules.md`):

`project-context.md: created | updated | unchanged (verified with test -f at start)`

Never report `unchanged` unless `PROJECT_CONTEXT_EXISTS` was true at step 1b.

## Integration with SDD pipeline

`/speckit-project-context` is **project-level** groundwork — triage on each explicit run; full scan only when stale or missing. Not part of the per-feature branch workflow.

```text
/speckit-project-context  →  /speckit-constitution  →  /speckit-specify  →  /speckit-plan  →  ...
```

`/speckit-specify`, `/speckit-plan`, `/speckit-tasks`, `/speckit-clarify`, `/speckit-analyze`, and `/speckit-implement` should load constitution and project context per **Project memory paths** in `.cursor/rules/specify-rules.md`. They also load architecture under the same `TARGET_REPO_ROOT` when present (discovery order in `.cursor/rules/references/project-memory-paths.md`). They do **not** re-run the scan. If `STRUCTURE_STALE` is known from a recent triage, note that context may be stale and suggest `/speckit-project-context`.

Optional **project-context triage hooks** (existing events only) run `speckit.project-context.triage` when enabled in `.specify/extensions.yml`. See [`.specify/extensions/project-context/README.md`](../../../../.specify/extensions/project-context/README.md). Manual triage: [../speckit-project-context-triage/SKILL.md](../speckit-project-context-triage/SKILL.md).

Full placement diagram: [../README.md](../README.md#sdd-pipeline-placement).

## Error handling

| Condition                                    | Action                                                         |
| -------------------------------------------- | -------------------------------------------------------------- |
| Scan path does not exist                     | ERROR — ask user for correct path                              |
| Empty repo / no manifests                    | ERROR - inform user that there is no scannable items           |
| User requests scan of path outside workspace | ERROR — refuse; ask user to open that project in the workspace |
| `triage-project-context.sh` fails            | ERROR — report stderr; do not guess triage outcome             |

## Clarification policy

Ask the user **only** when:

- Scan scope is ambiguous (monorepo package vs whole repo) and choice materially changes output
- User provided contradictory output path instructions
- Business context cannot be inferred and user indicated product-critical accuracy

## Additional resources

- Output structure: [../references/output-template.md](../references/output-template.md)
- Scan checklist: [../references/discovery-guide.md](../references/discovery-guide.md)
- Fingerprint / staleness: [../references/fingerprint-signals.md](../references/fingerprint-signals.md)
