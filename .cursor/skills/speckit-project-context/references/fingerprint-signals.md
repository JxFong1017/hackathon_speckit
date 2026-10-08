# Structure Fingerprint Signals

The triage script (`.specify/scripts/bash/triage-project-context.sh`) computes a **structure fingerprint** to decide whether a full project-context regeneration is needed. Individual feature files, tests, and style changes do **not** affect the fingerprint.

## Included in fingerprint

| Signal               | Source                                                                   | Why it matters                               |
| -------------------- | ------------------------------------------------------------------------ | -------------------------------------------- |
| `scan_scope`         | Skill / `--scan-scope` argument                                          | Scoped scans fingerprint only that subtree   |
| `top_level_dirs`     | Non-hidden directories at scan root (depth 1)                            | New modules, apps, or packages at repo root  |
| `src_modules`        | Direct children of `src/` when present                                   | Domain/module layout changes                 |
| `workspace_packages` | `pnpm-workspace.yaml` `packages` list, or `packages/` / `apps/` children | Monorepo membership changes                  |
| `manifest_digest`    | SHA-256 of known manifest files that exist                               | Stack, deploy, or ownership metadata changes |

Manifest files considered (when present at repo root):

- `package.json`, `pnpm-workspace.yaml`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`
- `catalog-info.yaml`, `sku.config.ts`, `deploy.config.js`, `gantry.apply.yml`
- `docker-compose.yml`, `Dockerfile`

## Excluded from fingerprint

- Files under `specs/` (per-feature work)
- Individual source files, tests, CSS, lockfiles
- `node_modules/`, `dist/`, `build/`, `.git/`, `lib/`

## State artifact

After every **full regeneration**, write:

`.specify/memory/project-context.state.json`

via:

```bash
bash .specify/scripts/bash/triage-project-context.sh --write-state --scan-scope "<scope>"
```

The state file stores the fingerprint and human-readable signals for debugging. It lives beside `project-context.md` and is preserved by `/speckit-update` (under `.specify/memory/**`).

## Quality-pass escalation

When triage returns `quality_pass`, the skill verifies paths cited in **Key Modules & Domains** and **Entry points** tables. Escalate to `full_regen` when:

- Any path listed under **Entry points** is missing, or
- Any path listed under **Key Modules & Domains** is missing

Quality pass does **not** patch individual rows to **Stale risk** — any missing cited path triggers full regeneration.
