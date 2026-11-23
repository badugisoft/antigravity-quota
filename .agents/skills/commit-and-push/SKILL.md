---
name: commit-and-push
description: >-
  Standardized post-task workflow for reviewing changes, running tests, updating
  CHANGELOG.md, getting user confirmation, and committing/pushing to origin.
---

# Commit and Push Workflow

Follow this checklist before committing and pushing any changes in **Antigravity Quota**.

## 1. Review Changes
- Run `git status -sb` and `git diff --stat` to verify only intended files are modified and no temporary files or unintended `assets/*.png` diffs exist.

## 2. Run Verification
- Run `swift test` and confirm all tests pass.
- If source code or bundle scripts changed, run `./scripts/build_app.sh` to verify Release compilation, inside-out codesigning, `/Applications` installation, and app launch.

## 3. Sync Changelog & Documentation
- Update `CHANGELOG.md` under `## [Unreleased]` for any notable feature, fix, or workflow change.
- If user-facing behavior, UI, or installation steps changed, ensure `README.md`, `docs/README.<lang>.md` (`ko`, `zh`, `ja`, `de`, `fr`, `es`), `AGENTS.md`, and `site/` are synchronized.

## 4. Ask for Confirmation (Mandatory)
- **NEVER execute `git commit` or `git push` without explicit user approval.**
- Present:
  1. The list of files to be staged and committed.
  2. The proposed Conventional Commit message (e.g., `feat: ...`, `fix: ...`, `docs: ...`, `ci: ...`, `chore: ...`).
- Wait for the user to confirm.

## 5. Commit and Push
- Once approved:
  ```bash
  git add <files>
  git commit -m "<type>: <summary>"
  git push origin main
  ```
