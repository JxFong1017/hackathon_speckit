---
alwaysApply: true
---

<!-- SPECKIT START -->

Governance: follow constitution per **Project memory paths** below after running `/speckit-constitution`.

**Active feature**: Not set — run `/speckit-specify` to create a feature (or check `.specify/feature.json`).

For stack, commands, and structure: read the active feature's `plan.md` and `quickstart.md` under `specs/[###-feature]/` once available.

**Mandatory rules to follow**

- Do not invent architecture, APIs, contracts, or UI absent from the repo, approved contracts, or a loaded architecture doc.
- Decide only from files and directories that **exist on disk in this checkout right now**, with one exception: when an architecture doc is loaded under `TARGET_REPO_ROOT`, agents **may create** folders/files the doc calls for (intended implementation layout). Still forbid inventing APIs, contracts, or UI without evidence.
- **Architecture docs** — resolve and load under `TARGET_REPO_ROOT` when present (same root as `project-context.md`; not the spec hub or toolkit). Discovery order and path examples: [`.cursor/rules/references/project-memory-paths.md`](references/project-memory-paths.md).
  - **IF EXISTS only** — never invent architecture content.
  - **Precedence**: architecture doc = intended structure for new/changed code; existing-on-disk still governs contracts/APIs/feature artifacts.
  - **Conflicts**: if architecture doc and current tree disagree, follow architecture for greenfield paths; note drift in plan/research; do not silently invent a third layout.
- For UI/UX initiatives, features, or projects, require design evidence in
  `specs/<feature>/references/design/`; if `spec.md` lacks that reference, add a blocking
  `[NEEDS CLARIFICATION: design reference required for UI/UX work]` instead of inferring UI.
- For frontend or hirer-visible work, require an explicit Hubble tracking decision
  (`required`, `not required`, or `N/A`); if missing, add
  `[NEEDS CLARIFICATION: frontend Hubble tracking decision required]`. Backend tracking belongs
  under the feature's Observability Strategy (logs, metrics, traces, dashboards, alerts).
- Resolve `FEATURE_DIR` with `bash .specify/scripts/bash/check-prerequisites.sh` (use flags the skill requires, e.g. `--require-spec`, `--paths-only`).
- **Project memory paths** (multi-root workspace — resolve before reading):
  - **Constitution** — `<SPECKIT_PROJECT_ROOT>/.specify/memory/constitution.md`
    - Resolve `SPECKIT_PROJECT_ROOT` from the command's prerequisite/setup script (repo where `specs/` and the active feature live; e.g. `sidekicker-cta`).
    - Do **not** read from a toolkit-only or unrelated sibling repo in the workspace.
  - **Project context** — `<TARGET_REPO_ROOT>/.specify/memory/project-context.md`
    - Resolve `TARGET_REPO_ROOT` as the **application codebase** where implementation will land or is being documented (e.g. `sidekicker-ui`, `sidekicker-api`).
    - For `/speckit-specify` and `/speckit-plan` from a spec hub, `TARGET_REPO_ROOT` is usually the UI or API repo — **not** the spec hub — unless specs and code share one repo.
    - Do **not** read from a toolkit-only or unrelated sibling repo in the workspace.
    - When specs and application code live in the same repo, `TARGET_REPO_ROOT` equals `SPECKIT_PROJECT_ROOT`.
  - **Architecture** — same `TARGET_REPO_ROOT` as project context; discovery order in [`.cursor/rules/references/project-memory-paths.md`](references/project-memory-paths.md).
  - Use `test -f` (or equivalent path probe) on the resolved path before `Read` when a skill treats the file as optional (`IF EXISTS`).
  - Examples: [`.cursor/rules/references/project-memory-paths.md`](references/project-memory-paths.md)
- After the prerequisites script succeeds, run an explicit existence probe **before** choosing create vs update vs “no changes”:
  ```bash
  test -f "<FEATURE_DIR>/<artifact>"
  ```
- **`test -f` exit 0** → artifact exists; read/update/quality-pass paths are allowed.
- **`test -f` exit 1** → artifact missing; copy template / sync / **Write** is required. Do **not** `Read` that path and treat returned content as proof it exists.
- **Forbidden as existence proof**: a successful `Read`, glob/list-dir, `git status`, or matching content in `spec.md` / another file.
- **Missing toolkit reference paths**: When a path cited in a Spec Kit skill, extension, hook, command, or toolkit doc does not exist on disk (e.g. after refactor or partial sync), do **not** stop solely for that reason. Attempt to infer the intended path from naming, directory layout, sibling files, or workspace roots. If a reasonable substitute exists, use it to continue the task. **Always warn in chat**: quote the broken reference, state the inferred path and confidence, and suggest fixing the source file or running `/speckit-update`. This applies only to toolkit self-references — not to application code, feature artifacts, or approved contracts (those still follow the existence rules above). |

**Completion reports** for artifact-producing commands MUST state the probe result and outcome, e.g. `user-stories.md: created | updated | unchanged (verified with test -f at start)`. Never report “no file edits” or “quality pass only” unless `test -f` on that artifact succeeded **at the start** of the run.

<!-- SPECKIT END -->
