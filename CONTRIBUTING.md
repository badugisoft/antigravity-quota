# Contributing to Antigravity Quota

Thank you for your interest in contributing to **Antigravity Quota**!

## Prerequisites

- **macOS**: 13.0 (Ventura) or later
- **Toolchain**: Xcode 15.0+ or Swift 5.9+
- **Target App**: Google Antigravity (for live local/remote RPC integration testing)

## Local Development Workflow

```bash
# 1. Clone the repository
git clone https://github.com/badugisoft/antigravity-quota.git
cd antigravity-quota

# 2. Run unit & integration tests (does not modify assets/*.png)
swift test

# 3. Build, codesign, install to /Applications, and launch
./scripts/build_app.sh

# 4. Regenerate documentation screenshots (only when UI intentionally changes)
GENERATE_SCREENSHOTS=1 swift test
```

## Project Conventions

- **Zero External Dependencies**: The project strictly uses pure Swift, SwiftUI, AppKit, and WidgetKit (`Package.swift` must remain dependency-free).
- **Dynamic Server-Driven UI**: Avoid hardcoding model names or fixed quota group enums. All menu bar abbreviations, popover cards, widgets, and settings dynamically iterate server-provided groups and buckets.
- **Multi-Language Support (7 Languages)**: Keep all user-facing strings localized across all 7 supported dictionaries in `Sources/AntigravityQuotaCore/Services/Localization/` (`EN`, `KO`, `ZH`, `JA`, `DE`, `FR`, `ES`) and verified by tests.
- **Documentation & Changelog Sync**: When adding features or changing UI/behavior, update [CHANGELOG.md](CHANGELOG.md) under `## [Unreleased]`, both the root [README.md](README.md) and all localized guides in `docs/README.<lang>.md` (`ko`, `zh`, `ja`, `de`, `fr`, `es`), as well as [AGENTS.md](AGENTS.md) if architectural rules change.
- **Codesigning & Sandbox Rules**: Never use `codesign --deep`; always sign `AntigravityQuotaWidget.appex` before the host bundle (`./scripts/build_app.sh` handles this automatically, using a local `Developer ID Application` certificate with Hardened Runtime when present or falling back to ad-hoc signing).

## Submitting a Pull Request

1. Fork the repository and create a topic branch from `main`.
2. Keep changes focused and ensure `swift test` passes with zero failures.
3. Verify the app builds and runs locally using `./scripts/build_app.sh`.
4. Fill out the [Pull Request Template](.github/PULL_REQUEST_TEMPLATE.md) clearly describing your changes and testing steps.
