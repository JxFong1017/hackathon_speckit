# Frontend standards

Apply when the repository is classified as **frontend** or **full-stack** (UI layer only for full-stack).

Load [standards-general.md](standards-general.md) in addition to this file.

## Rule identifiers

Each assessable rule has an **ID** used in assessment reports:

| Prefix | File |
| ------ | ---- |
| `FE-` | This file (`standards-frontend.md`) |

Also apply `GEN-` rules from [standards-general.md](standards-general.md). Violations against conventions documented only in the repo **README** or other repo docs (not listed in `standards-*.md`) are cited as **`README`** with the section name — no skill rule ID.

---

## Unit and component testing

| ID | Rule                                                                            | Verify                                                                                                                                                                                                                                                                                                                            |
| -- | ------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FE-001 | **SHOULD** — Every component and page has a co-located unit test                | Under `src/`, pair each `*.tsx` component/page (exclude `*.test.*`, `*.spec.*`, entry-point `index.tsx`) with `*.test.ts(x)` or `*.spec.ts(x)`. Check repo test README for helpers (e.g. `renderWithProviders`). **Exclude Icon components** under `src/components/Icons/` (static SVG/markup only; no co-located test required). |
| FE-002 | **SHOULD** — Dependencies imported by a component/page are mocked in unit tests | Child modules and hooks should be mocked; do not exercise full integration stacks in the unit runner.                                                                                                                                                                                                                             |
| FE-003 | **SHOULD** — Multi-module UI integration is covered by e2e, not unit tests      | Tests wiring many real modules together belong in e2e (Playwright, Cypress, etc.). Files named `*.integration.spec.*` are a signal to review the boundary.                                                                                                                                                                        |
| FE-004 | **SHOULD** — Component tests use shared render helpers                          | Use repo test utilities (e.g. `renderWithProviders` from `src/test/testing-library`) instead redefining a new render utlity function. Rely on global mocks configured in `src/test/setup.ts` (e.g. `@seek/hubble`, `@vocab/react`).                                                                                               |

---

## Analytics and Hubble tracking

Skip when the repo does not use `@seek/hubble` / Hubble tracking.

| ID | Rule                                                                            | Verify                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| -- | ------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FE-005 | **MUST** — Mount/display Hubble events use `useTrackOnMount`                    | When a component sends a Hubble event on mount (typically `component_displayed` in a `useEffect` on first render), it **MUST** use the repo's `useTrackOnMount` hook — not ad-hoc `useEffect` + `useHubbleTracking`, and not calling `trackEvent('component_displayed', …)` directly on mount. The hook waits for `useAccountContext()` so login attributes are present. Flag violations in components and custom hooks that fire display events at mount time. |
| FE-006 | **SHOULD** — User-action and post-mount events use `useHubbleTracking` directly | Events tied to clicks, form submission, validation errors, or other non-mount lifecycle may call `useHubbleTracking()`. Do not require `useTrackOnMount` for these.                                                                                                                                                                                                                                                                                             |

---

## File and directory layout (UI)

| ID | Rule                                                   | Verify                                                                                                                                   |
| -- | ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| FE-007 | **SHOULD** — Pages under `src/pages/`                  | Page-specific components live under the page, e.g. `src/pages/NewLandingPage/components/`.                                               |
| FE-008 | **SHOULD** — Shared components under `src/components/` | e.g. `src/components/LocationAutosuggest/`, `src/components/Icons/`. Flag reusable UI placed at `src/` root or under a page when shared. |
| FE-009 | **SHOULD** — App shell under `src/App/`                | Root application wiring (providers, routes).                                                                                             |
| FE-010 | **SHOULD** — Client/API modules under `src/modules/`   | e.g. `ApiClient/`, `Hubble/`, `Datadog/`, `FeaturesAndExperimentsManager/`.                                                              |
| FE-011 | **SHOULD** — Shared constants under `src/constants/`   | e.g. `routes.ts`, `defaults.ts`, `urls.ts` — not scattered magic strings.                                                                |
| FE-012 | **SHOULD** — Shared types under `src/types/`           | e.g. `app.ts`, `signalCapture.ts`.                                                                                                       |
| FE-013 | **SHOULD** — Layouts under `src/layouts/`              | e.g. `src/layouts/MainLayout/`.                                                                                                          |
| FE-014 | **SHOULD** — Hooks under `src/hooks/`                  | All shared and feature hooks, e.g. `useSiteContext.tsx`, `useHubbleTracking.ts`.                                                         |
| FE-015 | **SHOULD** — Utilities under `src/utils/`              | Pure helpers; domain logic belongs in modules or hooks. Subdirectories OK for domains, e.g. `src/utils/signalCapture/`.                  |
| FE-016 | **SHOULD** — Static images under `src/img/`            | e.g. `src/img/banner.png`, `src/img/otherIndustryDialog/`.                                                                               |
| FE-017 | **SHOULD** — Test utilities under `src/test/`          | Global setup in `src/test/setup.ts`; helpers in `src/test/testing-library/`; fixtures in `src/test/__fixtures__/`.                       |

**Naming under `src/` (when README is silent):**

| ID | Rule                                                                         | Verify                                                          |
| -- | ---------------------------------------------------------------------------- | --------------------------------------------------------------- |
| FE-018 | **SHOULD** — `camelCase` for non-component files and directories             | e.g. `getVisitorId.ts`, `hooks/useSiteContext.tsx`              |
| FE-019 | **SHOULD** — `PascalCase` for React components, pages, and their directories | e.g. `components/LocationAutosuggest/`, `pages/NewLandingPage/` |

---

## Design system and styling (React + Braid repos)

Skip this section if the repo does not use Braid or a comparable design system.

| ID | Rule                                                                                  | Verify                                                                                                                                                                                                                                                  |
| -- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FE-020 | **SHOULD** — Style design-system components via provided props                        | Prefer Braid layout, spacing, and typography props over custom CSS when Braid supports the need. Vanilla Extract (`.css.ts`) is acceptable when the design system does not cover the case.                                                              |
| FE-021 | **SHOULD** — Prefer responsive CSS/layout over conditional UI by breakpoint           | Use responsive props (e.g. Braid `Stack` `space`, `Columns` collapse) or CSS before rendering different component trees per breakpoint. Flag `useResponsiveValue` / breakpoint checks that swap entire subtrees when a layout-only approach would work. |
| FE-022 | **SHOULD** — Custom styles via Vanilla Extract (`.css.ts`) when Braid is insufficient | Co-locate `.css.ts` with the component; do not add ad-hoc global CSS.                                                                                                                                                                                   |

---

## Form management and validation

Skip when the repo has no user-facing forms.

| ID | Rule                                                         | Verify                                                                                                                                                                                                                                                         |
| -- | ------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FE-023 | **SHOULD** — Form state managed with `react-hook-form`       | Use `useForm` (and `Controller` for design-system or custom inputs) from `react-hook-form`. Flag ad-hoc `useState` per field or hand-rolled form state when this stack is available in the repo.                                                               |
| FE-024 | **SHOULD** — Validation with `zod` and `@hookform/resolvers` | Define schemas with `zod`; wire validation via `zodResolver(schema)` from `@hookform/resolvers/zod` passed to `useForm({ resolver: … })`. Flag manual validation in submit handlers, inline field checks, or custom error state when a zod schema would apply. |
| FE-025 | **SHOULD** — Submit handling via `handleSubmit`              | Use `handleSubmit` from `react-hook-form` for form submission; read validated values from the handler callback or `getValues()` after validation.                                                                                                              |

---

## GraphQL client (when present)

| ID | Rule                                                                                   | Verify                                                                                                   |
| -- | -------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| FE-026 | **SHOULD** — Queries and mutations defined as `.gql` files under the API client module | e.g. `src/modules/ApiClient/queries/*.gql`.                                                              |
| FE-027 | **SHOULD** — Regenerate types after adding or changing `.gql` files                    | Run `pnpm codegen` or `pnpm codegen:local` per `docs/graphql-setup.md`.                                  |
| FE-028 | **SHOULD** — Consume generated documents from the codegen output                       | Import `*Document` from `src/graphql/graphql`; do not hand-write query strings.                          |
| FE-029 | **SHOULD NOT** — Manually edit generated GraphQL output                                | `src/graphql/gql.ts`, `src/graphql/graphql.ts` — flag manual edits; exclude from style review otherwise. |

---

## Internationalization (Vocab)

Skip when the repo does not use Vocab.

| ID | Rule                                               | Verify                                                                                                   |
| -- | -------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| FE-030 | **SHOULD** — User-facing copy via `@vocab/react`   | Use `useTranslations` with a page-level `translations` object; avoid hardcoded UI strings in components. |
| FE-031 | **SHOULD** — Translations co-located with the page | e.g. `src/pages/NewLandingPage/.vocab/translations.json`.                                                |

---

## External references (frontend)

| Source                                                   | Focus                         |
| -------------------------------------------------------- | ----------------------------- |
| [SKU](https://github.com/seek-oss/sku)                   | SEEK frontend build toolchain |
| [Braid](https://github.com/seek-oss/braid-design-system) | Design system usage           |
