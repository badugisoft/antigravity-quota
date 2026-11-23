# Antigravity Quota — Technical Notes & Pitfalls

Detailed implementation notes and macOS-specific constraints for maintainers and AI agents.

## A. macOS TCC & Sandbox Security (Avoid Privacy Popups)
- **Never access `~/Library/Group Containers` or cross-container paths in ad-hoc builds.**
  - On macOS Sonoma and Sequoia, accessing cross-container directories without Apple Developer Team Provisioning Profiles triggers a persistent TCC privacy prompt on every launch.
- **Current Secure Architecture**:
  - The host app writes data to `~/Library/Application Support/AntigravityQuota/shared_quota.json`.
  - The sandboxed widget extension reads this file via `com.apple.security.temporary-exception.files.home-relative-path.read-only = /Library/Application Support/AntigravityQuota/`.

## B. WidgetKit Codesigning & PluginKit Registration
- **Never use `codesign --deep`** on `Antigravity Quota.app`; it strips the inner `.appex` sandbox entitlement and causes `pkd` / `chronod` rejection.
- **Inside-Out Signing & Hardened Runtime**:
  1. Sign `AntigravityQuotaWidget.appex` first using `scripts/entitlements/widget.entitlements`.
  2. Sign the outer `Antigravity Quota.app` second using `scripts/entitlements/app.entitlements`.
  3. `make build` (`scripts/build_app.sh`) automatically detects a local `Developer ID Application` certificate (`--options runtime --timestamp`) and falls back to ad-hoc (`-`) when none is available.
  4. `make package` (`scripts/package_release.sh`) notarizes and staples both the `.app` (for `.zip`) and `.dmg` when `APPLE_ID`, `APPLE_TEAM_ID`, and `APPLE_APP_PASSWORD` are provided.
- **Linker Entry Point for SwiftPM**:
  - `Package.swift` must keep `.unsafeFlags(["-Xlinker", "-e", "-Xlinker", "_NSExtensionMain"])` for `AntigravityQuotaWidgetExtension`.

## C. Widget UI & Visual Style
- Always use `containerBackground(.regularMaterial, for: .widget)` (avoid `Color.clear` or opaque `windowBackgroundColor`).
- `AntigravityQuotaWidgetBundle.swift` must declare `.contentMarginsDisabled()` for borderless desktop widgets.

## D. Adaptive Polling & AI Activity Detection
- Do **not** accelerate polling to 15s solely based on window focus.
- When quota consumption is detected (`didQuotaDecrease`), polling accelerates to **15s** for a **3-minute cooldown window**, then steps down to **60s (Idle)**. Window activation triggers a single immediate sync.

## E. Test Suite & Asset Safety
- Running `make test` (`swift test`) must not dirty `assets/*.png`. `testGenerateScreenshots()` in `QuotaModelTests.swift` is gated behind `GENERATE_SCREENSHOTS=1` (`make screenshots`).

## F. Remote SSH Fallback
- When Antigravity is not detected locally, `QuotaService` falls back to `RemoteSSHQuotaService` if enabled using one-shot `/usr/bin/ssh` (`-q`, `BatchMode=yes`, `ConnectTimeout=5`) rather than persistent `ssh -L` tunnels.

## G. 100% Full Quota & Rolling Window Countdown Suppression
- When `QuotaBucket.isFull` (`remainingFraction >= 1.0 - 0.0001`), `timeRemaining` returns `0`, `formattedTimeRemaining` shows `quotaUnused`, and scheduled reset times are hidden to prevent rolling-window reset jumps.

## H. Local Process & Listening Port Discovery
- `LanguageServerDiscovery` uses `/usr/sbin/lsof -iTCP -sTCP:LISTEN -n -P -a -p <pid>` (with `netstat` fallback) because `netstat` in child processes can omit PID mappings on macOS.
- CSRF tokens are extracted from `--csrf_token` CLI flags first, then from process environment `ANTIGRAVITY_SERVER_CSRF_TOKEN` (`ps eww -p <pid>` / `/proc/$PID/environ`).
- Candidate endpoints must preserve their protocol scheme (`http` vs `https`).

## I. Dynamic Group & Bucket Rendering
- Never hardcode model group lookups or fixed enum cases (`MenuBarGaugeSource`). Iterate server-returned `groups` and `group.orderedBuckets` via `QuotaGroup.dynamicAbbreviations(for:)` and `QuotaSnapshot.resolveGaugeBucket`.

## J. Dynamic Popover Sizing & Dismissal
- `MenuBarPopoverView` uses `.fixedSize(horizontal: false, vertical: true)` and `AppDelegate` clamps `maxY` via `clampPopoverWindowToScreen()` so resizing never pushes the popover above the menu bar.
- `AppDelegate` configures `popover.behavior = .applicationDefined` with `NSPopoverDelegate` (`popoverWillShow`/`popoverDidShow`/`popoverDidClose`) to avoid `.transient` state corruption during opening animations, and omits `window.makeKeyAndOrderFront(nil)` so background refreshes do not steal focus.
