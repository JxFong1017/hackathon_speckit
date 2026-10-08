# Feature Specification: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`  
**Created**: [DATE]  
**Status**: Draft  
**Input**: User description: "$ARGUMENTS"

## Problem & Outcome

**Problem:** [Hirer moment blocked - what intent is not converting and why]

**Outcome:** [Measurable conversion, completion, or safety outcome for the P1 CTA journey]

## CTA Inventory *(mandatory when feature adds or changes CTAs)*

| CTA ID | Surface(s) | Primary action | Eligibility (summary) | Flag key(s) |
|--------|------------|----------------|---------------------|-------------|
| [cta-id] | [web / chat / email / push] | [e.g., create_sk_request] | [state + market rules] | [flag-key] |

## Design References *(required when feature includes UI/UX work)*

<!--
  If this feature adds or changes a hirer-visible UI/UX surface, include design references
  in specs/[###-feature]/references/design/ and link or describe them here.

  Acceptable references include Figma links, exported screens, interaction notes, content
  decisions, accessibility notes, or design-review notes.

  If the feature has UI/UX work but no design reference has been supplied, keep the
  clarification marker below. Do not infer layout, copy hierarchy, or interaction states.
-->

- **Design reference path**: `specs/[###-feature]/references/design/`
- **Source of truth**: [Figma / design review / exported screenshots / N/A - no UI/UX change]
- **Status**: [Proposed / reviewed / approved / NEEDS CLARIFICATION]
- **Clarification**: [NEEDS CLARIFICATION: design reference required for UI/UX work]

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as hirer journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE and deliver value on its own.

  Headings must use this exact parser-compatible format:
  ### User Story N - Title (Priority: PN)
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this hirer journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently - e.g., "Can be fully tested by [specific action] and delivers [specific value]"]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [CTA hidden or disabled], **When** [condition], **Then** [hirer sees correct state and telemetry]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this hirer journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

- CTA shown when upstream eligibility is stale or timed out
- Feature flag disabled mid-session
- Wrong market / missing entitlement
- External service or agent tool failure after CTA click
- Duplicate click / idempotent action handling
- UI/UX design reference missing for a hirer-visible change

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST [specific capability, e.g., "evaluate eligibility before rendering CTA"]
- **FR-002**: System MUST [specific capability, e.g., "emit impression and click analytics events"]
- **FR-003**: Users MUST be able to [key interaction, e.g., "complete primary action from CTA"]
- **FR-004**: System MUST [guardrail, e.g., "block finalize when headcount invalid"]
- **FR-005**: System MUST [behaviour, e.g., "hide CTA when sk_request is terminal state"]
- **FR-006**: For UI/UX work, System MUST trace visible copy, states, and interaction patterns to `references/design/` or retain a blocking design-reference clarification.

### Key Entities *(include if feature involves data)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships to other entities]

### Privacy & Data Handling *(required when feature touches candidate, employer, or workforce PII)*

- **Data collected**: [What is stored or processed]
- **Classification**: [public / internal / confidential / restricted per field]
- **Purpose & lawful basis**: [Why each data element is needed]
- **Access & retention**: [Who can access, how long data is kept, deletion triggers]
- **Logging constraints**: [What MUST NOT appear in logs/errors]

### Non-Functional Requirements *(mandatory)*

- **Reliability / SLOs**: [User-visible availability and degradation behaviour]
- **Performance**: [Latency targets for eligibility and action paths]
- **Security**: [AuthZ model, threat notes, RFC008/018/020 applicability]
- **Accessibility** *(if UI)*: [WCAG-oriented requirements, focus states, keyboard flow, screen-reader states]
- **Markets / locales**: [RFC034/RFC049 scope - which zones apply]

### Tracking & Observability Requirements *(mandatory)*

<!--
  Frontend/hirer-visible changes must explicitly decide whether Hubble tracking is needed.
  It is valid to decide "not required" or "N/A", but the rationale must be recorded.
  Backend/service-side tracking belongs in Observability Strategy, not optional product analytics.
-->

- **Frontend Hubble tracking decision**: [Required / Not required / N/A / NEEDS CLARIFICATION]
- **Frontend tracking rationale**: [Why Hubble tracking is or is not needed]
- **Hubble events** *(if required)*: [Event names, trigger points, required properties, correlation IDs, PII exclusions]
- **Backend observability** *(if backend paths exist)*: [Logs, metrics, traces, dashboards, alerts, runbook owner]
- **Clarification**: [NEEDS CLARIFICATION: frontend Hubble tracking decision required]

### Dependencies & Integrations

- **Upstream / downstream systems**: [Name, owning team, contract location]
- **Cross-team contract status**: [Proposed / reviewed / approved - link to `contracts/`]
- **Design dependencies** *(if UI/UX)*: [Design owner, reference path, review status]

### Rollout Strategy

- **Feature flag key(s)**: [Name, default, kill-switch owner]
- **Phases**: [dev → staging → prod % rollout]
- **Rollback**: [Flag off, revert, data steps]
- **Analytics / tracking**: [Reference Tracking & Observability Requirements decision; do not duplicate conflicting event names]

## Out of Scope

- [Explicit non-goals and deferred work]

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: [Measurable metric, e.g., "P1 CTA completion rate ≥ X% in staging"]
- **SC-002**: [Guardrail, e.g., "Mis-click / support ticket rate does not increase"]
- **SC-003**: [Performance, e.g., "95% of hirers see the next step within X seconds"]
- **SC-004**: [Business metric tied to hirer outcome]

## Assumptions

- [Assumption about surfaces in scope, e.g., "Web only for v1; chat CTAs deferred"]
- [Assumption about upstream state, e.g., "SK request id present in session"]
- [Dependency on existing system/service, e.g., "Uses Hirer feature-flag service"]
