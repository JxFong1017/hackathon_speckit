# Codebase Standards Assessment

Cursor agent skills for **evidence-based codebase reviews** against documented engineering standards. Produces structured, severity-ranked reports — it does not modify code.

## Skills

| Skill       | Directory                                                                                  | When to use                                         |
| ----------- | ------------------------------------------------------------------------------------------ | --------------------------------------------------- |
| **Changes** | [`codebase-standards-assessment-changes/`](codebase-standards-assessment-changes/SKILL.md) | Pre-PR review, branch diff, staged/uncommitted work |
| **Full**    | [`codebase-standards-assessment-full/`](codebase-standards-assessment-full/SKILL.md)       | Exhaustive repo audit or health check               |

To run in Cursor, go to the chat and type `/codebase-standards-assessment-changes` or `/codebase-standards-assessment-full` depending on your use case.

### Changes vs full

|                | Changes                                 | Full                                        |
| -------------- | --------------------------------------- | ------------------------------------------- |
| **Scope**      | New/modified files only                 | Every in-scope file (enumerated)            |
| **Change set** | Uncommitted, committed vs base, or both | Entire repo (or named package in monorepos) |
| **Speed**      | Fast — ideal before merge               | Thorough — ideal for audits                 |

## How it works

1. **Classify** the repository (frontend, backend, full-stack, or unclear) from name, `package.json` deps, and `catalog-info.yaml`.
2. **Load standards** — repo docs first (see [`references/standards-sources.md`](references/standards-sources.md)), then applicable skill rules.
3. **Review** every file in scope against loaded rules.
4. **Run** `pnpm lint` when a `lint` script exists.
5. **Report** findings with severity (P0–P3), evidence (`path:line`), and rule IDs.

## Standards library

Shared references used by both skills:

| File                                                                   | Purpose                                                                            |
| ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| [`references/standards-general.md`](references/standards-general.md)   | Cross-cutting rules (`GEN-###`) — git, code quality, testing, security             |
| [`references/standards-frontend.md`](references/standards-frontend.md) | UI rules (`FE-###`) — co-located tests, mocking, Hubble, SKU/Braid                 |
| [`references/standards-backend.md`](references/standards-backend.md)   | API/service rules (`BE-###`) — layering, env/secrets, Gantry                       |
| [`references/standards-sources.md`](references/standards-sources.md)   | Where to find repo-specific conventions                                            |
| [`references/reference.md`](references/reference.md)                   | Repository classification, severity rubric, low-signal exclusions, evidence format |

Repo-specific docs (`README.md`, `CONTRIBUTING.md`, etc.) override skill defaults. Violations there are cited as **`README`** (section name), not a skill rule ID.

All standards docs are written specifically for and tested against Adjacency team's codebase (sidekicker-ui and sidekicker-api) - the same standards & practices may not be applicable on any other codebase, but can be modified according to use case.

## Report output

Assessments produce a markdown report with:

- Executive summary
- Categorized finding tables (maintainability, architecture, testing, security, config, docs, conventions)
- Lint errors from `pnpm lint`
- Prioritized recommendations (P0–P3)
- Assumptions and limitations

## Usage

### In adjacency-speckit repositories

If your project is already using the adjacency-speckit template, run `/speckit-update` to sync the skills into that repo.

To use the skill on a project in the same Cursor workspace without installing, add the project folder via **File → Add Folder to Workspace**, then in the agent chat, run the skill to target the specific project, eg: `/codebase-standards-assessment-full for sidekicker-ui`.

### In sidekicker-ui or sidekicker-api repositories

To install this skill bundle into your local sidekicker-ui or sidekicker-api projects, run the following command from the adjacency-speckit repo root:

```bash
bash .specify/scripts/bash/install-skill.sh codebase-standards-assessment /path/to/sidekicker-ui
```
