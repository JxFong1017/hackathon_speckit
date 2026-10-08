---
name: jira-feature-branch
description: Create or switch to a JIRA-ticket feature branch synced with the default branch, and format commits using Conventional Commits with the JIRA key as scope. Use when the user mentions a JIRA ticket, wants to start work on a ticket, create a feature branch from a ticket, commit changes with a JIRA ticket number, or when speckit-implement starts a new work unit.
compatibility: "Requires spec-kit project structure with .specify/ directory"
metadata:
  author: "flex-hiring-and-adjacencies"
---

# JIRA Feature Branch

Create or switch to a feature branch named after a JIRA ticket, keep it synced with the default branch, and format commits using [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) with the JIRA key as scope (same convention as `speckit-git-commit`).

## Naming conventions

| Artifact       | Format                                             | Example                                  |
| -------------- | -------------------------------------------------- | ---------------------------------------- |
| Branch         | `<ticket-lowercase>-<short-description>`           | `info-123-hirer-login-widget`            |
| Commit subject | `<type>(<exact-ticket>): <imperative description>` | `feat(INFO-123): add hirer login widget` |

**Branch rules**

- Ticket: full JIRA key lowercased (`INFO-123` → `info-123`)
- Description: 2–5 words, kebab-case, lowercase, no special characters
- Do not include the ticket prefix twice (not `info-123-info-123-widget`)

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

### Type selection

| Change kind                            | Suggested type    | Example                                          |
| -------------------------------------- | ----------------- | ------------------------------------------------ |
| New feature or user-facing behaviour   | `feat`            | `feat(INFO-123): add signal capture form`        |
| Bug fix                                | `fix`             | `fix(INFO-123): correct form validation`         |
| Spec, plan, tasks, checklist, analysis | `docs` or `chore` | `docs(INFO-123): add specification`              |
| Refactor, deps, tooling, save progress | `chore`           | `chore(INFO-123): save progress before planning` |

Use lowercase, imperative mood for the description (e.g. `add specification`, not `Added specification`).

When invoked from `/speckit-implement`, prefer `feat` for user-story implementation and `chore` for setup, foundational, or polish-only work.

## User input

Parse from `$ARGUMENTS` or the user message:

1. **JIRA ticket** — e.g. `INFO-123`, `info-123`, or a JIRA URL containing the key
2. **Short description** — kebab-case phrase for the branch; derive from feature name if omitted

If either is missing, ask before proceeding.

## Prerequisites

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

If not a git repo, warn and stop.

Detect the default branch (use in order):

```bash
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
```

If empty, try `main`, then `master`.

## Workflow: sync and checkout

Run sequentially. Stop on hard failures; report clearly.

### 1. Fetch latest

```bash
git fetch origin
```

Requires network; request permissions if the sandbox blocks it.

### 2. Handle uncommitted changes

```bash
git status --porcelain
```

If dirty:

- **Stash** only when the user asked to stash or sync is impossible otherwise
- Otherwise **stop** and tell the user to commit, stash, or discard before continuing

### 3. Sync default branch

```bash
git checkout <default-branch>
git pull --ff-only origin <default-branch>
```

Use `--ff-only` so a diverged local base branch fails loudly instead of creating merge commits silently.

If pull fails (non-FF), stop and ask the user to reset or rebase their local default branch.

### 4. Create or switch feature branch

Build the branch name:

```
<branch> = $(echo "<TICKET>" | tr '[:upper:]' '[:lower:]')-<short-description>
```

```bash
git rev-parse --verify "<branch>" 2>/dev/null
```

- **Exists locally or on origin** → `git checkout "<branch>"`, then rebase onto synced default:

  ```bash
  git checkout "<branch>"
  git rebase origin/<default-branch>
  ```

- **Does not exist** → create from synced default:

  ```bash
  git checkout -b "<branch>"
  ```

If rebase conflicts, stop and instruct the user to resolve before continuing.

### 5. Confirm

Report:

- Default branch synced to (commit SHA or “already up to date”)
- Current branch name
- Expected commit format: `<type>(<EXACT-TICKET>): <imperative description>`

## Workflow: commit with conventional format

Use when committing on a JIRA feature branch or when the user supplies a ticket for a commit.

### 1. Validate branch (optional but recommended)

Current branch should start with the lowercased ticket key:

```bash
git rev-parse --abbrev-ref HEAD
# expect: info-123-*
```

If the branch does not match but the user gave an explicit ticket, use that ticket for the scope.

### 2. Stage and commit

Follow the repo’s git safety rules (no `--no-verify`, no amend unless allowed).

**Subject line:**

```
<type>(<EXACT-TICKET>): <imperative description of the change>
```

Examples:

- `feat(INFO-123): add hirer login widget`
- `fix(INFO-123): correct validation on email field`

```bash
git add <paths>   # or git add . when appropriate
# IMPORTANT: GET HUMAN APPROVAL FOR THE COMMIT MESSAGE BEFORE COMMITTING
git commit -m "$(cat <<'EOF'
feat(INFO-123): brief description of the change

Optional body with more detail.
EOF
)"
```

Replace `INFO-123`, the type, and the description with the actual ticket, change kind, and summary.
Never commit without a human approval of the commit message.

### 3. Verify

```bash
git log -1 --oneline
```

Confirm the subject matches `<type>(<TICKET>): <description>` with the exact JIRA key in scope.

## Examples

**Start work on INFO-123 (hirer login widget):**

```
Input: INFO-123 hirer login widget
Branch: info-123-hirer-login-widget
Commit: feat(INFO-123): add hirer login widget
```

**Switch to existing branch:**

```
Input: INFO-456 payment retry
→ fetch, sync main/master, checkout info-456-payment-retry, rebase onto origin/<default>
```

## Invoked from `/speckit-implement`

When `speckit-implement` starts a work unit, it passes:

- **Ticket**: exact JIRA key for that unit (already resolved — do not ask again)
- **Short description**: kebab-case suffix derived from the unit (setup, foundational, story title, polish)

Run **sync and checkout** (6a) before coding, then **commit with conventional format** (6c) after the unit's tasks are done. One branch + one commit per work unit.

## Error handling

| Situation                              | Action                                        |
| -------------------------------------- | --------------------------------------------- |
| Not a git repo                         | Stop with warning                             |
| Uncommitted changes                    | Stop unless user approves stash               |
| `pull --ff-only` fails                 | Stop; local default branch diverged           |
| Rebase conflicts                       | Stop; user resolves, then continues           |
| Branch exists with wrong ticket prefix | Warn; do not rename without user confirmation |
| No JIRA ticket (standalone use)        | Ask before proceeding                         |
