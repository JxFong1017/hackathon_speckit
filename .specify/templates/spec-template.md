# Feature Specification: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`  
**Created**: [DATE]  
**Status**: Draft  
**Input**: User description: "$ARGUMENTS"

## Problem & Outcome

**Problem:** [Who is stuck, and what they cannot do today]

**Outcome:** [What a judge or user can see working in the demo]

**Timebox:** [What must ship for the demo vs what can wait]

## Design Notes *(when the feature has a UI)*

<!--
  Describe the intended experience in this spec. External design files are optional.
  If a team has Figma, screenshots, or notes, put them in
  specs/[###-feature]/references/design/ and link them here.
  Do not invent a visual system the team did not describe.
-->

- **Experience in one paragraph**: [What the user sees and does]
- **Design reference path**: [`specs/[###-feature]/references/design/` or N/A]
- **Source**: [Spec only / Figma / screenshots / N/A]

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories are prioritized journeys. P1 is the demo slice.
  Each story must be independently testable. If you build only P1, the demo still works.

  Headings must use this exact parser-compatible format:
  ### User Story N - Title (Priority: PN)
-->

### User Story 1 - [Brief Title] (Priority: P1)

[Describe this user journey in plain language]

**Why this priority**: [Why this is the demo slice]

**Independent Test**: [The action a judge can try, and the result they should see]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [error or empty state], **When** [action], **Then** [user sees a clear result]

---

### User Story 2 - [Brief Title] (Priority: P2)

[Describe this user journey in plain language]

**Why this priority**: [Value after the demo slice]

**Independent Test**: [How this can be tested on its own]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

- Empty or missing input
- The happy path fails halfway (network, invalid data)
- Repeated submit of the same action
- [Domain-specific edge the demo should survive]

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST [capability the P1 demo needs]
- **FR-002**: Users MUST be able to [primary action]
- **FR-003**: System MUST [failure behaviour the user can understand]
- **FR-004**: System MUST [only if a later story needs it]

### Key Entities *(include if the feature stores or passes data)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
- **[Entity 2]**: [What it represents, relationships to other entities]

### Privacy & Data Handling *(only if the feature touches personal data)*

- **Data collected**: [What is stored or processed, or N/A]
- **What stays out of logs**: [Secrets, tokens, personal data]
- **Demo data**: [Fake or local data only — no production data]

### Non-Functional Requirements

- **Demo reliability**: [The P1 path works on a fresh run]
- **Performance**: [Fast enough to show live, or N/A]
- **Security**: [Auth only if the demo needs it; no committed secrets]
- **Accessibility** *(if UI)*: [Keyboard and labels for the demo screens, or a noted gap]

### Observability *(lightweight)*

- **Demo signal**: [How you know the P1 path worked — UI state, log line, or script output]
- **Errors**: [What the user or operator sees when it fails]

## Dependencies

- **Needs before you can build**: [APIs, accounts, datasets, or "none"]
- **Explicitly not required for the demo**: [Trackers, feature flags, production rollout]

## Out of Scope

- [Non-goals and work that waits until later]

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: [Demo script: a new user completes the P1 journey without help]
- **SC-002**: [Failure the demo handles, e.g. invalid input shows a message]
- **SC-003**: [Optional: later-story outcome]

## Assumptions

- [Stack or platform assumption, e.g. "Web app, local run"]
- [Data assumption, e.g. "Seed data is checked in or generated locally"]
- [Team assumption, e.g. "One repo; specs and code live together"]
