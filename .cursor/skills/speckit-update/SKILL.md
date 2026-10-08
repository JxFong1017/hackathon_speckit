---
name: "speckit-update"
description: "Pull new Spec Kit toolkit changes from the canonical adjacency-speckit repository by comparing every managed file's contents (ignores the project's git remote origin)."
compatibility: "Requires spec-kit project structure with .specify/ directory"
metadata:
  author: "flex-hiring-and-adjacencies"
  source: ".specify/scripts/bash/speckit-update.sh"
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

Supported flags in `$ARGUMENTS` (pass through to the script):

- `--dry-run` — report differences only; do not write files
- `--json` — machine-readable summary on stdout

## Purpose

Sync **toolkit** files (commands, scripts, templates, skills, extensions) from the canonical **adjacency-speckit** source repository into the current workspace.

This command **does not** use `git pull`, `git merge`, or the current project's `remote.origin.url`. It always fetches from the canonical **adjacency-speckit** source (`SEEK-Jobs/adjacency-speckit`), overridable only via `SPECKIT_UPDATE_REPO`.

**Repository access order** (mandatory): try **SSH** first (`git@github.com:SEEK-Jobs/adjacency-speckit.git`), then fall back to **HTTPS** (`https://github.com/SEEK-Jobs/adjacency-speckit.git`) if SSH fails. If both fail, stop immediately.

## Mandatory constraints

1. **Do not** run `git pull` / `git fetch` against the project's own remote to perform this update.
2. **Do** run `.specify/scripts/bash/speckit-update.sh` as the single source of truth for file comparison and writes.
3. **Access failure = stop**: If the script exits non-zero (especially exit `1` for repository access or clone failure), **abort immediately**. Do not fall back to partial updates, cached copies, or guessing file contents.
4. **Content comparison**: The script compares each managed file with `cmp` (byte-identical). Only differing or missing local files are written.
5. **`specify-rules.md` merge**: When syncing `.cursor/rules/specify-rules.md`, toolkit rule text is taken from upstream but the local **`Active feature`** line is preserved (project-specific context set by `/speckit-plan` and related commands).

## Pre-execution checks

1. Confirm `.specify/` exists in the workspace (Spec Kit project). If missing, stop and tell the user to initialize Spec Kit first.
2. Confirm `git` is available (`command -v git`). If missing, stop with an error (the script requires git for `ls-remote` and shallow clone).

## Execution

From the repository root:

```bash
bash .specify/scripts/bash/speckit-update.sh
```

If the user passed `--dry-run` or `--json` in `$ARGUMENTS`, append those flags.

On **success** (exit 0):

- Summarize counts: updated, added, unchanged, preserved
- List changed paths (from script output or `--json`)
- If `--dry-run` was used and changes exist, tell the user to re-run `/speckit-update` without `--dry-run` to apply
- Do **not** auto-commit unless the user asks; optional note that they may commit toolkit updates separately from feature work

On **access error** (exit 1, message contains `Cannot access source repository` or `Failed to clone`):

- Stop. Do not modify any files manually.
- Tell the user to verify GitHub access to `SEEK-Jobs/adjacency-speckit` (SSH key for `git@github.com`, or HTTPS credential if SSH is unavailable) and retry.

## What gets synced

| Area              | Included                                                                             |
| ----------------- | ------------------------------------------------------------------------------------ |
| `.specify/`       | Scripts, templates, extensions, workflows, integration manifests, Jira import config |
| `.cursor/skills/` | All `speckit-*` command skills                                                       |
| `.cursor/rules/`  | `specify-rules.md`                                                                   |

## What is preserved (never overwritten)

| Path                    | Reason                                     |
| ----------------------- | ------------------------------------------ |
| `.specify/memory/**`    | Project constitution and memory            |
| `.specify/feature.json` | Active feature pin for this project        |
| `specs/**`              | Feature specs and implementation artifacts |

**Partial preservation** in `.cursor/rules/specify-rules.md`: the **`Active feature`** line is kept from the local file; all other content between `<!-- SPECKIT START -->` and `<!-- SPECKIT END -->` is updated from upstream.

## What is excluded (never pulled from upstream)

| Path                | Reason                              |
| ------------------- | ----------------------------------- |
| `.github/**`        | Project/repo-specific GitHub config |
| `docs/**`           | Project documentation               |
| `catalog-info.yaml` | Backstage catalog metadata          |
| `README.md`         | Project readme                      |

## Completion report

State explicitly:

- Source repo URL, transport (`ssh` or `https`), and ref used
- `updated` / `added` / `unchanged` / `preserved` counts
- Whether run was dry-run or applied
- Exit code from the script
