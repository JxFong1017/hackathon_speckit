---
description: "Triage project-context.md freshness for target codebase repo(s) on Spec Kit hook events"
---

# Project Context Triage

Run fingerprint-based triage for `project-context.md` in **target codebase repo(s)**. This command **warns only** — it does not auto-run full discovery or rewrite the document.

## Path resolution

Follow **Project memory paths** in `.cursor/rules/specify-rules.md` and examples in `.cursor/rules/references/project-memory-paths.md`:

| Variable               | Role                                                                            |
| ---------------------- | ------------------------------------------------------------------------------- |
| `SPECKIT_PROJECT_ROOT` | Spec Kit hub (`specs/`, constitution) — where `.specify/extensions.yml` lives   |
| `TARGET_REPO_ROOT`     | Codebase repo for `project-context.md` (e.g. `sidekicker-ui`, not the spec hub) |

Resolution order for the target codebase:

1. `--target PATH` argument (if passed)
2. `TARGET_REPO_ROOT` environment variable
3. `targets` list in `.specify/extensions/project-context/project-context-config.yml`
4. Fallback: `SPECKIT_PROJECT_ROOT` when specs and code share one repo

## Behavior

This command is invoked as a hook on **existing** Spec Kit events (`before_constitution`, `before_specify`, `before_plan`, `before_tasks`, `before_implement`).

1. Determine the event name from the hook context (e.g. `before_plan`)
2. Check `.specify/extensions/project-context/project-context-config.yml` for `triage_hooks.<event>.enabled` (falls back to `triage_hooks.default`)
3. Resolve one or more `TARGET_REPO_ROOT` paths
4. Run `.specify/scripts/bash/triage-project-context.sh --json` in each target repo
5. Report `ACTION`: `full_regen` or `quality_pass`
6. If `full_regen`, suggest running `/speckit-project-context` for the affected codebase — **do not** auto-regenerate from this hook

### Triage outcomes

| `ACTION`       | Meaning                                            | Hook behavior                                                     |
| -------------- | -------------------------------------------------- | ----------------------------------------------------------------- |
| `quality_pass` | Context exists and structure fingerprint unchanged | Continue the core command                                         |
| `full_regen`   | Missing context/state or fingerprint changed       | Warn user; suggest `/speckit-project-context` for the target repo |

## Execution

Determine the event name from the hook that triggered this command, then run:

- **Bash**: `.specify/extensions/project-context/scripts/bash/run-project-context-triage-hook.sh <event_name> [--json] [--target PATH]`

Examples:

```bash
.specify/extensions/project-context/scripts/bash/run-project-context-triage-hook.sh before_specify --json
.specify/extensions/project-context/scripts/bash/run-project-context-triage-hook.sh before_plan --target ../sidekicker-ui --json
```

When acting as a hook agent, prefer `--json` for structured output, then summarize for the user.

## Configuration

In `.specify/extensions/project-context/project-context-config.yml`:

```yaml
targets:
  - sidekicker-ui
  - sidekicker-api

triage_all_targets: true

triage_hooks:
  default: true
  before_specify:
    enabled: true
  before_plan:
    enabled: true
```

Set `enabled: false` on a specific event to skip triage for that hook. Set `triage_hooks.default: false` to disable all triage hooks unless explicitly enabled per event.

## Agent instructions

When executing as a hook:

1. Run the triage script with the hook event name and `--json`
2. Parse `ACTION` and `TARGETS` from the JSON
3. If `SKIPPED: true`, continue silently
4. If `ACTION` is `full_regen`, tell the user which codebase is stale and suggest `/speckit-project-context` scoped to that repo (e.g. `/speckit-project-context for sidekicker-ui`)
5. **Never block** the core Spec Kit command solely because context is stale — triage is advisory unless the user chooses to refresh first
