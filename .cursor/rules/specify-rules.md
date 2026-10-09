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
- When the active feature's `spec.md` has a `**PRD**:` line, load that file under `docs/prd/`. Treat its Out of scope list as binding in the spec, plan, and tasks.
- For UI work, describe the intended experience in `spec.md`. Files under
  `specs/<feature>/references/design/` are optional. Do not invent layout, copy, or
  interaction states the team did not describe. If the UI is too vague to build the demo,
  add `[NEEDS CLARIFICATION: demo UI flow]` instead of guessing.
- Product analytics and production rollout are optional. Record how someone can tell the
  demo path worked, and what the user sees when it fails.
- Resolve `FEATURE_DIR` with `bash .specify/scripts/bash/check-prerequisites.sh` (use flags the skill requires, e.g. `--require-spec`, `--paths-only`).
- **Project memory paths** (resolve before reading; this template is one repo):
  - **Constitution** — `<SPECKIT_PROJECT_ROOT>/.specify/memory/constitution.md`
    - Resolve `SPECKIT_PROJECT_ROOT` from the command's prerequisite/setup script (repo where `specs/` and the active feature live). For this template that is this repository.
    - Do **not** read from an unrelated sibling repo in the workspace.
  - **Project context** — `<TARGET_REPO_ROOT>/.specify/memory/project-context.md`
    - Resolve `TARGET_REPO_ROOT` as the codebase where implementation will land. Default is this repo.
    - When specs and application code live in the same repo, `TARGET_REPO_ROOT` equals `SPECKIT_PROJECT_ROOT`.
    - Do **not** read from an unrelated sibling repo in the workspace.
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
