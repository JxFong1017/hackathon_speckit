# Backend standards

Apply when the repository is classified as **backend** or **full-stack** (API/service layer only for full-stack).

Load [standards-general.md](standards-general.md) in addition to this file.

## Rule identifiers

Each assessable rule has an **ID** used in assessment reports:

| Prefix | File                               |
| ------ | ---------------------------------- |
| `BE-`  | This file (`standards-backend.md`) |

Also apply `GEN-` rules from [standards-general.md](standards-general.md). Violations against conventions documented only in the repo **README** or other repo docs (not listed in `standards-*.md`) are cited as **`README`** with the section name — no skill rule ID.

---

## Layering and structure

| ID     | Rule                                                           | Verify                                                                                                                                                                                                                                         |
| ------ | -------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| BE-001 | **SHOULD** — Clear separation of concerns                      | Handlers/controllers, domain/services, and data access (repositories, clients) should not be tightly coupled. Flag business logic embedded directly in HTTP handlers or Lambda entry points when a service layer exists elsewhere in the repo. |
| BE-002 | **SHOULD** — Files live in directories that match their role   | e.g. `handlers/`, `services/`, `repositories/`, `lambdas/`, `cmd/`, `internal/`. Follow repo README or dominant layout.                                                                                                                        |
| BE-003 | **SHOULD** — Configuration and secrets loaded from environment | No hardcoded credentials, API keys, or environment-specific URLs in source. Check for `.env.example` or documented env vars.                                                                                                                   |

---

## API and service testing

| ID     | Rule                                                                               | Verify                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| ------ | ---------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| BE-004 | **SHOULD** — Handlers, resolvers, and service functions have co-located unit tests | Pair `*.ts` / `*.go` / etc. implementation files with `*.test.*` or `*_test.go` (exclude generated and thin wiring). Exempt from unit test requirements: `src/config.ts`, `src/listen.ts`, `src/tracing.ts`, `src/framework/metrics.ts`, routing index files, health check HTTP handler, smoke test HTTP handler, files under `src/scripts`, files under `src/testing`, files under `src/types`, and schema files.                                                                                                                                                                                                                                                                                                                                                                                                      |
| BE-005 | **SHOULD** — External dependencies mocked in unit tests                            | Databases, HTTP clients, message queues, and cloud SDKs should be mocked or faked at unit-test boundaries.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| BE-006 | **SHOULD** — Route-specific error paths tested when present                        | When a handler contains explicit error-handling logic (`try/catch`, `ctx.throw()`, `createError.*()`, or branches that map failures to distinct status codes or response bodies), those paths should be covered by co-located tests — not only happy paths. **Exclude:** do not require per-handler sad-path tests for failures that propagate uncaught to `errorHandler` (e.g. downstream SDK/client errors, secret-fetch failures, S3 write failures, generic thrown errors) — status codes and response shape are covered by `errorHandler` tests; do not flag happy-path-only handler tests when the handler has no explicit error handling. **Exclude:** per-handler Zod schema validation failure tests — invalid-field responses are handled by `errorHandler` and covered by `errorHandler` / `zodUtils` tests. |
| BE-023 | **—** — Integration tests not required                                             | Do **not** flag absence of integration tests, `*.integration.test.*`, supertest/route-level tests, or `integration/` directories. Co-located unit tests with mocked external dependencies are sufficient per **BE-004** / **BE-005**.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |

---

## API design and security

| ID     | Rule                                                                           | Verify                                                                                                                                                                                                                                                                                            |
| ------ | ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| BE-007 | **SHOULD** — Input validated at boundaries                                     | Schema validation (Zod, Joi, OpenAPI constraints, etc.) on ingress; do not trust raw client input.                                                                                                                                                                                                |
| BE-008 | **MUST** — Koa handlers use the shared `Middleware` type                       | New route handlers must be typed with `Middleware` from `src/types/koa.ts` (pass a `Data` generic when returning a payload) so `ctx.body` conforms to the shared `ResponseBody` shape. Flag handlers typed as plain `Koa.Middleware`, `Context`, or untyped async functions.                      |
| BE-009 | **MUST** — Outgoing HTTP requests use `httpClient`                             | All outbound HTTP calls must use `httpClient` from `src/framework/httpClient/httpClient.ts`. Do not add dependencies such as `axios` or call native `fetch` directly in application code. Exempt `src/framework/httpClient/httpClient.ts` itself.                                                 |
| BE-010 | **SHOULD NOT** — Return error responses by setting `ctx.status` and `ctx.body` | For error conditions, use `ctx.throw()` or `throw createError.*()` so the error handler and request-logging middleware can record the failure (see root README, error handling — Method 3). Flag handlers that assign an error status and `{ message: '...' }` body directly instead of throwing. |
| BE-011 | **SHOULD** — Authentication and authorization enforced on protected routes     | Spot-check handlers/resolvers/middleware for auth gaps on sensitive operations. Exempt from authentication: `/health` and `/smoke` HTTP routes.                                                                                                                                                   |
| BE-012 | **SHOULD NOT** — SQL/command injection patterns                                | String-concatenated queries, unparameterized SQL, unsanitized shell execution.                                                                                                                                                                                                                    |
| BE-013 | **SHOULD** — Sensitive data not logged                                         | PII, tokens, and credentials absent from log statements.                                                                                                                                                                                                                                          |
| BE-014 | **SHOULD** — GraphQL schema documented (schema-first repos)                    | Types and fields documented; rate limiting / caching directives where applicable per repo standards.                                                                                                                                                                                              |

---

## Data and infrastructure

| ID     | Rule                                                                      | Verify                                                                                     |
| ------ | ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| BE-015 | **SHOULD** — Database migrations versioned and reversible where practical | Check `migrations/`, `db/`, or tool-specific paths; flag manual schema drift.              |
| BE-016 | **SHOULD** — Lambda/serverless handlers testable in isolation             | Mock events, env vars, and AWS SDK calls; test error handling and retries when documented. |

---

## Environment variables

When adding a new environment variable, all of the following must be updated together.

**Secrets vs secret names:** Env vars may hold **AWS Secrets Manager secret names** (e.g. `ENCRYPTION_SECRET_NAME=staging/sidekicker/encryption-secret`) or other non-sensitive configuration (bucket names, `DEPLOYMENT=local`). They must **not** hold sensitive **values** (API keys, client secrets, passwords, tokens). Fetch secret values at runtime via `getCachedSecret` / `src/framework/aws/secret-manager.ts`.

| ID     | Rule                                                    | Verify                                                                                                                                                                                                                                                                                                                                                     |
| ------ | ------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| BE-017 | **MUST** — Gantry env vars present in both dev and prod | Add the variable to `.gantry/dev.yml` and `.gantry/prod.yml` under `env:`. If the value is identical across environments, add it to `.gantry/common.yml` instead. Flag vars present in only one file.                                                                                                                                                      |
| BE-018 | **MUST** — Variable declared in application config      | Register the variable in `src/config.ts` (e.g. via `Env.string()`, `Env.oneOf()`, etc.) and expose it on the `Config` interface.                                                                                                                                                                                                                           |
| BE-019 | **MUST** — Variable added to local `.env` file          | Add a local development value to `.env` so `pnpm start` and other local workflows can load config without missing env errors. A git-tracked `.env` is acceptable when values are non-sensitive per **BE-021** / **BE-022**.                                                                                                                                |
| BE-020 | **SHOULD** — Variable available in the test environment | Add a test value to `vitest.config.ts` under `test.env` so unit and integration tests can load config without missing env errors.                                                                                                                                                                                                                          |
| BE-021 | **MUST NOT** — Sensitive secrets stored in env files    | Inspect `.env` and `.gantry/*.yml` `env:` values. Flag plain-text API keys, client secrets, passwords, tokens, and private keys (P0). **Remediation:** store the secret in AWS Secrets Manager, put only the secret **name** in env, and fetch the value at runtime via `getCachedSecret` or `getSecretAsJson` from `src/framework/aws/secret-manager.ts`. |
| BE-022 | **—** — Git-tracked `.env` without sensitive values     | Do **not** flag `.env` solely for being tracked in git (`git ls-files .env`) when contents are non-sensitive only — e.g. `DEPLOYMENT`, S3 bucket names, Secrets Manager secret **names**. Do not treat secret **names** as committed secrets.                                                                                                              |

---

## Backend-specific config and tooling

Inspect when present:

| Artifact                                        | Focus                                                        |
| ----------------------------------------------- | ------------------------------------------------------------ |
| `docs/`                                         | Service guides (kebab-case filenames)                        |
| `.gantry/common.yml` / `dev.yml` / `prod.yml`   | Deploy env injection, dev/prod parity                        |
| `src/types/koa.ts`                              | Shared `Middleware` and `ResponseBody` types                 |
| `src/middlewares/errorHandler/`                 | Centralized error handling (prefer over direct error bodies) |
| `src/framework/httpClient/`                     | Outbound HTTP client (use instead of `fetch` / `axios`)      |
| `src/framework/aws/secret-manager.ts`           | Runtime secret fetch (prefer over plain-text env secrets)    |
| `src/config.ts` / `vitest.config.ts` / `.env`   | Env var loading, local dev defaults, and test env defaults   |
| `serverless.yml` / `template.yaml` / CDK stacks | Deploy boundaries, IAM, env injection                        |
| `Dockerfile` / `docker-compose.yml`             | Runtime, health checks, secret handling                      |
| `jest.config.*` / `go test` setup               | Test presets, coverage thresholds                            |
| `openapi.yaml` / GraphQL schema                 | Contract accuracy vs implementation                          |
| `.buildkite/` / `.github/workflows/`            | CI test and deploy gates                                     |

---

## External references (backend)

| Source                 | Focus                                                       |
| ---------------------- | ----------------------------------------------------------- |
| Repo README / TechDocs | Service-specific conventions take precedence over this file |
