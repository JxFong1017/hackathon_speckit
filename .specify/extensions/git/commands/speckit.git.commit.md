---
description: "Auto-commit changes after a Spec Kit command completes"
---

# Auto-Commit Changes

Automatically stage and commit all changes after a Spec Kit command completes.

## Commit message convention

Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). When the branch relates to a JIRA ticket, use the **exact** ticket key (e.g. `INFO-123`) as the scope:

```
<type>(<JIRA-KEY>): <imperative description>
```

Examples:

- `feat(INFO-123): implement new feature`
- `chore(INFO-123): add specification`
- `docs(INFO-123): add implementation plan`
- `fix(INFO-123): correct validation on email field`

When the branch is **not** ticket-related (e.g. `001-feature-name`, `hotfix/foo`), omit the scope:

- `docs: add specification`
- `chore: save progress before planning`

### Derive JIRA scope from branch name

When the current branch starts with a JIRA-style prefix, extract it for the scope:

```bash
git rev-parse --abbrev-ref HEAD
# info-123-hirer-login-widget → INFO-123
# INFO-456-payment-retry      → INFO-456
```

Take the leading JIRA key from the branch prefix (`info-123-hirer-login-widget` → `INFO-123`). Match `^[A-Za-z]+-[0-9]+` at the start of the branch name and uppercase the project key.

### Type mapping for Spec Kit events

| Event kind                                                                                                              | Suggested type    | Example (with ticket)                            |
| ----------------------------------------------------------------------------------------------------------------------- | ----------------- | ------------------------------------------------ |
| `after_specify`, `after_clarify`, `after_plan`, `after_tasks`, `after_checklist`, `after_analyze`, `after_constitution` | `docs` or `chore` | `docs(INFO-123): add specification`              |
| `after_implement`                                                                                                       | `feat` or `chore` | `feat(INFO-123): implement user story 1`         |
| `after_taskstoissues`                                                                                                   | `chore`           | `chore(INFO-123): sync tasks to issues`          |
| `before_*` (save progress)                                                                                              | `chore`           | `chore(INFO-123): save progress before planning` |

Use lowercase, imperative mood for the description (e.g. `add specification`, not `Added specification`).

## Behavior

This command is invoked as a hook after (or before) core commands. It:

1. Determines the event name from the hook context (e.g., if invoked as an `after_specify` hook, the event is `after_specify`; if `before_plan`, the event is `before_plan`)
2. Checks `.specify/extensions/git/git-config.yml` for the `auto_commit` section
3. Looks up the specific event key to see if auto-commit is enabled
4. Falls back to `auto_commit.default` if no event-specific key exists
5. Uses the per-command `message` if configured; otherwise builds a conventional-commit default from the event (see **Default messages** below)
6. If enabled and there are uncommitted changes, runs `git add .` + `git commit`

When writing or editing `message` values in `git-config.yml`, always use the conventional-commit format above. Substitute the JIRA scope when on a ticket branch; omit scope otherwise.

## Execution

Determine the event name from the hook that triggered this command, then run the script:

- **Bash**: `.specify/extensions/git/scripts/bash/auto-commit.sh <event_name>`
- **PowerShell**: `.specify/extensions/git/scripts/powershell/auto-commit.ps1 <event_name>`

Replace `<event_name>` with the actual hook event (e.g., `after_specify`, `before_plan`, `after_implement`).

## Configuration

In `.specify/extensions/git/git-config.yml`:

```yaml
auto_commit:
  default: false # Global toggle — set true to enable for all commands
  after_specify:
    enabled: true
    message: "docs(INFO-123): add specification"
  after_plan:
    enabled: false
    message: "docs(INFO-123): add implementation plan"
  before_plan:
    enabled: false
    message: "chore(INFO-123): save progress before planning"
  after_implement:
    enabled: false
    message: "feat(INFO-123): implementation progress"
```

Replace `INFO-123` with the active ticket key, or drop the scope when not on a ticket branch (e.g. `docs: add specification`).

## Default messages

When no per-event `message` is configured, use this pattern:

1. Derive JIRA scope from the current branch (see above)
2. Pick type from the **Type mapping** table
3. Build: `<type>(<JIRA-KEY>): <event description>` or `<type>: <event description>` without scope

| Event                 | Default description              |
| --------------------- | -------------------------------- |
| `after_specify`       | add specification                |
| `after_clarify`       | clarify specification            |
| `after_plan`          | add implementation plan          |
| `after_tasks`         | add tasks                        |
| `after_implement`     | implementation progress          |
| `after_checklist`     | add checklist                    |
| `after_analyze`       | add analysis report              |
| `after_constitution`  | add project constitution         |
| `after_taskstoissues` | sync tasks to issues             |
| `before_*`            | save progress before \<command\> |

Example fallback for `after_specify` on branch `info-123-hirer-widget`: `docs(INFO-123): add specification`.

## Graceful Degradation

- If Git is not available or the current directory is not a repository: skips with a warning
- If no config file exists: skips (disabled by default)
- If no changes to commit: skips with a message
