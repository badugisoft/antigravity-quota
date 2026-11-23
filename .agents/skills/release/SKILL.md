---
name: release
description: >-
  End-to-end release workflow for Antigravity Quota: version bump, CHANGELOG.md
  finalization, local signed build verification, tagging, and monitoring the
  notarized GitHub Actions release.
---

# Release Workflow

Follow this procedure when preparing and publishing a new release (`vX.Y.Z`) of **Antigravity Quota**.

## 1. Pre-flight Checks
- Ensure `main` is up to date (`git fetch --tags && git status -sb`) and the working tree is clean.
- Run `make test` and confirm all tests pass without dirtying `assets/*.png`.

## 2. Bump Default Version
- Update the default version fallback to `X.Y.Z` in:
  - `Makefile` (`VERSION ?= X.Y.Z`)
  - `scripts/build_app.sh` (`APP_VERSION="${APP_VERSION:-X.Y.Z}"`)
  - `scripts/package_release.sh` (`VERSION="${1:-X.Y.Z}"`)

## 3. Finalize `CHANGELOG.md`
- Move items from `## [Unreleased]` into a new `## [X.Y.Z] - YYYY-MM-DD` section.
- Leave an empty `## [Unreleased]` section at the top.
- Update the comparison links at the bottom of `CHANGELOG.md`:
  ```markdown
  [Unreleased]: https://github.com/badugisoft/antigravity-quota/compare/vX.Y.Z...HEAD
  [X.Y.Z]: https://github.com/badugisoft/antigravity-quota/compare/vPREV...vX.Y.Z
  ```
- Preview the release notes that GitHub Actions will generate:
  ```bash
  make release-notes VERSION=vX.Y.Z
  ```

## 4. Local Build & Signing Verification
- Run `make build` and verify:
  - Developer ID certificate is detected and signed inside-out (`AntigravityQuotaWidget.appex` first, then `Antigravity Quota.app`) with Hardened Runtime.
  - The app installs to `/Applications/Antigravity Quota.app` and launches cleanly.

## 5. Ask for Confirmation (Mandatory)
- **NEVER commit, tag, or push without explicit user approval.**
- Present the modified files, proposed commit message (`chore: bump default app version to X.Y.Z`), tag (`vX.Y.Z`), and previewed release notes, then wait for confirmation.

## 6. Commit, Tag, and Push
- After approval:
  ```bash
  git add Makefile scripts/build_app.sh scripts/package_release.sh CHANGELOG.md
  git commit -m "chore: bump default app version to X.Y.Z"
  git tag vX.Y.Z
  git push origin main --tags
  ```

## 7. Monitor GitHub Actions Release
- Pushing `vX.Y.Z` triggers `.github/workflows/release.yml`, which:
  1. Runs `swift test`.
  2. Imports `MACOS_CERTIFICATE` into a temporary keychain.
  3. Builds, signs, notarizes (`notarytool`), and staples (`.app` and `.dmg`) via `make package`.
  4. Extracts release notes from `CHANGELOG.md` via `make release-notes` and publishes the GitHub Release.
- Monitor the workflow with `gh run list --workflow=release.yml` / `gh run watch` and verify the published release assets and notes.
