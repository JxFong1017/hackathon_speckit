---
description: "Task list for transfer talent contracts"
---

# Tasks: Transfer talent contracts

**Input**: Design documents from `/specs/001-transfer-talent-contracts/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/ui.md, quickstart.md

**Tests**: The plan names `sku test` and `app/src/offer.test.ts` for the offer rules. That test task is included. No other test layer was requested.

**Organization**: One user story. Setup and foundation come first. Stop after that story and walk the quickstart.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1)
- Include exact file paths in descriptions

## Path Conventions

- Demo page: `app/src/`
- Sku config and package: `app/`
- Paths follow `specs/001-transfer-talent-contracts/plan.md`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the Sku app the plan describes

- [X] T001 Create `app/` and `app/src/` as described in `specs/001-transfer-talent-contracts/plan.md`
- [X] T002 [P] Add React, `braid-design-system`, and Sku dependencies in `app/package.json`
- [X] T003 [P] Set `clientEntry` to `src/client.tsx` and `renderEntry` to `src/render.tsx` in `app/sku.config.ts`, with no sites, languages, or SSR

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shell and fake data that the story renders

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 [P] Wrap the page in `BraidProvider` with the `seekJobs` theme and the Seek Sans stylesheet in `app/src/render.tsx`
- [ ] T005 [P] Hydrate the page from `app/src/client.tsx`
- [ ] T006 [P] Add employers `employer-north`, `employer-harbour`, and `employer-brightpath`, plus contract `contract-roster` with label `Roster cover contract`, in `app/src/demo-data.ts`. Store no person name, contact details, or documents

**Checkpoint**: `sku start` from `app/` shows a Braid page. The story is not on it yet.

---

## Phase 3: User Story 1 - See an offered talent contract (Priority: P1) 🎯 MVP

**Goal**: A signed-in employer chooses one other fake employer and offers one contract. Both see `Roster cover contract` and `Offered`. A third employer does not. Taking the contract is out of scope.

**Independent Test**: Sign in as North Ferry Co, choose Harbour Lane Pty Ltd, offer the contract, then sign in as Harbour Lane Pty Ltd and see the same label and status `Offered`, with no employer name on the offer.

### Tests for User Story 1

> Write this test first. It fails until `app/src/offer.ts` exists.

- [ ] T007 [US1] Cover visibility, a second attempt, and a failed attempt with no receiver in `app/src/offer.test.ts`

### Implementation for User Story 1

- [ ] T008 [US1] Implement the offer rules in `app/src/offer.ts`: at most one offer, status `Offered`, a second attempt leaves the original ids unchanged, no receiver selected stores nothing, and only the offering and receiving ids can see it. Any log line contains employer ids, the contract id, the time, and the outcome only
- [ ] T009 [US1] Build the one page in `app/src/App.tsx` from `specs/001-transfer-talent-contracts/contracts/ui.md`: sign-in list, choice list of the other employers' names, an offer action with a visible name that works by keyboard, the label and status `Offered`, the empty state, the not-a-party state, the second-attempt message, and the failure message. Do not add a take action or employer names on the offer

**Checkpoint**: User Story 1 works on its own. Stop here and run the quickstart before any later work.

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: Confirm the demo path and the data rules

- [ ] T010 [P] Walk the P1 path and the surrounding checks in `specs/001-transfer-talent-contracts/quickstart.md` on a fresh `sku start`
- [ ] T011 [P] Confirm `app/` contains no secrets, real company names, real people, or production data

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup. Blocks the user story
- **User Story 1 (Phase 3)**: Depends on Foundational
- **Polish (Phase 4)**: Depends on User Story 1

### User Story Dependencies

- **User Story 1 (P1)**: Starts after Foundational. No other story exists

### Within User Story 1

- T007 is written and fails before T008
- T008 completes before T009
- The story does not include taking the contract, a person signing in, SEEK as a party, or a SEEK employee move

### Parallel Opportunities

- T002 and T003 can run together after T001
- T004, T005, and T006 can run together after Setup
- T010 and T011 can run together after T009

---

## Parallel Example: User Story 1

```bash
# After Setup, the shell and the fake data are different files:
Task: "Wrap the page in BraidProvider in app/src/render.tsx"
Task: "Hydrate the page from app/src/client.tsx"
Task: "Add fake employers and contract-roster in app/src/demo-data.ts"

# The offer test and the page are sequential, not parallel:
Task: "Cover the offer rules in app/src/offer.test.ts"
Task: "Implement app/src/offer.ts"
Task: "Build app/src/App.tsx"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Walk `specs/001-transfer-talent-contracts/quickstart.md`
5. There is no P2 story in this version

---

## Notes

- [P] tasks use different files and do not depend on each other
- [US1] maps to the only user story in `spec.md`
- Design files under `specs/001-transfer-talent-contracts/references/design/` are absent. Follow `spec.md` and `contracts/ui.md`
- Stop after the P1 story and run the demo before any later work
