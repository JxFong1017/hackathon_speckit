# Implementation Plan: Transfer talent contracts

**Branch**: `001-transfer-talent-contracts` | **Date**: 2026-10-12 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-transfer-talent-contracts/spec.md`

## Summary

A signed-in external employer chooses one other fake employer and offers one talent contract. Both see the contract label and the status Offered. Taking the contract waits. SEEK provides the page and is not a party.

The demo is one static React page in `app/`, styled with SEEK Braid (`seekJobs`), built and run with Sku. Offer state stays in memory for the session. There is no API and no database.

The simplest alternative considered was one HTML file and a sign-in select, with no React. That cannot use Braid components, and the PRD already requires SEEK Braid.

## Technical Context

**Language/Version**: TypeScript on Node.js 24.16 or newer (Sku 16.4 requires it)
**Primary Dependencies**: React, `braid-design-system` (`seekJobs`), Sku
**Storage**: In-memory for the browser session. No database.
**Testing**: `sku test` for the offer rules (who can see the offer, a second attempt, a failed attempt)
**Target Platform**: Local browser via `sku start`
**Project Type**: One web page
**Performance Goals**: Both employers see the offer in the same browser session
**Constraints**: Fake data only. No committed secrets. No second runtime. Access only for the two employers on the offer (RFC008, ADOPTED).
**Scale/Scope**: Three fake employers, one contract, at most one offer
**Design notes** _(if UI)_: A signed-in employer chooses one receiving employer and offers one contract. Both see the same fake label and the status Offered. Employer names are not on the offer. The receiving employer cannot take it. Low fidelity, SEEK branding, SEEK Braid. Design reference path: N/A.
**Demo signal**: Both parties see `Roster cover contract` and `Offered`. A failed offer shows that it was not offered, and no offer appears.

## Constitution Check

_GATE: Must pass before Phase 0 research. Re-check after Phase 1 design._

| Gate        | Question                                                                                   | Status                                                                                                                          |
| ----------- | ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------- |
| Demo        | P1 outcome is something a person can try; no blocking `[NEEDS CLARIFICATION]` on that path | Pass                                                                                                                            |
| Timebox     | Out of scope is explicit; the plan does not depend on deferred work                        | Pass                                                                                                                            |
| Stack       | Language, runtime, and storage are chosen or marked N/A                                    | Pass. TypeScript on Node.js 24.16 or newer, in-memory storage, one command: `sku start`                                         |
| Evidence    | No invented APIs, contracts, or UI beyond the spec and files on disk                       | Pass. No architecture document was present. The UI contract repeats the spec's one page, lists, offer action, label, and status |
| Data        | Personal data is called out, or the plan says the demo uses local/fake data                | Pass. Fake employers and one fake contract label. No person name is stored                                                      |
| Demo signal | Someone can tell the P1 path worked, and what they see when it fails                       | Pass                                                                                                                            |

Post-design re-check: Pass. Research, the data model, the UI contract, and the quickstart stay inside this gate.

### Pattern and reuse

This checkout has no application source. Checked for `package.json`, `src/`, `docs/architecture.md`, and `.specify/memory/project-context.md`. None are present. The demo is new code under `app/`. Sku is the one build tool, so the page does not add Vite, a second test runner, or a server.

## Project Structure

### Documentation (this feature)

```text
specs/001-transfer-talent-contracts/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── ui.md
└── tasks.md             # /speckit-tasks, not created here
```

### Source Code (repository root)

```text
app/
├── package.json
├── sku.config.ts        # clientEntry and renderEntry only
├── src/
│   ├── client.tsx
│   ├── render.tsx       # BraidProvider, seekJobs theme, Seek Sans stylesheet
│   ├── App.tsx          # the one page
│   ├── demo-data.ts     # three employers and one contract
│   ├── offer.ts         # offer rules
│   └── offer.test.ts
└── dist/                # Sku output, not committed as source
```

**Structure Decision**: One static Sku app in `app/`. The toolkit stays at the repository root. No `backend/` and no second package.

## UI notes _(when the feature has a UI)_

- **Experience**: The page starts signed out, with the three fake employer names and a sign-in action. After sign-in, the employer sees the other employers' names and an offer action. Before an offer, they see that nothing has been offered. After a successful offer, the offering employer and the chosen receiving employer see `Roster cover contract` and `Offered`. A third employer sees no offer. Using the offer action again shows that a second offer was not created. Using it with nobody selected shows that it was not offered.
- **Design reference path**: N/A
- **States to show**: signed out, nothing offered, offer visible, not a party, second attempt, failed offer
- **Accessibility**: The offer action has a visible name and can be completed by keyboard. Use Braid controls for the lists and the action. Theme `seekJobs`.

## Demo signal

- **Success looks like**: North Ferry Co offers to Harbour Lane Pty Ltd. Both, in the same session, see `Roster cover contract` and `Offered`, with no employer name on the offer.
- **Failure looks like**: The offer action with no receiving employer selected. The page shows that it was not offered. No offer is stored.
- **Secrets**: None. Fake ids only. A log line, if one is added, may contain the two employer ids, the contract id, the time, and the outcome. It must not contain a person's name or an employer name.

## Complexity Tracking

No constitution violations.
