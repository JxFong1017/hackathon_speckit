# speckit-update

Run `/speckit-update` in any project that has `.specify/` to pull the latest toolkit files from the canonical [adjacency-speckit](https://github.com/SEEK-Jobs/adjacency-speckit) repository.

- Uses a shallow clone of the source repo — **not** your project's `git remote origin`
- Compares every file and only writes files that differ or are missing locally
- Preserves project-specific files: `.specify/memory/**`, `.specify/feature.json`, and all of `specs/**`
- Never pulls: `.github/**`, `docs/**`, `catalog-info.yaml`, or `README.md`
- Source is `SEEK-Jobs/adjacency-speckit` — tries SSH first, then HTTPS (override with `SPECKIT_UPDATE_REPO` only)
- Stops immediately if the source repository is unreachable (fix GitHub access, then retry)

Optional: `bash .specify/scripts/bash/speckit-update.sh --dry-run` to preview changes without writing.
