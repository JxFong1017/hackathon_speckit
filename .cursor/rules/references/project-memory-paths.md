# Project Memory Paths

Canonical path resolution for constitution / project context / roots lives in `.cursor/rules/specify-rules.md` (**Project memory paths**). This file holds multi-root examples and the **architecture discovery order**.

## Multi-root workspace

One workspace may contain a Spec Kit project (e.g. **sidekicker-cta** — `specs/`, constitution) and separate codebases (e.g. **sidekicker-ui**, **sidekicker-api** — each with its own `project-context.md` and optional architecture docs).

| Memory file | Always resolve from | Example path |
| ----------- | ------------------- | ------------ |
| **Constitution** | The Spec Kit project using the toolkit | `sidekicker-cta/.specify/memory/constitution.md` |
| **Project context** | The codebase where implementation lives | `sidekicker-ui/.specify/memory/project-context.md` or `sidekicker-api/.specify/memory/project-context.md` |
| **Architecture** | Same codebase as project context (`TARGET_REPO_ROOT`) | `docs/architecture.md` or root `README.md` (Architecture section) — e.g. `sidekicker-api/docs/architecture.md` or `sidekicker-ui/README.md` |

Pick the correct codebase from feature scope (UI vs API). When specs and code share one repo, all three are under that repo. Never load architecture from the spec hub or toolkit when implementation targets a sibling codebase.

## Resolving roots

| Variable | Source |
| -------- | ------ |
| `SPECKIT_PROJECT_ROOT` | Repo where `specs/` and the active feature live |
| `TARGET_REPO_ROOT` | Codebase repo for `project-context.md` and architecture docs |

## Architecture discovery

Stop at the first usable source under `TARGET_REPO_ROOT` (generic; works for backend and frontend):

1. `docs/architecture.md` — e.g. `sidekicker-api/docs/architecture.md`
2. Usable markdown under `docs/architecture/` — e.g. `sidekicker-ui/docs/architecture/overview.md`
3. Explicit **Architecture** section in root `README.md`

If none exist, skip — do not invent architecture. If more than one source exists and they conflict, warn and prefer the highest-priority usable source.
