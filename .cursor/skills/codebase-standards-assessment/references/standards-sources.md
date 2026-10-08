# Discovering standards in the current repository

Before assessing code, locate **repo-specific** standards in the workspace. Repo docs override skill defaults when they conflict.

## Standard locations to check

Search for and read any that exist:

| Location                           | Typical content                                                                  |
| ---------------------------------- | -------------------------------------------------------------------------------- |
| `README.md`                        | Setup, commands, **Conventions & standards**                                     |
| `CONTRIBUTING.md`                  | Contribution workflow, review expectations                                       |
| `docs/` / `doc/`                   | Architecture, runbooks, domain guides                                            |
| `.github/pull_request_template.md` | PR checklist (tests, docs, lint)                                                 |
| `catalog-info.yaml`                | Backstage component type (service vs website)                                    |
| `package.json` scripts             | Lint, test, build entry points                                                   |
| Build config                       | `sku.config.ts`, `jest.config.*`, `playwright.config.ts`, `serverless.yml`, etc. |

Extract explicit MUST/SHOULD rules and implied conventions from these sources. Repo-only rules discovered here are cited in reports as **`README`** (with section name) — not with a skill rule ID.

## Skill standards to load (by repo type)

After classifying the repo, read the applicable `standards-*.md` files. Each assessable rule has an **ID** (`GEN-###`, `BE-###`, `FE-###`) — cite these IDs in assessment findings.

| Repo type      | Standards files                                                                                      |
| -------------- | ---------------------------------------------------------------------------------------------------- |
| **frontend**   | [standards-general.md](standards-general.md) + [standards-frontend.md](standards-frontend.md)        |
| **backend**    | [standards-general.md](standards-general.md) + [standards-backend.md](standards-backend.md)          |
| **full-stack** | All three — scope each finding to the relevant layer (UI vs API/service)                             |
| **unclear**    | [standards-general.md](standards-general.md) only; note limited type-specific coverage in the report |

## Org-level sources (SEEK)

| Source                                                                 | Focus                                              |
| ---------------------------------------------------------------------- | -------------------------------------------------- |
| SEEK org Cursor rules (if present in the developer environment)        | Evidence-driven work, verification, scoped changes |
| [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) | Commit message format                              |

## Config and tooling to inspect

Adapt to the repo's stack:

- **Node:** `package.json`, lockfile (CVE/policy only — not style review)
- **Go:** `go.mod`, `Makefile`
- **CI:** `.github/`, `.buildkite/`
- **Generated output:** flag process issues only; do not style-review generated code
