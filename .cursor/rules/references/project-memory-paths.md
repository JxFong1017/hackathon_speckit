# Project Memory Paths

Canonical path resolution for constitution / project context / roots lives in `.cursor/rules/specify-rules.md` (**Project memory paths**). This file holds examples and the **architecture discovery order**.

## Default: one repository

The default checkout is one repo. Specs, constitution, and application code share that root.

| Memory file | Always resolve from | Example path |
| ----------- | ------------------- | ------------ |
| **Constitution** | This repo | `.specify/memory/constitution.md` |
| **Project context** | This repo, if the file exists | `.specify/memory/project-context.md` |
| **Architecture** | This repo, if a doc exists | `docs/architecture.md` or an Architecture section in `README.md` |

`SPECKIT_PROJECT_ROOT` and `TARGET_REPO_ROOT` are the same directory unless a later customization splits specs and code.

## Multi-root workspace

Use a second root only when a team deliberately keeps specs in one repo and code in another.

| Memory file | Always resolve from | Example path |
| ----------- | ------------------- | ------------ |
| **Constitution** | The repo that contains `specs/` | `my-app/.specify/memory/constitution.md` |
| **Project context** | The codebase where implementation lives | `my-app/.specify/memory/project-context.md` |
| **Architecture** | Same codebase as project context (`TARGET_REPO_ROOT`) | `docs/architecture.md` |

Never load architecture from an unrelated toolkit checkout when implementation targets this repo.

## Resolving roots

| Variable | Source |
| -------- | ------ |
| `SPECKIT_PROJECT_ROOT` | Repo where `specs/` and the active feature live |
| `TARGET_REPO_ROOT` | Codebase repo for `project-context.md` and architecture docs |

## Architecture discovery

Stop at the first usable source under `TARGET_REPO_ROOT`:

1. `docs/architecture.md`
2. Usable markdown under `docs/architecture/`
3. Explicit **Architecture** section in root `README.md`

If none exist, skip — do not invent architecture. If more than one source exists and they conflict, warn and prefer the highest-priority usable source.
