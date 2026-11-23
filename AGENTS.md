# Antigravity Quota — Agent Guidelines

## Operating Rules

1. **Git Commit & Push Policy**: **NEVER** execute `git commit` or `git push` without explicit user approval. Always present modified files and the proposed commit message first.
2. **Language & Localization**:
   - Respond in the user's language.
   - Preserve 7-language support (`EN`, `KO`, `ZH`, `JA`, `DE`, `FR`, `ES`) in `Sources/AntigravityQuotaCore/Services/Localization/`.
   - Keep `README.md` and `docs/README.<lang>.md` (`ko`, `zh`, `ja`, `de`, `fr`, `es`) synchronized.
3. **Zero External Dependencies**: Pure Swift / SwiftUI / AppKit / WidgetKit only (`Package.swift` must remain dependency-free).
4. **Local Verification**: Always run `make build` after code changes so `/Applications/Antigravity Quota.app` is compiled, signed, installed, and launched.

## Commands

```bash
make test         # Run unit & integration tests (swift test)
make build        # Build release bundle, codesign, install to /Applications, and launch
make screenshots  # Regenerate README screenshots (only when UI changes intentionally)
make package      # Build signed .zip and .dmg (notarizes when Apple credentials are set)
```

## Architecture & References

- **Targets** (`Package.swift`): `AntigravityQuotaCore` (models, store, localization, widget views), `AntigravityQuota` (menu bar app), `AntigravityQuotaWidget` (WidgetKit extension).
- **Project structure & setup**: [README.md](README.md), [CONTRIBUTING.md](CONTRIBUTING.md)
- **Technical notes & macOS pitfalls** (TCC, inside-out codesigning, polling, SSH, popover lifecycle): [docs/TECHNICAL_NOTES.md](docs/TECHNICAL_NOTES.md)
- **Workflow skills**: `.agents/skills/commit-and-push/`, `.agents/skills/release/`
