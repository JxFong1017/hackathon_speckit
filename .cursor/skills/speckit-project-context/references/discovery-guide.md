# Discovery Guide

Use this guide during repo scan. Adapt depth to repo size; prefer breadth first, then drill into hotspots.

## Phase 1 — Orientation (always)

| Signal             | Typical paths                                                                                                                             |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------- |
| Project identity   | `README.md`, `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, `build.gradle*`, `catalog-info.yaml`                    |
| Architecture docs  | Discovery order in `.cursor/rules/references/project-memory-paths.md`. Record path + short summary when found; never invent architecture. |
| Product actors     | README audience, auth config, route guards, user-facing copy in pages — **not** `catalog-info.yaml` `spec.owner`                          |
| Owning team        | `catalog-info.yaml` `spec.owner`, `deploy.config.js` `owner`, `.github/CODEOWNERS` — governance only; separate from product actors        |
| Monorepo layout    | `pnpm-workspace.yaml`, `lerna.json`, `nx.json`, `turbo.json`, `packages/`, `apps/`                                                        |
| Spec Kit           | `.specify/`, `specs/`, `.specify/memory/constitution.md`                                                                                  |
| CI/CD              | `.buildkite/`                                                                                                                             |
| Container / deploy | `Dockerfile`, `docker-compose*.yml`, `helm/`, `terraform/`, `serverless.yml`                                                              |

## Phase 2 — Entry points by stack

| Stack hint    | Entry points to find                                                                                    |
| ------------- | ------------------------------------------------------------------------------------------------------- |
| Node / TS     | `package.json` `main`/`bin`/`scripts`, `src/index.ts`, `src/main.ts`, `app/`, `pages/api/`, `server.ts` |
| Python        | `pyproject.toml` / `setup.py`, `__main__.py`, `manage.py`, `app.py`, `uvicorn`/`gunicorn` targets       |
| Go            | `cmd/*/main.go`, `main.go`                                                                              |
| Java / Kotlin | `@SpringBootApplication`, `Application.java`, `build.gradle` application plugin                         |
| Rust          | `src/main.rs`, `src/lib.rs`                                                                             |
| Frontend SPA  | `index.html`, `src/main.tsx`, `src/App.tsx`, router config                                              |
| GraphQL       | `schema.graphql`, `*.graphql`, codegen config                                                           |
| REST          | `openapi.yaml`, `swagger`, route registration files                                                     |

## Phase 3 — Integrations & data

| Concern          | Where to look                                                                                  |
| ---------------- | ---------------------------------------------------------------------------------------------- |
| Env vars         | `.env.example`, `.env.template`, `config/*.yml`, `.gantry/*.yml`, README setup sections        |
| Secrets / auth   | Gantry config `gantry.apply.yml`, OAuth config, API client setup, IAM/terraform, middleware    |
| Databases        | ORM configs, migrations (`prisma/`, `alembic/`, `db/migrate/`), connection strings in examples |
| Messaging        | Kafka/SQS/SNS client setup, consumer/producer modules                                          |
| External APIs    | HTTP clients, SDK imports, webhook handlers                                                    |
| Shared contracts | `contracts/`, `proto/`, `schemas/`, generated types                                            |

## Phase 4 — Testing

| Signal      | Paths                                                                   |
| ----------- | ----------------------------------------------------------------------- |
| Test runner | `jest.config.*`, `vitest.config.*`, `pytest.ini`, `go test` in Makefile |
| Test dirs   | `**/__tests__/`, `**/*.test.*`, `**/*.spec.*`, `tests/`, `e2e/`         |
| Commands    | `package.json` scripts, `Makefile`, `justfile`, CI workflow test steps  |

## Phase 5 — Depth budget

For repos with >50k LOC or many packages:

1. Map top-level structure and name each major package's role from README + one representative file.
2. Trace **one** primary user journey end-to-end (do not exhaust every route).
3. Sample contracts and models from canonical locations (schema dir, `types/`, `models/`).
4. Record what was **not** scanned and mark confidence accordingly.

## Evidence rules

- **Verified**: direct quote or path-backed fact from the checkout.
- **Inferred**: pattern-based conclusion (naming, folder layout) — say what triggered the inference.
- **Unknown**: no reliable signal — do not guess.
- **Stale risk**: docs contradict code or docs are old/unmaintained — cite both sides if possible.

### Actors vs ownership

**Primary users / actors** are end users who interact with the product to accomplish a business goal (e.g. hirers on a registration page). Derive them from README product copy, auth levels, route audiences, and user-facing flows — **not** from `catalog-info.yaml` `spec.owner`, `deploy.config.js` `owner`, or `CODEOWNERS`. Those identify the **maintaining team**; record them under **Owner / maintaining team** instead. Do not list developers, SREs, or internal ops as primary actors unless the repo is explicitly an internal tool they use in production workflows.

When filling **Repo Purpose & Business Context**, keep **Primary users / actors** and **Owner / maintaining team** separate. Only cite README, routes, auth, or product docs as evidence for primary actors; cite `catalog-info.yaml` / CODEOWNERS only for the owner row.

| Concept                  | Meaning                                            | Typical sources                                     | Goes in output as            |
| ------------------------ | -------------------------------------------------- | --------------------------------------------------- | ---------------------------- |
| Primary user / actor     | Person who uses the product in a business workflow | README, routes, auth levels, domain language        | **Primary users / actors**   |
| Owner / maintaining team | Group responsible for the codebase or service      | `catalog-info.yaml`, CODEOWNERS, deploy owner field | **Owner / maintaining team** |

Do not treat Backstage `spec.owner` or deploy `owner` as evidence of who uses the product.

## Commands (run when available)

Discover conventions; do not assume:

```bash
# Structure
find . -maxdepth 3 -type d ! -path '*/node_modules/*' ! -path '*/.git/*' 2>/dev/null | head -80

# Manifests
ls -la package.json pyproject.toml go.mod Cargo.toml pom.xml 2>/dev/null

# Test script (Node example)
node -e "const p=require('./package.json'); console.log(p.scripts||{})" 2>/dev/null
```

Use semantic search and targeted reads after orientation — avoid loading entire `node_modules` or generated artifacts.
