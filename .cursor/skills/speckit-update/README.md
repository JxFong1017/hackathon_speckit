# speckit-update

Run `/speckit-update` only after `SPECKIT_UPDATE_REPO` is set to this template's own git URL. The command refuses to run without that variable so it cannot overwrite the template from another Spec Kit repo.

- Uses a shallow clone of the source repo — **not** your project's `git remote origin`
- Compares every file and only writes files that differ or are missing locally
- Preserves project-specific files: `.specify/memory/**`, `.specify/feature.json`, and all of `specs/**`
- Never pulls: `.github/**`, `docs/**`, `catalog-info.yaml`, or `README.md`
- Source is whatever `SPECKIT_UPDATE_REPO` is set to — tries SSH first, then HTTPS
- Stops immediately if that variable is missing or the source repository is unreachable

Optional: `bash .specify/scripts/bash/speckit-update.sh --dry-run` to preview changes without writing.
