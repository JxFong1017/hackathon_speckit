<!-- Sync Impact Report
Version change: (none) → 1.0.0
Initial ratification. No prior constitution file existed.
Modified principles: none (first adoption)
  I. Demo-first
  II. Timebox
  III. One stack
  IV. Safe demo data
  V. Simplicity
Added sections: Evidence and safety; Spec Kit workflow; Appendix CQ
Removed sections: none
Templates:
  ✅ .specify/templates/plan-template.md — Constitution Check already matches these principles
  ✅ .specify/templates/spec-template.md — problem, outcome, timebox, out of scope, demo data already present
  ✅ .specify/templates/tasks-template.md — P1 demo path and no committed secrets already present
  ✅ .specify/templates/prd-template.md — audience, outcome, out of scope, sources already present
  ✅ README.md — step 1 now points at this file
  N/A .specify/templates/commands/ — directory not present; commands live under .cursor/skills/
Follow-up TODOs: none
-->

# Spec Kit Template Constitution

## Core Principles

### I. Demo-first

Every version MUST have one P1 path a person can try. Later stories MUST wait until that path works. `/speckit-implement` MUST stop after the P1 story and report the demo path before continuing, unless the user already asked to build everything.

### II. Timebox

Work outside the current version MUST be written under Out of scope in the PRD or spec. Generated plans and tasks MUST NOT depend on that deferred work. A new behaviour discovered while building MUST be recorded as out of scope or as a new story, not folded into the current slice.

### III. One stack

The plan MUST name one language, one runtime, and one way to run the app, or mark each as N/A. Generated work MUST NOT add a second framework, datastore, or hosting model for the same P1 path.

### IV. Safe demo data

Demo data MUST be local or fake. Generated work MUST NOT use production data, real user accounts, or committed secrets. Personal data, when the feature touches it, MUST be named in the spec. Logs and errors MUST NOT contain secrets or personal data.

### V. Simplicity

The plan MUST name the simplest design that makes the P1 demo work, and MUST name one simpler alternative that was rejected. Generated work MUST NOT add extension points, configuration, or abstractions that the current version does not use.

## Evidence and safety

A Ready PRD under `docs/prd/` MUST be the source for problem, audience, outcome, and out of scope. `/speckit-specify` MUST NOT add behaviour that PRD lists as out of scope.

Generated specs, plans, and tasks MUST NOT invent architecture, APIs, contracts, or UI. Decisions come from the PRD, the spec, and files that exist in this checkout.

Company context (Glean, Atlassian, Backstage, GitHub, and the RFC skill) MUST be used only when that connector or skill is available in the session. A search with no match MUST stay an open question. It is not evidence that the thing does not exist. An ADOPTED RFC that applies MUST be cited. A DEPRECATED RFC MUST NOT be treated as a constraint.

`/speckit-design-prompt` is optional. It MUST NOT invent screens. Fidelity and SEEK Braid are choices recorded in the PRD, not assumptions.

## Spec Kit workflow

The required order is `/speckit-constitution`, `/speckit-prd`, `/speckit-specify`, `/speckit-plan`, `/speckit-tasks`, then `/speckit-implement`. `/speckit-design-prompt` MAY run after the PRD is Ready, and again after the spec exists.

The plan Constitution Check MUST pass, or each violation MUST be justified, before research. Stack, libraries, and file layout belong in the plan. Product questions belong in the PRD. Behaviour and acceptance belong in the spec.

Specs and application code for a feature live in this repository unless the team records a different layout in the plan.

## Governance

This constitution supersedes conflicting practice in generated specs, plans, and tasks. Amendments MUST be made by running `/speckit-constitution`, which writes a Sync Impact Report and updates dependent templates when a principle changes.

Versioning follows semantic versioning. MAJOR removes or redefines a principle. MINOR adds a principle or a section. PATCH clarifies wording without changing a rule.

The plan Constitution Check is the compliance review before implementation. Correctness, safety (secrets and production data), and a missing P1 demo path block `/speckit-implement`. Other quality-charter gaps are advisory while the first demo is in progress and MUST be noted in the plan.

**Owner:** the team using this repository.

**Version**: 1.0.0 | **Ratified**: 2026-10-09 | **Last Amended**: 2026-10-09

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

### Appendix CQ — Repo-grounded examples & records (Spec Kit Template)

This repository has no application source code yet. Examples below use the toolkit that is on disk: Markdown skills under `.cursor/skills/`, Bash under `.specify/scripts/bash/`, and templates under `.specify/templates/`. There is no configured TypeScript or other application compiler (R8).

| Rule | Follow                                                                                                    | Do not                                                                                     |
| ---- | --------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| R1   | A new command is a `.cursor/skills/speckit-*/SKILL.md` with the same frontmatter shape as `/speckit-prd`. | A second skill layout that does not match the existing `name`, `description`, and outline. |
| R2   | `/speckit-specify` reads a Ready PRD instead of a new command that restates the same sections.            | A parallel spec writer that ignores `docs/prd/`.                                           |
| R3   | One feature directory per `/speckit-specify` run.                                                         | Generating the plan, tasks, and code in that same command.                                 |
| R4   | Repeated script helpers go in `.specify/scripts/bash/common.sh` on the third use.                         | A shared library for a helper used once.                                                   |
| R5   | Skill steps stay short sentences a teammate can follow.                                                   | Nested conditions that hide when the command must stop.                                    |
| R6   | `docs/prd/` holds the current brief.                                                                      | Empty folders reserved for document types nobody has asked to write.                       |
| R7   | A new skill exists because a current command calls it.                                                    | A base skill type added so later commands might inherit from it.                           |
| R8   | Bash stays within the scripts already in `.specify/scripts/bash/`.                                        | Rewriting those scripts in a language this repo does not install.                          |

**Carve-out.** `.cursor/mcp.json` lists connector URLs and no tokens. It is a stable external interface (R6/R7 carve-out a): the file exists so Cursor can ask each person to sign in. Recorded 2026-10-09.

**Exception records.** None.
