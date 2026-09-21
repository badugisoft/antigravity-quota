# Antigravity Quota — Agent & Contributor Guidelines

This document provides essential architecture context, operating rules, user instructions, and technical pitfalls for any AI agent or developer working on this repository.

---

## 1. Operating Rules & User Directives

1. **Git Commit & Push Policy (CRITICAL)**:
   - **NEVER execute `git commit` or `git push` automatically without asking.**
   - Even if shell command permissions are granted, always present the modified files and proposed commit message to the user first and wait for explicit confirmation.
2. **Communication & Internationalization**:
   - Communicate in the **user's language of choice** (mirror the language used in prompts, e.g., English, Korean, etc.).
   - Preserve application multi-language support (7 languages: `EN`, `KO`, `ZH`, `JA`, `DE`, `FR`, `ES`) in code, UI, and localization dictionaries.
3. **No External Dependencies**:
   - The project strictly uses pure Swift / SwiftUI / AppKit / WidgetKit. Do not introduce third-party CocoaPods, Carthage, or SPM packages.
4. **Local Task Completion & Installation**:
   - Whenever code changes or tasks are completed locally, always execute `./scripts/build_app.sh` to compile, package, install to `/Applications`, and launch the updated app so the user can test immediately.

---

## 2. Architecture Overview

The repository is structured into three distinct Swift targets:

```
Sources/
├── AntigravityQuotaCore/      # Modular core library target
│   ├── Models/               # Quota models, envelope parsing, snapshot structs
│   ├── Services/             # QuotaDataStore, LocalizationManager (7 languages)
│   └── Views/                # SmallQuotaWidgetView, MediumQuotaWidgetView, WidgetBackgroundModifier
├── AntigravityQuota/          # Main macOS menu bar application (LSUIElement = true)
│   ├── App/AppDelegate.swift # Status bar item (NSStatusItem) & NSPopover lifecycle
│   ├── Services/             # Process discovery (ps, netstat) & Connect-RPC client
│   └── ViewModels/           # QuotaViewModel (adaptive polling, burst management)
└── AntigravityQuotaWidget/    # WidgetKit Extension (.appex)
    ├── AntigravityQuotaWidgetBundle.swift # Widget definition (.systemSmall, .systemMedium)
    └── QuotaTimelineProvider.swift        # TimelineProvider reading from shared QuotaDataStore
```

---

## 3. Critical Technical Lessons & Pitfalls

### A. macOS TCC & Sandbox Security (Avoid Privacy Popups)
- **Never access `~/Library/Group Containers` or cross-container paths in ad-hoc builds.**
  - On macOS Sonoma and Sequoia, accessing cross-container directories without Apple Developer Team Provisioning Profiles triggers a persistent macOS TCC privacy prompt on every launch:
    `'Antigravity Quota'이(가) 다른 앱의 데이터에 접근하려고 합니다`
- **Current Secure Architecture**:
  - The host app writes data to `~/Library/Application Support/AntigravityQuota/shared_quota.json`.
  - The sandboxed widget extension reads this file using the entitlement:
    `com.apple.security.temporary-exception.files.home-relative-path.read-only = /Library/Application Support/AntigravityQuota/`
  - Zero TCC popups, zero sandbox violations.

### B. WidgetKit Codesigning & PluginKit Registration
- **Never use `codesign --deep`** on `Antigravity Quota.app`.
  - `--deep` overrides the inner `.appex` signature with the host app's entitlements, stripping the sandbox entitlement from the widget and causing macOS `pkd` / `chronod` to reject it.
- **Inside-Out Signing**:
  1. Sign `AntigravityQuotaWidget.appex` first using `scripts/entitlements/widget.entitlements`.
  2. Sign the outer `Antigravity Quota.app` second using `scripts/entitlements/app.entitlements`.
- **Linker Entry Point for SwiftPM**:
  - `Package.swift` must maintain `.unsafeFlags(["-Xlinker", "-e", "-Xlinker", "_NSExtensionMain"])` for `AntigravityQuotaWidgetExtension` to properly register as an Apple extension.

### C. Widget UI & Visual Style
- **Native Material Background**:
  - Always use `containerBackground(.regularMaterial, for: .widget)`.
  - Do not use `Color.clear` (which causes a pitch-black backing surface on desktop) or opaque `windowBackgroundColor` (which creates an inner box/card outline).
- **Borderless Native Margins**:
  - `AntigravityQuotaWidgetBundle.swift` must declare `.contentMarginsDisabled()` so the widget view blends borderless with macOS desktop widgets.

### D. Adaptive Polling & AI Activity Detection
- Do **NOT** accelerate polling to 15s solely based on window focus.
- **Quota-Driven Burst Polling**:
  - When quota consumption is detected (`didQuotaDecrease`), polling accelerates to **15 seconds** and remains active for a **3-minute cooldown window**.
  - When no AI activity occurs for 3 minutes, polling automatically steps down to **60 seconds (Idle)** to conserve battery and CPU.
  - Window activation triggers an immediate 1-time sync to catch changes instantly.

### E. Test Suite & Asset Safety
- Running `swift test` must NOT dirty `assets/*.png`.
- `testGenerateScreenshots()` in `QuotaModelTests.swift` is gated behind `GENERATE_SCREENSHOTS=1`.

### F. Remote SSH Fallback (Multi-Machine Support)
- When Antigravity is not detected locally, `QuotaService` falls back to `RemoteSSHQuotaService` if enabled.
- The remote query executes `/usr/bin/ssh` with `-q`, `BatchMode=yes`, and `ConnectTimeout=5` to extract PID, CSRF token, and listening port on the target machine and invoke `RetrieveUserQuotaSummary` via curl.
- Never use persistent background tunnel processes (`ssh -L`); direct one-shot RPC queries prevent port conflicts, daemon lifecycle leaks, and stale connections.

### G. 100% Full Quota & Rolling Window Countdown Suppression
- **Rolling Window Quota Reset Behavior**:
  - Antigravity 5h and weekly limits operate on a rolling window over consumed tokens.
  - When quota is 100% intact (`remainingFraction >= 1.0`), there is no consumed quota to recover. The backend calculates `resetTime` as `now + 5h` upon each request.
  - Repeated app activation or refresh would cause the countdown to reset back to 4h 59m, causing confusing jumps.
- **Suppression Strategy**:
  - `QuotaBucket.isFull` checks `remainingFraction >= 1.0 - 0.0001`.
  - When `isFull` is true:
    - `timeRemaining` returns 0.
    - `formattedTimeRemaining` displays `quotaUnused` ("미사용" / "Unused") instead of an active countdown.
    - Scheduled reset times (`resetDate.formattedShortTime`) are hidden in bucket rows.
    - `QuotaSnapshot.nearestResetDate` ignores full buckets so widget summary countdowns stay clean.

---

## 4. Common Commands

```bash
# Run unit & integration tests (fast, does not overwrite assets)
swift test

# Build release bundle, package .appex, sign, install to /Applications, and launch
./scripts/build_app.sh

# Regenerate documentation screenshots (only when UI intentionally changes)
GENERATE_SCREENSHOTS=1 swift test
```
