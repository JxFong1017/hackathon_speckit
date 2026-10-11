# Research: Transfer talent contracts

## No existing app layout

- **Decision**: Put the demo in a new `app/` directory at the repository root.
- **Rationale**: This checkout has no `package.json`, no `src/`, no `.specify/memory/project-context.md`, and no `docs/architecture.md`. The spec says the demo lives in this repository. `app/` keeps the Spec Kit toolkit separate from the page a person runs.
- **Alternatives considered**: Adding the page beside `.cursor/` and `.specify/` at the root. That mixes the toolkit with the demo.

## One local page, no second runtime

- **Decision**: One statically rendered web page. Offer state stays in memory for the browser session. There is no API server and no database.
- **Rationale**: The P1 path is one signed-in employer choosing another and both seeing one offer. A second service is not required for that path.
- **Alternatives considered**: A separate backend that stores the offer. It would be a second runtime for the same path, which the constitution rejects.

## Stack

- **Decision**: TypeScript on Node.js 24.16 or newer, React, `braid-design-system` with the `seekJobs` theme, and Sku as the one way to build, run, and test. Run from `app/` with `sku start`. Test with `sku test`. Sku 16.4 does not start on Node.js 20.
- **Rationale**: The PRD and spec already choose low-fidelity SEEK branding and SEEK Braid. On the web, Braid is React components and the `seekJobs` theme. Sku is the SEEK build tool for a Braid page (`clientEntry` and `renderEntry`, static `sku start`). This version does not configure sites, languages, SSR, Vocab, Melways, or a deploy step.
- **Alternatives considered**: A single HTML file with no design system. It cannot host Braid components, so it misses the branding decision already in the PRD. A Vite app beside Sku was also set aside: Sku is the one toolchain for this page, including tests.

## Sign-in for the demo

- **Decision**: Sign-in is choosing one of three fake employers on the page. The choice is kept in memory. An unsigned visitor sees no offer. A signed-in employer sees the offer only when their id is the offering employer or the chosen receiving employer.
- **Rationale**: RFC008 (Application Authentication, ADOPTED) requires a caller to be authenticated and access to be limited to the parties. The demo uses fake employers and no passwords, tokens, or committed secrets. It is not a production authenticator.
- **Alternatives considered**: A public page with the offer visible to anyone. That breaks the spec and RFC008.

## What the offer shows

- **Decision**: The offer region shows the fake contract label and the status `Offered`. Employer names appear on the sign-in list and on the choice list. They do not appear on the offer.
- **Rationale**: Clarification on 2026-10-12.
- **Alternatives considered**: Showing both employer names on the offer. The clarification rejected that.

## A second attempt and a failed attempt

- **Decision**: The first successful offer for the one contract is kept. Another attempt, with the same receiving employer or a different one, leaves that offer as it is and shows that a second offer was not created. Submitting the offer action with no receiving employer selected is the failure: the page shows that it was not offered, and no offer is stored.
- **Rationale**: The spec requires both outcomes and does not add another screen. An empty choice is the failure a person can cause on the same action.
- **Alternatives considered**: A separate control that simulates a server error. That would be a screen the spec does not describe.
