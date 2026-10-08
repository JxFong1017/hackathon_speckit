# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]  
**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]  
**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]  
**Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]  
**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]
**Project Type**: [e.g., library/cli/web-service/mobile-app/compiler/desktop-app or NEEDS CLARIFICATION]  
**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]  
**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]  
**Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]
**Design Reference** *(if UI/UX)*: [`specs/[###-feature]/references/design/` path, Figma/export status, or NEEDS CLARIFICATION]
**Frontend Hubble Tracking**: [Required / Not required / N/A, with rationale, or NEEDS CLARIFICATION]
**Backend Observability**: [Logs/metrics/traces/dashboard/alert strategy, owner, or N/A]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate (constitution §) | Question | Status |
|-----------------------|----------|--------|
| §3 Product | P1 outcome clear; no blocking `[NEEDS CLARIFICATION]` | ☐ |
| §2 Hirer domain | Bounded contexts, dependencies, contract owners named | ☐ |
| §4 Architecture | Extends existing patterns; new services justified; no invented APIs | ☐ |
| §6 Data/privacy | Classification, retention, logging redaction if data touched | ☐ |
| §7 Rollout | Feature flags, rollback, operational readiness for user-visible change | ☐ |
| §8 Testing | Unit/contract/integration strategy for domain + external contracts | ☐ |
| §9 Observability | Logs, metrics, traces, dashboards, alerts per RFC024/025/026 | ☐ |
| §9 Tracking | Frontend Hubble tracking decision documented; backend tracking covered by Observability Strategy | ☐ |
| §10 SDD | Spec/plan/tasks traceability; `contracts/` for externals | ☐ |
| §10 SDD + §3 Product | UI/UX work has `references/design/` evidence or a blocking clarification | ☐ |

Mark **Pass**, **Violation** (justify in Complexity Tracking), or **N/A** with rationale.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── references/
│   └── design/          # Required for UI/UX work: links, exports, review notes
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## UI/UX Design Alignment *(required when feature includes UI/UX work)*

- **Design reference path**: [`specs/[###-feature]/references/design/` or N/A - no UI/UX work]
- **Source of truth**: [Figma URL / exported screens / design review notes / NEEDS CLARIFICATION]
- **States covered**: [default, loading, error, disabled, empty, success, responsive states as applicable]
- **Accessibility notes**: [keyboard, focus, labels, screen reader behaviour, contrast]
- **Braid/Vocab alignment**: [Components/tokens used or exception needing Complexity Tracking]

If this section is `NEEDS CLARIFICATION` for a UI/UX feature, stop before Phase 0 research and run
`/speckit-clarify`.

## Tracking & Observability Strategy

- **Frontend Hubble decision**: [Required / Not required / N/A]
- **Frontend Hubble rationale**: [Why this feature does or does not need frontend tracking]
- **Frontend events** *(if required)*: [Event names, triggers, properties, correlation IDs, PII exclusions]
- **Backend observability scope**: [Backend/BFF/agent/integration paths in scope or N/A]
- **Backend logs**: [Structured log fields, correlation/request IDs, redaction rules]
- **Backend metrics/traces**: [Counters/timers/spans, dimensions, SLO/SLA tie-in]
- **Dashboards/alerts/runbook**: [Dashboard links or planned paths, alert thresholds, owner]

If frontend Hubble tracking is undecided for a frontend/hirer-visible feature, stop and run
`/speckit-clarify`. If backend paths exist, do not leave backend observability as optional
analytics; cover it here.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
