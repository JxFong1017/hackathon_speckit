---
name: speckit-project-context-triage
description: Triage project-context.md freshness for target codebase repos on Spec Kit hook events
compatibility: Requires spec-kit project structure with .specify/ directory
metadata:
  author: flex-hiring-and-adjacencies
  source: project-context:commands/speckit.project-context.triage.md
---

# Project Context Triage

Run fingerprint-based triage for `project-context.md` in **target codebase repo(s)**. Warns only — does not auto-regenerate context.

## User Input

```text
$ARGUMENTS
```

Optional: `--target PATH` to override the configured target codebase. The hook event name is inferred from context when invoked as a pre-hook (e.g. `before_specify`).

## Path resolution

Follow **Project memory paths** in `.cursor/rules/specify-rules.md`:

See `.cursor/rules/references/project-memory-paths.md` for multi-root workspace examples.

## Execution

1. Determine hook event from context (e.g. `before_plan`) or from `$ARGUMENTS`
2. Run:

```bash
.specify/extensions/project-context/scripts/bash/run-project-context-triage-hook.sh <event_name> --json [--target PATH]
```

3. Parse JSON: `ACTION`, `TARGETS`, `SKIPPED`
4. If `ACTION` is `full_regen`, suggest `/speckit-project-context` for the stale codebase
5. Do not block the parent Spec Kit command — triage is advisory

## Configuration

`.specify/extensions/project-context/project-context-config.yml` — `targets` list and `triage_hooks` per event.

Full command reference: [`../../../../.specify/extensions/project-context/commands/speckit.project-context.triage.md`](../../../../.specify/extensions/project-context/commands/speckit.project-context.triage.md)

Main scan/regen skill: [`../speckit-project-context/SKILL.md`](../speckit-project-context/SKILL.md)
