# General standards (all repository types)

Apply these rules to **every** assessment unless the repo README explicitly overrides them.

**Rule strength:** MUST = blocking / policy violation · SHOULD = expected convention · SHOULD NOT = avoid

For each item: confirm the rule applies, inspect the suggested locations, and cite evidence when reporting a violation.

## Rule identifiers

Each assessable rule has an **ID** used in assessment reports:

| Prefix | File                               |
| ------ | ---------------------------------- |
| `GEN-` | This file (`standards-general.md`) |

Violations against conventions documented only in the repo **README** or other repo docs (not listed in `standards-*.md`) are cited as **`README`** with the section name — no skill rule ID.

---

## Git and workflow

| ID      | Rule                                                                                                                                                  | Verify                                                                                                                                                                |
| ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GEN-001 | **MUST** — Branch names include a JIRA issue key (SEEK repos)                                                                                         | Check current branch and recent branches. Allowed exceptions when documented: `hotfix/…`, `adhoc/…`. Look for JIRA key docs in README or `docs/buildkite-scripts.md`. |
| GEN-002 | **SHOULD** — Commits use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) with JIRA ticket as scope when work is ticket-related | Sample `git log`. Expected shape: `feat(INFO-123): …`, `fix(INFO-123): …`, `chore(INFO-123): …`.                                                                      |

---

## Code quality

| ID      | Rule                                                              | Verify                                                                                                                                                                                                                                                                                                                                      |
| ------- | ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GEN-003 | **SHOULD** — Use ES6+ syntax in TypeScript/JavaScript projects    | Prefer `const`/`let`, arrow functions, modules (`import`/`export`), destructuring, template literals, and `class` where appropriate. Flag legacy patterns (`var`, function expressions where arrows suffice, CommonJS `require`/`module.exports`) in hand-written source. For other languages, follow idioms documented in the repo README. |
| GEN-004 | **SHOULD** — Apply DRY, KISS, SOLID, YAGNI where applicable       | Flag **clear** violations only: large copy-paste blocks, god modules, speculative unused code paths. Do not nitpick minor duplication.                                                                                                                                                                                                      |
| GEN-005 | **SHOULD NOT** — Dead code in the codebase                        | Unused exports, unreachable branches, commented-out blocks, unreferenced files. Exclude generated output paths documented in the repo.                                                                                                                                                                                                      |
| GEN-006 | **SHOULD NOT** — Meaningless `try`/`catch` blocks                 | Flag `catch` blocks that only rethrow the same error (`throw error`, `throw e`) or otherwise add no handling, logging, recovery, or transformation. Prefer letting the error propagate without a wrapper `try`/`catch`.                                                                                                                     |
| GEN-007 | **SHOULD NOT** — `eslint-disable` comments in hand-written source | Fix lint issues instead of suppressing. Exclude generated files (e.g. `src/graphql/`). Flag`eslint-disable-next-line` in application code unless narrowly justified.                                                                                                                                                                        |

---

## Naming conventions (hand-written source)

| ID      | Rule                                                           | Verify                                   |
| ------- | -------------------------------------------------------------- | ---------------------------------------- |
| GEN-008 | **SHOULD** — `SCREAMING_SNAKE_CASE` for constants              | e.g. `MAX_RETRIES`, `DEFAULT_TIMEOUT_MS` |
| GEN-009 | **SHOULD** — `camelCase` for variables and functions           | e.g. `getVisitorId`, `parsePayload`      |
| GEN-010 | **SHOULD** — `PascalCase` for classes and type/interface names | e.g. `UserService`, `ApiResponse`        |

**Files and directories:** follow repo README first. If silent, default to `camelCase` for modules/utilities and language-appropriate casing for entry points. Exclude root config, generated output, and vendored paths from naming audits.

**Non-production dev-only directories:** `__name__` (double underscores), e.g. `__fixtures__/`, `__mocks__/`.

---

## File and directory layout

| ID      | Rule                                                                    | Verify                                                                                                                                                                                                                                                   |
| ------- | ----------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GEN-011 | **SHOULD** — Files live in directories that match their purpose         | Flag modules placed in unrelated trees (e.g. API handler under a UI components folder). Use README or dominant repo structure as the reference layout.                                                                                                   |
| GEN-012 | **SHOULD NOT** — Barrel `index` files that only re-export other modules | Skip entry-point `index` files that **are** the module (e.g. page root `index.tsx`). **Report every** re-export-only barrel — including existing files. Severity: typically Low–Medium; raise if barrels obscure dependencies or cause circular imports. |

---

## Dependency manifest hygiene (Node/pnpm/npm repos)

| ID      | Rule                                                 | Verify                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| ------- | ---------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GEN-013 | **SHOULD NOT** — `pnpm.overrides` or npm `overrides` | Confirm field is absent unless README documents an approved exception.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| GEN-014 | **SHOULD NOT** — Unused dependencies                 | Cross-check imports across source, config, and scripts — but **do not** flag a package as unused based on missing `import` statements alone. Before reporting, check whether it satisfies a **peer**, **optional peer**, or documented **runtime requirement** of a direct dependency (e.g. `rxjs` for `@apollo/client`). Inspect `peerDependencies` / `peerDependenciesMeta` on installed direct deps (`node_modules/<pkg>/package.json`, `pnpm why <pkg>`, or lockfile metadata). Also check README, setup docs, and bundler config for explicitly required companions. Report only when there is no import **and** no peer/doc/config justification; otherwise omit or note as informational (required peer, not directly imported). |
| GEN-015 | **SHOULD** — Dev-only packages in `devDependencies`  | Build tools, test runners, codegen, and types → `devDependencies`; runtime app code → `dependencies`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |

For non-Node repos (Go modules, Cargo, etc.), apply equivalent hygiene to the repo's manifest (`go.mod`, `Cargo.toml`, etc.).

---

## Documentation

| ID      | Rule                                                                    | Verify                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| ------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GEN-016 | **SHOULD** — All markdown documentation lives under `docs/`             | Flag `.md` files outside `docs/` (e.g. `GRAPHQL_SETUP.md`, `e2e/README.md`, `src/test/README.md`). Root `README.md` is allowed as the repo entry point only. Exclude: `.cursor` markdown files, template markdown files (e.g. `.github/pull_request_template.md`)                                                                                                                                                                                                                                                                                                         |
| GEN-017 | **SHOULD** — Doc filenames use kebab-case                               | Name markdown files under `docs/` like `http-client.md` or `graphql-setup.md`. Flag camelCase, PascalCase, snake_case, or SCREAMING_SNAKE_CASE filenames (e.g. `GRAPHQL_SETUP.md`, `httpClient.md`, `buildkite_scripts.md`).                                                                                                                                                                                                                                                                                                                                              |
| GEN-018 | **SHOULD** — READMEs and docs are up to date where applicable           | For each README or doc that describes behaviour, setup, commands, architecture, or conventions: compare claims to the current codebase and config. Flag stale commands, missing scripts, outdated paths, removed features still documented, or undocumented setup steps that are now required. Applies to root `README.md`, docs under `docs/` (e.g. `docs/test-utilities.md`, `docs/e2e.md`), and domain guides (e.g. `docs/graphql-setup.md`) when they cover live functionality. Skip docs for deprecated or unused areas unless the user scopes the assessment there. |
| GEN-019 | **SHOULD** — Root README covers setup, common commands, and conventions | Compare root README to `package.json` scripts, Makefile targets, CI config, and repo conventions.                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| GEN-020 | **SHOULD** — PR template checklist reflected in practice                | If `docs/pull-request-template.md` exists, spot-check recent changes against its testing/docs checklist.                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
