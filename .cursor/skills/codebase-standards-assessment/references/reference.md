# Assessment reference

## Repository classification

Determine repo type **before** loading type-specific standards. State the classification and confidence in the report.

| Type           | Standards to apply                                                                            |
| -------------- | --------------------------------------------------------------------------------------------- |
| **frontend**   | [standards-general.md](standards-general.md) + [standards-frontend.md](standards-frontend.md) |
| **backend**    | [standards-general.md](standards-general.md) + [standards-backend.md](standards-backend.md)   |
| **full-stack** | All three — tag each finding with `frontend` or `backend` layer                               |
| **unclear**    | [standards-general.md](standards-general.md) only                                             |

**User override:** If the user specifies a type, use that type.

**Detection signals** — use multiple; README or `catalog-info.yaml` may declare the type. Repository name: use `package.json` `name`, root directory name, `catalog-info.yaml` `metadata.name`, or git remote.

| Signal              | Frontend                                           | Backend                                                     |
| ------------------- | -------------------------------------------------- | ----------------------------------------------------------- |
| `package.json` deps | `react`, `react-dom`, `sku`, `braid-design-system` | `express`, `fastify`, `koa`, `aws-lambda`, `@apollo/server` |

**Monorepo:** Classify each package separately when structure is clear. **Assess packages only** — scope enumeration and review to package directories (e.g. `packages/*`, `apps/*`). **Ignore root-level** workspace config and files (e.g. root `package.json`, `pnpm-workspace.yaml`, `turbo.json`, root CI/tooling) unless the user names a package or asks to include the root. Enumerate and assess each classified package, or scope to the package the user names.

## Severity rubric

Assign one level per finding. When in doubt, choose the higher severity if user/data/security impact is plausible.

| Level | Label         | Criteria                                                                                                           | Examples                                                                                           |
| ----- | ------------- | ------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| P0    | Critical      | Exploitable security issue, sensitive secrets in repo/config, data loss risk, broken production build/deploy       | Hardcoded API keys, plain-text passwords/tokens in `.env` or Gantry `env:` (BE-021), SQL injection |
| P1    | High          | Violates documented MUST rule, major test gap on critical path, significant maintainability debt blocking delivery | Untested auth handler, component/page with no unit test, auth bypass                               |
| P2    | Medium        | Violates SHOULD rule, moderate complexity/coupling, incomplete docs for non-trivial feature, config drift          | Inconsistent mock patterns, outdated setup doc, duplicated service logic                           |
| P3    | Low           | Minor convention drift, small readability issues, optional doc gaps                                                | Naming inconsistency, barrel re-export file, missing JSDoc on obvious helper                       |
| —     | Informational | Observation only; no change required unless optimizing                                                             | Lockfile age, optional refactor opportunity                                                        |

**Priority mapping for recommendations:**

- P0 → address immediately
- P1 → address soon
- P2 → plan into sprint
- P3 / Informational → backlog or accept

## Lint verification

Shared rules for both assessment skills. Applies **only** to output from `pnpm lint` — not to standards-based findings in other report sections.

### Running lint

When `package.json` defines a `lint` script, run `pnpm lint` from the repository root during the assessment.

- Capture the full command output.
- Non-zero exit code is expected when errors exist — still capture stdout/stderr and summarize.
- If `pnpm lint` cannot run (missing `pnpm`, no `lint` script, install failure), state this under **Assumptions and limitations** — do not invent lint findings.

### Reporting

- Summarize `pnpm lint` output in the report's **Lint errors** section — group by rule or theme with error/warning counts (e.g. "3 errors and 2 warnings; most errors involve explicit `any` use"). Do not list every lint finding on its own row.
- Include warnings when the linter emits them.
- Parse file paths and line numbers from output when present; cite representative examples per group, not every occurrence.
- Default severity: **P2** (Medium) per lint theme/group; **P1** if the error blocks CI or indicates a likely runtime bug.

**Changes assessment addendum:** When assessing only changed files, note which lint groups fall within the change set when identifiable — in the **Summary** line and via the **In change set?** column in the output template below.

### Lint errors output template

Use this block verbatim in the report (apply the changes-assessment variant when relevant).

```markdown
## Lint errors (`pnpm lint`)

**Summary:** [e.g. 3 errors and 2 warnings; most errors involve explicit `any` use — cite dominant rule(s) and affected areas]

| Theme / rule | Errors | Warnings | Notes |
| ------------ | ------ | -------- | ----- |
| ...          | ...    | ...      | representative paths or brief pattern |

Use `None — pnpm lint passed with no errors or warnings.` when clean. If the command was not run, explain why here.
```

**Changes assessment variant:** Add an **In change set?** column (`yes` / `no` / `mixed`) after **Warnings**, and mention change-set scope in the **Summary** line when identifiable:

```markdown
| Theme / rule | Errors | Warnings | In change set? | Notes |
| ------------ | ------ | -------- | -------------- | ----- |
| ...          | ...    | ...      | yes / no / mixed | representative paths or brief pattern |
```

## Low-signal paths (de-prioritize)

Do not spend review depth here unless investigating a specific incident or the user requests it.

### Always skip for style/convention review

All files included within `.gitignore`, accompanied by these additions:

```
.cursor/
.git/
.github/
.husky/
.specify/
.vscode/
*.min.js
*.min.css
```

### Generated — flag process issues only

```
**/generated/**
**/__generated__/**
**/*.generated.*
**/graphql/**          # client codegen — verify workflow, do not critique generated shape
```

If generated output is committed incorrectly (secrets, huge diffs, manual edits), report as configuration/process finding, not code style.

### Lockfiles

`pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`:

- OK: known CVE in dependency, pin missing for security patch, unexpected deprecated package
- Skip: formatting, transitive depth, version churn

### Vendored assets

Third-party bundles, font files, static copies of libraries — skip unless tampered or known vulnerable version bundled intentionally.

## Sampling guidance

Prefer breadth across dimensions over depth in a single directory unless the user scopes the assessment.

### All repository types

| Area                           | Focus                                    |
| ------------------------------ | ---------------------------------------- |
| README / docs                  | Setup accuracy, documented conventions   |
| CI (`.github/`, `.buildkite/`) | Lint, test, deploy gates                 |
| Root config                    | Manifest, lint/test config, env examples |

### Frontend

| Area                            | Focus                                                    |
| ------------------------------- | -------------------------------------------------------- |
| `src/pages/`, `src/components/` | Components + co-located `*.test.*` / `*.spec.*`          |
| `src/test/`                     | Shared test utilities vs README                          |
| `e2e/`                          | Auth setup, test isolation                               |
| Build config                    | `sku.config.ts`, `playwright.config.ts`, `vite.config.*` |

### Backend

| Area                                         | Focus                                                                            |
| -------------------------------------------- | -------------------------------------------------------------------------------- |
| `.env`, `.gantry/*/yml` `env:`               | Non-sensitive config vs plain-text secrets (BE-021, BE-022)                      |
| `handlers/`, `resolvers/`, `routes/`         | Request handling, auth, validation                                               |
| `services/`, `domain/`                       | Business logic separation                                                        |
| `repositories/`, `db/`, `migrations/`        | Data access, schema versioning                                                   |
| `lambdas/`, `cmd/`                           | Entry points, env handling, error paths                                          |
| `src/api/`, `src/utils/`, `src/middlewares/` | Co-located unit tests with mocked deps (integration tests not required — BE-023) |

### Full-stack

Run frontend and backend sampling on their respective trees. Tag findings with the layer in the report.

## Evidence format

Each finding must cite the violated rule in the **Rule** column:

| Rule value                    | When to use                                                                                                                             |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `GEN-###`, `BE-###`, `FE-###` | Violation of a rule in `standards-general.md`, `standards-backend.md`, or `standards-frontend.md`                                       |
| `README` (section name)       | Violation of a repo convention documented only in root `README.md` or other repo docs not listed in `standards-*.md` — no skill rule ID |
| `engineering risk`            | Clear risk with no matching documented rule                                                                                             |

Good:

- `` `src/pages/Foo/Foo.tsx:42` — exported component has no co-located test — **FE-001** ``
- `` `src/handlers/createUser.ts:18` — no input validation on request body — **BE-007** ``
- `` `src/middlewares/foo.ts:28` — error returned via `ctx.status` / `ctx.body` instead of throwing — **README** (error handling) ``
- `` `.env:3` — plain-text API key committed in env file — **BE-021** ``
- Handler with happy-path test only and Zod `schema.parse(ctx)` at boundary — **no finding** for missing Zod validation failure test (BE-006 exclusion)
- Handler with happy-path test only, no `try/catch` or route-specific error mapping, downstream dependency mocked to succeed (e.g. S3 write, secret fetch) — **no finding** for missing downstream-failure test (BE-006 exclusion; `errorHandler` covers bubbled errors)
- Handler with `try/catch` or `ctx.throw()` mapping a specific failure to a distinct status — flag if that branch lacks a co-located test (**BE-006**)
- Repo with unit tests only and no `*.integration.test.*` files — **no finding** (BE-023 exemption)

Avoid:

- "Some components lack tests" without paths
- Findings in `node_modules/` or minified artefacts presented as team debt
- Frontend-specific findings reported against a classified backend-only repo
- Vague rule references like "standards-frontend: unit testing" without the rule ID
