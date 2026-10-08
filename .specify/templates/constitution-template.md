# [PROJECT_NAME] Constitution

<!-- Example: Project Constitution, App Constitution, etc. -->

## Core Principles

### [PRINCIPLE_1_NAME]

<!-- Example: I. Demo-first -->

[PRINCIPLE_1_DESCRIPTION]

<!-- Example: Every slice must be showable. P1 is a path a judge can try. Later stories wait until that path works. -->

### [PRINCIPLE_2_NAME]

<!-- Example: II. Timebox -->

[PRINCIPLE_2_DESCRIPTION]

<!-- Example: Scope is whatever fits the event. Out-of-scope work is written down and not built "while we're here". -->

### [PRINCIPLE_3_NAME]

<!-- Example: III. One stack -->

[PRINCIPLE_3_DESCRIPTION]

<!-- Example: Pick one language and one way to run the app. Do not add a second framework for the demo. -->

### [PRINCIPLE_4_NAME]

<!-- Example: IV. Safe demo data -->

[PRINCIPLE_4_DESCRIPTION]

<!-- Example: Local or fake data only. No production data, no committed secrets, no real user accounts. -->

### [PRINCIPLE_5_NAME]

<!-- Example: V. Simplicity -->

[PRINCIPLE_5_DESCRIPTION]

<!-- Example: The smallest design that makes the P1 demo work. No extension points for a future product. -->

## [SECTION_2_NAME]

<!-- Example: Additional Constraints, Security Requirements, Performance Standards, etc. -->

[SECTION_2_CONTENT]

<!-- Example: Technology stack requirements, compliance standards, deployment policies, etc. -->

## [SECTION_3_NAME]

<!-- Example: Development Workflow, Review Process, Quality Gates, etc. -->

[SECTION_3_CONTENT]

<!-- Example: Code review requirements, testing gates, deployment approval process, etc. -->

## Governance

<!-- Example: Constitution supersedes all other practices; Amendments require documentation, approval, migration plan -->

[GOVERNANCE_RULES]

<!-- Example: All PRs/reviews must verify compliance; Complexity must be justified; Use [GUIDANCE_FILE] for runtime development guidance -->

**Version**: [CONSTITUTION_VERSION] | **Ratified**: [RATIFICATION_DATE] | **Last Amended**: [LAST_AMENDED_DATE]

<!-- Example: Version: 2.1.1 | Ratified: 2025-06-13 | Last Amended: 2025-07-16 -->

---

## Generated-Code Quality Charter

<!-- SHARED CORE START — copy verbatim into every repo's constitution. This block MUST remain
word-for-word identical across all repos generated from this template. Only "Appendix CQ" below
is repo-specific. Do not edit the shared core in one repo without updating this template and the
other repos via /speckit-constitution. -->

**Purpose.** Bias every Spec Kit output — `spec.md`, `plan.md`, `tasks.md`, and implementation
guidance — toward maintainable, simple, reusable code. These are operational, testable rules,
not aspirations. `/speckit-analyze` treats **correctness and safety** failures as CRITICAL.
Other **MUST** items in this charter are advisory while the first demo is in progress: record the gap and
keep the P1 demo moving.

**Precedence.** When these rules conflict, resolve in this fixed order:

1. **Correctness & safety**
2. **Readability & simplicity**
3. **Reuse & DRY**
4. **Extensibility**

Extensibility never outranks readability or simplicity. A lower tier never overrides a higher one.

### R1 — Pattern check before design (MUST; precedes R2)

- Before proposing any design, generated `spec.md`/`plan.md` **MUST** identify the prevailing
  repo patterns in the affected area for: **naming**, **module layout**, **error handling**,
  **state management**, and **testing approach**.
- Generated work **MUST** either follow those patterns or record a one-sentence justification
  for each deviation.
- Generated work **MUST NOT** introduce a parallel pattern for a problem the repo already solves
  without a recorded one-sentence justification.

### R2 — Reuse before creation (MUST)

- Before proposing new functionality, generated work **MUST** record: (a) which existing
  services / helpers / utilities / components were searched, (b) what was found, (c) whether the
  chosen path is **reuse / extend / create-new**, and (d) a one-sentence rationale.
- “Nothing suitable exists” is **INSUFFICIENT** unless it names what was checked.
- Generated work **MUST** prefer reuse or extension of an existing option that meets the current
  need over creating new code.

### R3 — KISS & simplest-alternative (MUST)

- Generated `spec.md`/`plan.md` **MUST** name the simplest alternative considered and state in
  1–2 sentences why it is insufficient.
- “Prefer the simplest solution” without naming an alternative does **NOT** satisfy this rule.
- Generated work **SHOULD** choose the simplest design that satisfies the current requirement.

### R4 — DRY, bounded by a duplication threshold (MUST/SHOULD)

- Generated work **SHOULD** remove needless duplication of logic and knowledge.
- **Duplication threshold:** consolidate duplicated logic on the **third genuine recurrence**,
  **UNLESS** consolidation would cross an ownership boundary — then record the decision instead
  of consolidating.
- Generated work **MUST NOT** create a shared abstraction for duplication seen fewer than three
  times unless R7 is satisfied.

### R5 — Readability over cleverness (MUST)

- Generated code **MUST** favour clarity for the team over cleverness.
- A more concise or clever construct **MUST NOT** be used where it makes the code harder for the
  team to read.
- This rule takes precedence over stylistic modernity (see R8).

### R6 — YAGNI / no speculative future-proofing (MUST)

- Generated work **MUST NOT** add extension points, configuration options, generalisations, or
  abstractions with no current consumer.
- Speculative future needs **MUST NOT** justify present complexity.
- Only the narrow **carve-outs** below may add non-consumed structure, and each **MUST** carry a
  recorded note.

### R7 — Pragmatic SOLID & abstraction justification (MUST)

- **Pragmatic** means: apply a SOLID principle **only when it reduces coupling for a current
  need**, never for speculative future flexibility.
- Any new abstraction above the trivial threshold — a new interface, base class, generic utility,
  or module (**trivial private helpers are exempt**) — **MUST** carry a present-tense
  justification tied to a current requirement.
- Speculative future needs **do NOT** count as justification.

### R8 — Modern idiomatic language use, bounded (SHOULD)

- Generated code targeting a **TypeScript** repo **SHOULD** use modern, idiomatic TypeScript
  (optional chaining, nullish coalescing, `async`/`await`, discriminated unions, `satisfies`,
  utility types) where it genuinely reduces code or clarifies intent.
- Generated code **MUST NOT** use language or tooling features beyond the **target repo’s
  currently configured compiler/tooling version**, and **MUST NOT** propose upgrading TypeScript
  or tooling as part of the work.
- Where a repo’s own primary language is not TypeScript, apply the same idiom-vs-readability rule
  to that language within its **currently installed** interpreter/tooling version.
- **R5 takes precedence:** newer syntax **MUST NOT** be used where it makes code harder for the
  team to read.

### R9 — Smallest safe change surface (MUST)

- Generated work **MUST** propose the smallest change that safely satisfies the current
  requirement: minimal diff, minimal blast radius, and PRs scoped to one user story where practical.
- Generated work **MUST NOT** bundle unrelated refactors, renames, or drive-by changes into a
  feature change.
- Changes **SHOULD** be backward compatible; breaking changes to shared interfaces follow the
  repo's existing API/event/schema evolution rules (version bump, migration, consumer
  notification) — **no silent breaking changes**.

### R10 — Tests proportional to risk and change (MUST)

- Generated plans/tasks **MUST** scope test effort to the risk and surface area of the change:
  cover new or changed logic, edge cases, and failure paths; do not add ceremonial tests for
  trivial, no-logic changes.
- Test **depth and type** (unit / contract / integration / E2E) **MUST** match the change's risk,
  not a fixed ritual.
- Where a repo mandates a coverage bar for changed scope, that bar still applies; proportionality
  governs test **type and depth**, not evasion of a required bar.

### Carve-outs (R6/R7 exceptions)

Non-consumed structure is permitted **only** for: (a) **stable / external interfaces**,
(b) **security / compliance hooks**, (c) **deliberate migration-period duplication**. Each
carve-out **MUST** be recorded — in the feature `plan.md` Complexity Tracking, and, if durable,
in Appendix CQ Exception Records.

### Review checklist — GATING

Use this list while planning. **Status: advisory while the first demo is in progress.** A “No” blocks
`/speckit-implement` only when it breaks correctness, safety (secrets, production data), or
the P1 demo path. Other gaps get a one-line note in the plan and do not stop the build.

- [ ] ✱ R1: Prevailing patterns (naming, layout, errors, state, testing) identified; each deviation justified in one sentence
- [ ] ✱ R1: No parallel pattern introduced for an already-solved problem without justification
- [ ] ✱ R2: Reuse search recorded (searched / found / reuse-extend-create / rationale), naming what was checked
- [ ] ✱ R3: Simplest alternative named, with 1–2 sentences on why it is insufficient
- [ ] R4: Duplication is < 3 recurrences, or consolidated, or an ownership-boundary note is recorded
- [ ] ✱ R5: No clever construct that harms team readability
- [ ] ✱ R6: No extension points / config / generalisations without a current consumer (or a recorded carve-out)
- [ ] ✱ R7: Every new interface / base class / generic utility / module has a present-tense, current-requirement justification
- [ ] R8: Modern syntax stays within the target repo’s configured tooling version and does not reduce readability
- [ ] ✱ R9: Smallest safe change surface — minimal diff, no unrelated refactors bundled, backward compatible or breaking-change process followed
- [ ] ✱ R10: Test depth/type matches change risk (new logic, edges, failures covered); any repo-mandated coverage bar still met
- [ ] ✱ Carve-outs (if any) recorded with a note

### Governance

- **Owner:** the team using this repository.
- **Exception path:** record exceptions in the feature `plan.md` Complexity Tracking with owner
  and date; record durable exceptions in **Appendix CQ**. Amend the shared core **only** via
  `/speckit-constitution` with a Sync Impact Report and code-owner review, applied identically to
  all repos generated from this template.
- **Differences by repo:** if a repo genuinely needs different policy, **record it as an
  Appendix CQ exception** — do **NOT** silently change the shared core.
- **Review cadence:** not separately defined; this charter **MUST** be reviewed on every
  `/speckit-constitution` amendment and whenever the re-validation trigger fires.
- **Re-validation trigger:** re-run this validation flow when the underlying **generation model
  or Spec Kit tooling changes materially**.

<!-- SHARED CORE END -->

### Appendix CQ — Repo-grounded examples & records ([PROJECT_NAME])

<!-- Replace this appendix with examples grounded in THIS repo's real patterns. Provide one short
positive example and one counter-example per rule (R1–R8), a note on the repo's primary language
and configured tooling version (for R8), plus any carve-outs and exception records. If the repo
has no implementation code yet, say so explicitly and ground examples in documented conventions
and shared tooling rather than inventing them. Keep to ~1 page. Do NOT edit the shared core above
to fit a repo — record differences here as exceptions instead. -->

[APPENDIX_CQ_EXAMPLES]
