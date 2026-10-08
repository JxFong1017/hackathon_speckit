# Spec Kit template

Generic [Spec Kit](https://github.com/github/spec-kit) starter. Copy this repo, describe the idea, and run a short spec → plan → build loop in Cursor. The stack, domain, and extra reference material are filled in when a team uses the template.

Skills, PRD folders, and docs that Spec Kit should read are **not** part of this pass. Those get added on this repo later.

## On this page

- [Quickstart](#quickstart)
- [Workflow](#workflow)
- [Commands](#commands)
- [What this template leaves open](#what-this-template-leaves-open)
- [Git extension](#git-extension)

## Quickstart

1. Copy this repository (one repo holds both specs and code).
2. Open it in Cursor.
3. Run the [workflow](#workflow). Aim for a demoable P1 slice, then keep building if time remains.

## Workflow

Some Git steps are **hooks** listed in [`.specify/extensions.yml`](./.specify/extensions.yml).

- **Automatic hook** — Spec Kit runs the Git step without asking. Example: initialize the repo before `/speckit-constitution`, or create a feature branch before `/speckit-specify`.
- **Optional hook** — Spec Kit offers a commit; accept or skip.

```mermaid
flowchart LR
  CON["/speckit-constitution"] --> SP["/speckit-specify"]
  SP --> PL["/speckit-plan"]
  PL --> TK["/speckit-tasks"]
  TK --> IM["/speckit-implement"]
```

| Step | Command | What to produce |
| ---- | ------- | ---------------- |
| 1 | `/speckit-constitution` | Short principles: demo-first, timeboxed scope, one stack, no secrets |
| 2 | `/speckit-specify` | One feature: problem, P1 user journey, success = a demo |
| 3 | `/speckit-plan` | Stack, layout, and the smallest design that can be shown |
| 4 | `/speckit-tasks` | Ordered tasks, P1 first |
| 5 | `/speckit-implement` | Build on the feature branch. Stop after P1 and check the demo path |

Optional when the spec is fuzzy or time allows: `/speckit-clarify`, `/speckit-userstories`, `/speckit-checklist`, `/speckit-analyze`.

If requirements change after implementation has started, update the spec, then run `/speckit-implement` again with the change. Run `/speckit-analyze` when you want the spec, plan, and tasks checked against each other.

## Commands

### Default path

| Command | Purpose |
| ------- | ------- |
| `/speckit-constitution` | Create or update `.specify/memory/constitution.md` |
| `/speckit-specify` | Create or update `specs/[###-feature]/spec.md` |
| `/speckit-plan` | Produce `plan.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md` |
| `/speckit-tasks` | Generate dependency-ordered `tasks.md` |
| `/speckit-implement` | Build tasks on the current feature branch, P1 demo slice first |
| `/speckit-clarify` | Resolve underspecified areas (up to 5 questions) |
| `/speckit-userstories` | Expand `user-stories.md` from `spec.md` |
| `/speckit-checklist` | Requirements-quality checklist |
| `/speckit-analyze` | Cross-check spec, plan, and tasks |

Skill files for each command live under [`.cursor/skills/`](./.cursor/skills/).

### Present, not part of the default loop

These remain in the repo for a later customization pass. Do not block the first demo on them.

| Command | Why it is deferred |
| ------- | ------------------ |
| `/speckit-project-context` | For brownfield repos. New apps usually start empty. |
| `/speckit-spectoissue`, `/speckit-taskstoissues` | Ticket and issue export. No tracker is required to build. |
| `/speckit-update` | Syncs toolkit files only when `SPECKIT_UPDATE_REPO` points at **this** template. It does not pull another team's Spec Kit. |
| `/codebase-standards-assessment-*` | Full standards review. Use later if you want an audit. |
| `/review-uncommitted` | Optional polish of uncommitted work. |

## What this template leaves open

- No ticket is required before writing code.
- Specs and application code live in this one repository.
- UI can be described in the spec. A Figma file or screenshot folder is optional.
- Product analytics and phased production rollout are optional. Record a demo path and basic error handling instead.

## Git extension

`/speckit-git-*` covers repo init, the feature branch, validation, and optional commits. Hooks are configured in [`.specify/extensions.yml`](./.specify/extensions.yml). Details: [`.specify/extensions/git/README.md`](./.specify/extensions/git/README.md).

Project-context freshness checks are installed but **turned off**. Turn them on only if a team is extending an existing codebase. See [`.specify/extensions/project-context/README.md`](./.specify/extensions/project-context/README.md).
