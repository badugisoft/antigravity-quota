# Changelog

All notable changes to **Antigravity Quota** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- Prevented the menu bar popover from remaining stuck open when focus moves or clicks occur during the opening animation, and ensured it closes cleanly when opening Settings (`AppDelegate`, `MenuBarPopoverView`).

## [1.4.0] - 2026-11-23

### Added
- Developer ID code signing (Hardened Runtime) and Apple notarization/stapling in release builds (`scripts/build_app.sh`, `scripts/package_release.sh`, `.github/workflows/release.yml`).
- Automatic local Developer ID certificate detection in `scripts/build_app.sh` with ad-hoc (`-`) fallback when no certificate is present.
- `CHANGELOG.md` and automated release note extraction with Full Changelog comparison links.
- Cloudflare Web Analytics tracking on the GitHub Pages promotional site (`site/index.html`).
- Project skills for commit/push and release workflows in `.agents/skills/`.

### Changed
- Updated documentation (`README.md`, `docs/README.*.md`, `CONTRIBUTING.md`, `AGENTS.md`, `site/`) to reflect Apple Developer ID signing, notarization, and changelog workflow.
- Updated default app version to `1.4.0`.

## [1.3.1] - 2026-11-21

### Added
- Multi-language GitHub Pages promotional site (`site/`) and automated deployment workflow (`.github/workflows/pages.yml`).
- Community health files (`CONTRIBUTING.md`, `SECURITY.md`, issue/PR templates) and localized READMEs for all 7 supported languages (`en`, `ko`, `zh`, `ja`, `de`, `fr`, `es`).

### Fixed
- Dynamically sized the menu bar popover to fit its content and clamped the window within the top screen boundary (`MenuBarPopoverView`, `AppDelegate`).

### Changed
- Bumped GitHub Actions workflows to Node.js 24 compatible action versions.
- Updated default app version to `1.3.1`.

## [1.3.0] - 2026-11-21

### Added
- Dynamic rendering of all server-returned quota groups and buckets across widgets, menu bar, popover cards, and settings—eliminating hardcoded model group lookups.

### Changed
- Updated default app version to `1.3.0`.

## [1.2.3] - 2026-11-21

### Fixed
- Extracted CSRF token from the `ANTIGRAVITY_SERVER_CSRF_TOKEN` environment variable for Antigravity 2.34+ compatibility (across both local `LanguageServerDiscovery` and `RemoteSSHQuotaService`).

### Changed
- Updated release workflow runner from `macos-14` to `macos-latest`.

## [1.2.2] - 2026-10-15

### Fixed
- Switched local listening port discovery from `netstat` to `lsof` for reliable output in child processes on macOS Sonoma/Sequoia.
- Preserved HTTP vs. HTTPS endpoint protocol schemes during `language_server` discovery to prevent HTTP 400 errors against HTTPS servers.

## [1.2.1] - 2026-09-22

### Fixed
- Suppressed rolling-window reset countdowns and scheduled reset times when quota is 100% full, displaying an "Unused" status instead.

## [1.2.0] - 2026-09-21

### Added
- Remote SSH quota query fallback (`RemoteSSHQuotaService`) when Antigravity is not running locally.
- Configurable polling interval settings in the Settings window.

## [1.1.1] - 2026-09-14

### Added
- Pre-scheduled local system notifications for upcoming quota refills.

## [1.1.0] - 2026-09-14

### Added
- Native macOS Settings window (Launch at Login, menu bar gauge source, display style, and language).
- Circular progress ring gauge around the Antigravity logo in the menu bar.
- Offline quota auto-recovery tracking when the IDE is closed.
- Quota refill banner notifications when 5-hour or weekly buckets reach 100%.

## [1.0.0] - 2026-09-13

### Added
- Initial release of Antigravity Quota macOS menu bar monitor and WidgetKit desktop/Notification Center widgets (Small & Medium).
- Real-time quota monitoring via local `language_server` Connect-RPC discovery.
- Quota-driven adaptive burst polling (15s active with 3-minute cooldown, 60s idle).
- Multi-language support for 7 languages (`EN`, `KO`, `ZH`, `JA`, `DE`, `FR`, `ES`).
- Automated GitHub Actions release workflow with `.dmg` and `.zip` packaging.

[Unreleased]: https://github.com/badugisoft/antigravity-quota/compare/v1.4.0...HEAD
[1.4.0]: https://github.com/badugisoft/antigravity-quota/compare/v1.3.1...v1.4.0
[1.3.1]: https://github.com/badugisoft/antigravity-quota/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/badugisoft/antigravity-quota/compare/v1.2.3...v1.3.0
[1.2.3]: https://github.com/badugisoft/antigravity-quota/compare/v1.2.2...v1.2.3
[1.2.2]: https://github.com/badugisoft/antigravity-quota/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/badugisoft/antigravity-quota/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/badugisoft/antigravity-quota/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/badugisoft/antigravity-quota/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/badugisoft/antigravity-quota/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/badugisoft/antigravity-quota/releases/tag/v1.0.0
