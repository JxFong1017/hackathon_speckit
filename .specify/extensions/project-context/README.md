# Project Context Triage Extension

Fingerprint-based triage for `project-context.md` on **existing** Spec Kit hook events. Warns when codebase context is missing or stale; does not auto-run full discovery.

## Overview

This extension packages the State → Mechanics triage script as a hook-friendly command. It complements `/speckit-project-context` (full scan/regen) by running lightweight checks before key SDD commands.

- **Advisory only** — hooks never block the core command
- **Target codebase repos** — resolves `TARGET_REPO_ROOT` per `.cursor/rules/specify-rules.md` (not the spec hub in multi-root workspaces)
- **Existing events only** — no new hook event types

## Scripts

| Script                                                                                | Role                                                               |
| ------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| `.specify/scripts/bash/triage-project-context.sh`                                     | Core fingerprint triage → `ACTION` (`full_regen` / `quality_pass`) |
| `.specify/extensions/project-context/scripts/bash/run-project-context-triage-hook.sh` | Hook orchestration — target repos, config, calls core triage       |

## Commands

| Command                          | Description                                                         |
| -------------------------------- | ------------------------------------------------------------------- |
| `speckit.project-context.triage` | Triage `project-context.md` freshness for configured target repo(s) |

Cursor skill: `/speckit-project-context-triage`

## Hooks

| Event                 | Command                          | Optional | Description                          |
| --------------------- | -------------------------------- | -------- | ------------------------------------ |
| `before_constitution` | `speckit.project-context.triage` | Yes      | Brownfield onboarding check          |
| `before_specify`      | `speckit.project-context.triage` | Yes      | Check context before specification   |
| `before_plan`         | `speckit.project-context.triage` | Yes      | Check context before planning        |
| `before_tasks`        | `speckit.project-context.triage` | Yes      | Check context before task generation |
| `before_implement`    | `speckit.project-context.triage` | Yes      | Check context before implementation  |

Hooks are registered in `.specify/extensions.yml` alongside other extensions (e.g. git). Each hook is `optional: true` and `enabled: true` by default in the template.

## Configuration

Configuration is stored in `.specify/extensions/project-context/project-context-config.yml`:

### Target resolution

For each entry in `targets`:

1. Absolute path (if directory exists)
2. Relative to `SPECKIT_PROJECT_ROOT`
3. Workspace sibling: `../<folder>` (parent of the Spec Kit project)

Override at runtime with `--target PATH` or `TARGET_REPO_ROOT`.

## Installation

Bundled with this template under `.specify/extensions/project-context/`. Freshness checks are off until a team lists real target repos.

## Disabling

```bash
specify extension disable project-context
```

Or set `enabled: false` on individual hooks in `.specify/extensions.yml`, or disable per-event in `project-context-config.yml`.

## Related

- Full scan/regen: `[speckit-project-context](../../../.cursor/skills/speckit-project-context/speckit-project-context/SKILL.md)`
- Hook triage skill: `[speckit-project-context-triage](../../../.cursor/skills/speckit-project-context/speckit-project-context-triage/SKILL.md)`
- Core triage: `[.specify/scripts/bash/triage-project-context.sh](../../scripts/bash/triage-project-context.sh)`
- Path rules: `[.cursor/rules/references/project-memory-paths.md](../../../.cursor/rules/references/project-memory-paths.md)`
