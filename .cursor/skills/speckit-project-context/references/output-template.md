# Project Context: [PROJECT_NAME]

**Generated**: [ISO-8601 date]  
**Scan scope**: [whole repo | subdirectory: relative/path]

<!-- Scan scope: repo-relative only. Use "whole repo" for full scans, or "subdirectory: packages/foo" when scoped. Never write absolute paths (e.g. /Users/...). -->

## Executive Summary

[2–4 sentences: what this project is, who it serves, and its primary technical role. Lead with business/product purpose when evidence exists.]

## Repo Purpose & Business Context

| Aspect                   | Detail                                                                                                      | Confidence                                   |
| ------------------------ | ----------------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| Product / service        | [what it delivers]                                                                                          | [Verified / Inferred / Unknown / Stale risk] |
| Primary users / actors   | [end users who interact with the product to achieve a business goal — e.g. hirers, candidates, job seekers] |                                              |
| Owner / maintaining team | [from `catalog-info.yaml` `spec.owner`, CODEOWNERS, or deploy config — if found]                            |                                              |
| Problem domain           | [domain the code addresses]                                                                                 |                                              |
| Maturity / status        | [active, legacy, spike, library, etc.]                                                                      |                                              |

<!-- Primary users / actors: people who use the product in production workflows. Derive from README, auth levels, route audiences, and product copy — NOT from `catalog-info.yaml` owner or CODEOWNERS. Owner / maintaining team is governance metadata, not a product actor. -->

**Evidence**: [README, package description, catalog-info, docs paths consulted]

## Key Modules & Domains

| Module / area | Path(s) | Responsibility | Notes                  |
| ------------- | ------- | -------------- | ---------------------- |
| [name]        | `path/` | [what it owns] | [coupling, boundaries] |

<!--
  List top-level packages, services, or bounded contexts.
  For monorepos: one row per deployable or major package.
-->

## Entry Points & Runtime Flow

### Entry points

| Type                                            | Location | Trigger         | Notes |
| ----------------------------------------------- | -------- | --------------- | ----- |
| [HTTP API / CLI / worker / UI / library export] | `path`   | [how it starts] |       |

### Primary runtime flow

```text
[Trigger] → [component] → [component] → [external system / persistence]
```

[1–2 short paragraphs describing the happy-path request/job lifecycle. Name real files or handlers where verified.]

## Services, Integrations & Dependencies

### Internal / first-party

| Service / package | Relationship                | Interface                     | Notes |
| ----------------- | --------------------------- | ----------------------------- | ----- |
|                   | consumes / exposes / embeds | REST / GraphQL / events / SDK |       |

### External / third-party

| Dependency | Purpose | Config / credential surface | Notes |
| ---------- | ------- | --------------------------- | ----- |
|            |         | env var / secret name       |       |

### Key runtime dependencies

| Category           | Technology | Version (if found) | Role |
| ------------------ | ---------- | ------------------ | ---- |
| Language / runtime |            |                    |      |
| Framework          |            |                    |      |
| Data store         |            |                    |      |
| Messaging / queues |            |                    |      |

## Data Models & Contracts

| Model / contract | Location | Description | Consumers |
| ---------------- | -------- | ----------- | --------- |
|                  | `path`   |             |           |

**Contract artifacts**: [OpenAPI, GraphQL schema, protobuf, JSON schema, shared types — list paths or "none found"]

## Configuration & Environment

| Variable / setting | Required | Purpose | Default / example |
| ------------------ | -------- | ------- | ----------------- |
|                    | yes/no   |         |                   |

**Config files**: [`.env.example`, `config/`, Helm, Terraform — list with purpose]

**Local dev expectations**: [install steps, services to run, ports, seed data — from README/Makefile/scripts]

**Deployment targets**: [AWS, K8s, Vercel, etc. — only if evidenced]

## Testing Approach

| Layer       | Framework / tool | Location            | How to run |
| ----------- | ---------------- | ------------------- | ---------- |
| Unit        |                  | `tests/` or pattern | `command`  |
| Integration |                  |                     |            |
| E2E         |                  |                     |            |

**Coverage tooling**: [if present]

**Notable gaps**: [untested critical paths, missing e2e, flaky areas, absent contract tests]

## Documentation & Knowledge

| Artifact            | Path | Status                        |
| ------------------- | ---- | ----------------------------- |
| README              |      | [complete / sparse / missing] |
| Architecture docs   |      | [path + 1–2 sentence summary when found; `none found` if absent — do not invent] |
| API docs            |      |                               |
| Runbooks / ADRs     |      |                               |
| Backstage / catalog |      |                               |

<!-- Architecture: discovery order in .cursor/rules/references/project-memory-paths.md under scan root / TARGET_REPO_ROOT. Surface path and short summary for /speckit-specify, /speckit-plan, /speckit-tasks, /speckit-implement. -->

## Confidence & Knowledge Gaps

| Topic  | Status                                     | Notes                          |
| ------ | ------------------------------------------ | ------------------------------ |
| [area] | Verified / Inferred / Unknown / Stale risk | [what is missing or uncertain] |

**Recommended follow-ups before SDD** (max 5):

1. [question or doc to add]

## SDD Reuse Notes

Use this file as grounding input for:

- **`/speckit-constitution`**: product name, principles, non-negotiables implied by stack and boundaries
- **`/speckit-specify`**: actors, existing surfaces, integration constraints, data entities; architecture path/summary when present
- **`/speckit-clarify`**: actors, integrations, domain boundaries when forming questions
- **`/speckit-plan`**: technical context, entry points, contracts, env assumptions, test commands; seed structure from architecture when present
- **`/speckit-tasks`**: modules, entry points, realistic file paths for task breakdown; respect architecture layering when present
- **`/speckit-analyze`**: codebase alignment checks against verified project structure
- **`/speckit-implement`**: codebase structure, entry points, integration patterns; intended directories from architecture when present

**Do not treat inferred rows as facts** — confirm Unknown / Inferred items with the team before locking requirements.
