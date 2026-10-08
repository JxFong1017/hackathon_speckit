---
name: "speckit-implement"
description: "Execute the implementation plan by processing tasks.md one JIRA-tracked work unit at a time — each unit uses jira-feature-branch skill for checkout and commit. Requires a JIRA ticket before starting."
compatibility: "Requires spec-kit project structure with .specify/ directory"
metadata:
  author: "github-spec-kit"
  source: "templates/commands/implement.md"
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before implementation)**:

- Check if `.specify/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_implement` key
- If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally
- Filter out hooks where `enabled` is explicitly `false`. Treat hooks without an `enabled` field as enabled by default.
- For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
  - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
  - If the hook defines a non-empty `condition`, skip the hook and leave condition evaluation to the HookExecutor implementation
- For each executable hook, output the following based on its `optional` flag:
  - **Optional hook** (`optional: true`):

    ```
    ## Extension Hooks

    **Optional Pre-Hook**: {extension}
    Command: `/{command}`
    Description: {description}

    Prompt: {prompt}
    To execute: `/{command}`
    ```

  - **Mandatory hook** (`optional: false`):

    ```
    ## Extension Hooks

    **Automatic Pre-Hook**: {extension}
    Executing: `/{command}`
    EXECUTE_COMMAND: {command}

    Wait for the result of the hook command before proceeding to the Outline.
    ```

- If no hooks are registered or `.specify/extensions.yml` does not exist, skip silently

## Outline

1. Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Check checklists status** (if FEATURE_DIR/checklists/ exists):
   - Scan all checklist files in the checklists/ directory
   - For each checklist, count:
     - Total items: All lines matching `- [ ]` or `- [X]` or `- [x]`
     - Completed items: Lines matching `- [X]` or `- [x]`
     - Incomplete items: Lines matching `- [ ]`
   - Create a status table:

     ```text
     | Checklist | Total | Completed | Incomplete | Status |
     |-----------|-------|-----------|------------|--------|
     | ux.md     | 12    | 12        | 0          | ✓ PASS |
     | test.md   | 8     | 5         | 3          | ✗ FAIL |
     | security.md | 6   | 6         | 0          | ✓ PASS |
     ```

   - Calculate overall status:
     - **PASS**: All checklists have 0 incomplete items
     - **FAIL**: One or more checklists have incomplete items

   - **If any checklist is incomplete**:
     - Display the table with incomplete item counts
     - **STOP** and ask: "Some checklists are incomplete. Do you want to proceed with implementation anyway? (yes/no)"
     - Wait for user response before continuing
     - If user says "no" or "wait" or "stop", halt execution
     - If user says "yes" or "proceed" or "continue", proceed to step 3

   - **If all checklists are complete**:
     - Display the table showing all checklists passed
     - Automatically proceed to step 3

3. Load and analyze the implementation context:
   - **REQUIRED**: Read tasks.md for the complete task list and execution plan
   - **REQUIRED**: Read plan.md for tech stack, architecture, and file structure
   - **IF EXISTS**: Read data-model.md for entities and relationships
   - **IF EXISTS**: Read contracts/ for API specifications and test requirements
   - **IF EXISTS**: Read research.md for technical decisions and constraints
   - **IF EXISTS**: Load constitution and project context per **Project memory paths** in `.cursor/rules/specify-rules.md` — use constitution for governance constraints; use project context for codebase structure, entry points, and integration patterns; prefer Verified rows
   - **IF EXISTS**: Load architecture under the same `TARGET_REPO_ROOT` as project context (discovery order in `.cursor/rules/references/project-memory-paths.md`) — **before coding**, read it and implement in the intended directories even if they are not present yet (architecture exception to the exist-on-disk rule). Do not invent APIs/contracts/UI beyond evidence. If architecture and tree disagree on greenfield paths, follow architecture; note drift rather than inventing a third layout.
   - **IF EXISTS**: Read quickstart.md for integration scenarios

4. **Project Setup Verification**:
   - **REQUIRED**: Create/verify ignore files based on actual project setup:

   **Detection & Creation Logic**:
   - Check if the following command succeeds to determine if the repository is a git repo (create/verify .gitignore if so):

     ```sh
     git rev-parse --git-dir 2>/dev/null
     ```

   - Check if Dockerfile\* exists or Docker in plan.md → create/verify .dockerignore
   - Check if .eslintrc\* exists → create/verify .eslintignore
   - Check if eslint.config.\* exists → ensure the config's `ignores` entries cover required patterns
   - Check if .prettierrc\* exists → create/verify .prettierignore
   - Check if .npmrc or package.json exists → create/verify .npmignore (if publishing)
   - Check if terraform files (\*.tf) exist → create/verify .terraformignore
   - Check if .helmignore needed (helm charts present) → create/verify .helmignore

   **If ignore file already exists**: Verify it contains essential patterns, append missing critical patterns only
   **If ignore file missing**: Create with full pattern set for detected technology

   **Common Patterns by Technology** (from plan.md tech stack):
   - **Node.js/JavaScript/TypeScript**: `node_modules/`, `dist/`, `build/`, `*.log`, `.env*`
   - **Python**: `__pycache__/`, `*.pyc`, `.venv/`, `venv/`, `dist/`, `*.egg-info/`
   - **Java**: `target/`, `*.class`, `*.jar`, `.gradle/`, `build/`
   - **C#/.NET**: `bin/`, `obj/`, `*.user`, `*.suo`, `packages/`
   - **Go**: `*.exe`, `*.test`, `vendor/`, `*.out`
   - **Ruby**: `.bundle/`, `log/`, `tmp/`, `*.gem`, `vendor/bundle/`
   - **PHP**: `vendor/`, `*.log`, `*.cache`, `*.env`
   - **Rust**: `target/`, `debug/`, `release/`, `*.rs.bk`, `*.rlib`, `*.prof*`, `.idea/`, `*.log`, `.env*`
   - **Kotlin**: `build/`, `out/`, `.gradle/`, `.idea/`, `*.class`, `*.jar`, `*.iml`, `*.log`, `.env*`
   - **C++**: `build/`, `bin/`, `obj/`, `out/`, `*.o`, `*.so`, `*.a`, `*.exe`, `*.dll`, `.idea/`, `*.log`, `.env*`
   - **C**: `build/`, `bin/`, `obj/`, `out/`, `*.o`, `*.a`, `*.so`, `*.exe`, `*.dll`, `autom4te.cache/`, `config.status`, `config.log`, `.idea/`, `*.log`, `.env*`
   - **Swift**: `.build/`, `DerivedData/`, `*.swiftpm/`, `Packages/`
   - **R**: `.Rproj.user/`, `.Rhistory`, `.RData`, `.Ruserdata`, `*.Rproj`, `packrat/`, `renv/`
   - **Universal**: `.DS_Store`, `Thumbs.db`, `*.tmp`, `*.swp`, `.vscode/`, `.idea/`

   **Tool-Specific Patterns**:
   - **Docker**: `node_modules/`, `.git/`, `Dockerfile*`, `.dockerignore`, `*.log*`, `.env*`, `coverage/`
   - **ESLint**: `node_modules/`, `dist/`, `build/`, `coverage/`, `*.min.js`
   - **Prettier**: `node_modules/`, `dist/`, `build/`, `coverage/`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
   - **Terraform**: `.terraform/`, `*.tfstate*`, `*.tfvars`, `.terraform.lock.hcl`
   - **Kubernetes/k8s**: `*.secret.yaml`, `secrets/`, `.kube/`, `kubeconfig*`, `*.key`, `*.crt`

5. Parse tasks.md structure and extract:
   - **Task phases**: Setup, Tests, Core, Integration, Polish
   - **Task dependencies**: Sequential vs parallel execution rules
   - **Task details**: ID, description, file paths, parallel markers [P]
   - **Execution flow**: Order and dependency requirements
   - **Work units**: Ordered list of JIRA-tracked implementation units (see step 5b)

5b. **JIRA ticket resolution (mandatory before any implementation)**:

Implementation runs **one work unit at a time** — not all tasks in a single branch. Each unit gets its own branch and commit via the **`jira-feature-branch`** skill.

**Identify work units** from `tasks.md` (in execution order):

| Unit type    | Phase pattern                        | Branch short-description source              |
| ------------ | ------------------------------------ | -------------------------------------------- |
| Setup        | Phase 1                              | `setup` or first setup task keywords         |
| Foundational | Phase 2                              | `foundational` or key infrastructure keyword |
| User story   | `## Phase N: User Story M - [Title]` | kebab-case from story title (2–5 words)      |
| Polish       | Final polish / cross-cutting phase   | `polish` or dominant concern keyword         |

**Resolve JIRA ticket per unit** (first match wins):

1.  JIRA key in the phase heading or unit metadata — e.g. `[INFO-123]`, `(JIRA: INFO-123)`, `INFO-123:`
2.  JIRA key on any incomplete task line in that unit
3.  Default ticket from `$ARGUMENTS` or the user message (pattern `[A-Z][A-Z0-9]+-\d+`)
4.  **If still missing for any unit** → **STOP**. Ask the user for the JIRA ticket number(s) before proceeding. Do not checkout branches or write code until every upcoming unit has a ticket.

When asking, show the work-unit table with missing tickets and accept either one default ticket for all units or a per-unit mapping.

Record for each unit: `{ unit_id, ticket_exact, ticket_lower, branch_suffix, task_ids[] }`.

6. **Execute implementation one work unit at a time** (do **not** batch all tasks on one branch):

   For **each work unit** in order, repeat this cycle until all units are complete:

   ### 6a. Branch checkout (`jira-feature-branch`)
   - **Read** `.cursor/skills/jira-feature-branch/SKILL.md` and follow **Workflow: sync and checkout** exactly.
   - Inputs: `{ticket_exact}` and `{branch_suffix}` for the current unit.
   - Example: ticket `INFO-123`, suffix `hirer-login-widget` → branch `info-123-hirer-login-widget`.
   - Stop on sync/rebase failures; do not implement until the branch is ready.

   ### 6b. Implement tasks in this unit only
   - Run **only** incomplete tasks belonging to the current work unit.
   - **Respect dependencies**: Sequential tasks in order; parallel tasks `[P]` together when safe.
   - **Follow TDD**: Test tasks before their implementation tasks.
   - **File-based coordination**: Same-file tasks stay sequential.
   - **Validation checkpoint**: Verify unit completion before commit.
   - Do **not** start tasks from the next unit on this branch.

   ### 6c. Commit (`jira-feature-branch`)
   - **Read** `.cursor/skills/jira-feature-branch/SKILL.md` and follow **Workflow: commit with conventional format**.
   - Subject: `<type>({ticket_exact}): {brief description of this unit's change}` — derive type and description from unit title or completed tasks (`feat` for user stories, `chore` for setup/foundational/polish).
   - Stage only files changed for this unit.
   - Verify with `git log -1 --oneline` that the subject matches `<type>({ticket_exact}):`.

   ### 6d. Mark progress
   - Mark completed tasks `[X]` in `tasks.md`.
   - Report: unit name, branch, commit SHA, tasks completed.
   - Proceed to the next work unit (returns to 6a).

   **Parallel units** (different user stories): still run sequentially in this workflow unless the user explicitly requests parallel agents — each story gets its own branch/commit cycle.

7. Implementation execution rules:
   - **Setup first**: Initialize project structure, dependencies, configuration
   - **Tests before code**: If you need to write tests for contracts, entities, and integration scenarios
   - **Core development**: Implement models, services, CLI commands, endpoints
   - **Integration work**: Database connections, middleware, logging, external services
   - **Polish and validation**: Unit tests, performance optimization, documentation

8. Progress tracking and error handling:
   - Report progress after each **work unit** (branch + commit + tasks marked)
   - Report task-level detail within the current unit
   - Halt execution if any non-parallel task fails
   - For parallel tasks [P], continue with successful tasks, report failed ones
   - Provide clear error messages with context for debugging
   - Suggest next steps if implementation cannot proceed
   - **IMPORTANT** For completed tasks, mark `[X]` in `tasks.md` after the unit commit (step 6d)
   - **IMPORTANT** Never commit without the conventional `<type>(JIRA-KEY):` format — always use `jira-feature-branch` commit rules

9. Completion validation:
   - Verify all required tasks are completed
   - Check that implemented features match the original specification
   - Validate that tests pass and coverage meets requirements
   - Confirm the implementation follows the technical plan
   - Report final status with summary of completed work

Note: This command assumes a complete task breakdown exists in tasks.md. If tasks are incomplete or missing, suggest running `/speckit-tasks` first to regenerate the task list.

10. **Check for extension hooks**: After completion validation, check if `.specify/extensions.yml` exists in the project root.
    - If it exists, read it and look for entries under the `hooks.after_implement` key
    - If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally
    - Filter out hooks where `enabled` is explicitly `false`. Treat hooks without an `enabled` field as enabled by default.
    - For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
      - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
      - If the hook defines a non-empty `condition`, skip the hook and leave condition evaluation to the HookExecutor implementation
    - For each executable hook, output the following based on its `optional` flag:
      - **Optional hook** (`optional: true`):

        ```
        ## Extension Hooks

        **Optional Hook**: {extension}
        Command: `/{command}`
        Description: {description}

        Prompt: {prompt}
        To execute: `/{command}`
        ```

      - **Mandatory hook** (`optional: false`):

        ```
        ## Extension Hooks

        **Automatic Hook**: {extension}
        Executing: `/{command}`
        EXECUTE_COMMAND: {command}
        ```

    - If no hooks are registered or `.specify/extensions.yml` does not exist, skip silently
