import XCTest
import SwiftUI
@testable import AntigravityQuota
@testable import AntigravityQuotaCore

final class QuotaModelTests: XCTestCase {
    
    let sampleJSON = """
    {
      "response": {
        "groups": [
          {
            "displayName": "Gemini Models",
            "description": "Models within this group: Gemini Flash, Gemini Pro",
            "buckets": [
              {
                "bucketId": "gemini-weekly",
                "displayName": "Weekly Limit Remaining",
                "description": "You have used some of your weekly limit, it will fully refresh in 1 day, 21 hours.",
                "window": "weekly",
                "remainingFraction": 0.74248415,
                "resetTime": "2026-09-14T15:42:50Z"
              },
              {
                "bucketId": "gemini-5h",
                "displayName": "Five Hour Limit Remaining",
                "description": "You have used some of your 5-hour limit, it will fully refresh in 4 hours, 53 minutes.",
                "window": "5h",
                "remainingFraction": 0.9830422,
                "resetTime": "2026-09-12T22:57:18Z"
              }
            ]
          },
          {
            "displayName": "Claude and GPT models",
            "description": "Models within this group: Claude Opus, Claude Sonnet, GPT-OSS",
            "buckets": [
              {
                "bucketId": "3p-weekly",
                "displayName": "Weekly Limit Remaining",
                "window": "weekly",
                "remainingFraction": 0.33202305,
                "resetTime": "2026-09-17T22:42:07Z"
              },
              {
                "bucketId": "3p-5h",
                "displayName": "Five Hour Limit Remaining",
                "window": "5h",
                "remainingFraction": 1.0,
                "resetTime": "2026-09-12T23:03:40Z"
              }
            ]
          }
        ],
        "description": "Test summary"
      }
    }
    """
    
    func testJSONDecoding() throws {
        let data = sampleJSON.data(using: .utf8)!
        let envelope = try JSONDecoder().decode(QuotaEnvelope.self, from: data)
        let response = try XCTUnwrap(envelope.response)
        
        XCTAssertEqual(response.groups.count, 2)
        
        let geminiGroup = try XCTUnwrap(response.groups.first(where: { $0.displayName.contains("Gemini") }))
        let fiveHour = try XCTUnwrap(geminiGroup.fiveHourBucket)
        XCTAssertEqual(fiveHour.remainingPercentage, 98)
        XCTAssertEqual(fiveHour.usedPercentage, 2)
        
        let weekly = try XCTUnwrap(geminiGroup.weeklyBucket)
        XCTAssertEqual(weekly.remainingPercentage, 74)
        XCTAssertEqual(weekly.usedPercentage, 26)
        
        let claudeGroup = try XCTUnwrap(response.groups.first(where: { $0.displayName.contains("Claude") }))
        let claudeWeekly = try XCTUnwrap(claudeGroup.weeklyBucket)
        XCTAssertEqual(claudeWeekly.remainingPercentage, 33)
        XCTAssertEqual(claudeWeekly.usedPercentage, 67)
    }
    
    func testResetCountdownFormattingMultiLanguage() {
        let bucket = QuotaBucket(
            bucketId: "test",
            displayName: "Test",
            remainingFraction: 0.5,
            resetTime: "2026-09-13T10:00:00Z"
        )
        
        let formatter = ISO8601DateFormatter()
        let fakeNow = formatter.date(from: "2026-09-13T08:30:00Z")!
        
        XCTAssertEqual(bucket.formattedTimeRemaining(from: fakeNow, language: .en), "1h 30m left")
        XCTAssertEqual(bucket.formattedTimeRemaining(from: fakeNow, language: .ko), "1시간 30분 남음")
        XCTAssertEqual(bucket.formattedTimeRemaining(from: fakeNow, language: .zh), "剩余 1小时 30分")
        XCTAssertEqual(bucket.formattedTimeRemaining(from: fakeNow, language: .ja), "残り 1時間 30分")
        XCTAssertEqual(bucket.formattedTimeRemaining(from: fakeNow, language: .de), "Noch 1 Std. 30 Min.")
        XCTAssertEqual(bucket.formattedTimeRemaining(from: fakeNow, language: .fr), "Reste 1h 30min")
        XCTAssertEqual(bucket.formattedTimeRemaining(from: fakeNow, language: .es), "Quedan 1h 30min")
    }
    
    @MainActor
    func testLocalizationManagerAllLanguages() {
        let manager = LocalizationManager()
        XCTAssertEqual(AppLanguage.allCases.count, 7)
        for lang in AppLanguage.allCases {
            manager.currentLanguage = lang
            XCTAssertFalse(manager.string(.refresh).isEmpty)
            XCTAssertFalse(manager.string(.quit).isEmpty)
            XCTAssertFalse(manager.string(.statusOffline).isEmpty)
            XCTAssertFalse(manager.string(.lastUpdated(time: "12:00")).isEmpty)
        }
    }
    
    func testQuotaSnapshotAndDataStore() {
        let snapshot = QuotaSnapshot.placeholder
        XCTAssertNotNil(snapshot.geminiGroup)
        XCTAssertNotNil(snapshot.claudeGptGroup)
        XCTAssertTrue(snapshot.isOnline)
        XCTAssertNotNil(snapshot.nearestResetDate)
        
        // Test save & load
        QuotaDataStore.shared.save(snapshot: snapshot)
        let loaded = QuotaDataStore.shared.loadLatestSnapshot()
        XCTAssertEqual(loaded.isOnline, snapshot.isOnline)
        XCTAssertEqual(loaded.groups.count, snapshot.groups.count)
    }
    
    func testLocalizedTimeFormatting() {
        let date = Date(timeIntervalSince1970: 1600000000) // 2020-09-13
        for lang in AppLanguage.allCases {
            let formattedMedium = date.formattedTime(for: lang)
            let formattedShort = date.formattedShortTime(for: lang)
            XCTAssertFalse(formattedMedium.isEmpty)
            XCTAssertFalse(formattedShort.isEmpty)
        }
    }
    
    @MainActor
    func testMeasureSizes() {
        let fiveHour = QuotaBucket(bucketId: "5h", displayName: "5h", window: "5h", remainingFraction: 0.8, resetTime: "2026-09-13T12:00:00Z")
        let weekly = QuotaBucket(bucketId: "weekly", displayName: "weekly", window: "weekly", remainingFraction: 0.5, resetTime: "2026-09-17T12:00:00Z")
        let g1 = QuotaGroup(displayName: "Gemini Models", description: "Models: Flash, Pro", buckets: [fiveHour, weekly])
        let g2 = QuotaGroup(displayName: "Claude and GPT models", description: "Models: Sonnet, Opus", buckets: [fiveHour, weekly])
        
        let now = Date()
        for lang in AppLanguage.allCases {
            let card1 = QuotaGroupCompactCardView(group: g1, currentNow: now, language: lang)
            let cardSz1 = NSHostingController(rootView: card1).sizeThatFits(in: NSSize(width: 316, height: 1000))
            XCTAssertLessThanOrEqual(cardSz1.height, 90.0, "Language \(lang.rawValue) compact card 1 exceeded expected height: \(cardSz1.height)")

            let card2 = QuotaGroupCompactCardView(group: g2, currentNow: now, language: lang)
            let cardSz2 = NSHostingController(rootView: card2).sizeThatFits(in: NSSize(width: 316, height: 1000))
            XCTAssertLessThanOrEqual(cardSz2.height, 90.0, "Language \(lang.rawValue) compact card 2 exceeded expected height: \(cardSz2.height)")
        }
        
        let cardStd = QuotaGroupCardView(group: g1, currentNow: now, language: .en)
        let hcCardStd = NSHostingController(rootView: cardStd)
        let stdCardSize = hcCardStd.sizeThatFits(in: NSSize(width: 316, height: 1000))
        XCTAssertGreaterThan(stdCardSize.height, 150.0)
    }
    
    @MainActor
    func testQuotaBurstPollingActivationAndExpiry() async {
        let b1 = QuotaBucket(bucketId: "5h", displayName: "5h", window: "5h", remainingFraction: 0.80, resetTime: "2026-09-13T12:00:00Z")
        let g1 = QuotaGroup(displayName: "Gemini Models", description: "Models: Flash, Pro", buckets: [b1])
        
        final class BurstMockService: QuotaServiceProtocol {
            var currentGroups: [QuotaGroup]
            init(groups: [QuotaGroup]) { self.currentGroups = groups }
            func fetchQuotaSummary() async throws -> QuotaResponseData {
                return QuotaResponseData(groups: currentGroups)
            }
        }
        
        let mockService = BurstMockService(groups: [g1])
        let vm = QuotaViewModel(service: mockService)
        
        // Initial state: ensure idle
        vm.deactivateBurstMode()
        XCTAssertFalse(vm.isAntigravityActive)
        
        // Same quota -> burst remains inactive
        await vm.refresh()
        XCTAssertFalse(vm.isAntigravityActive)
        
        // Quota decreases (AI consumed quota) -> burst activates
        let bDecreased = QuotaBucket(bucketId: "5h", displayName: "5h", window: "5h", remainingFraction: 0.78, resetTime: "2026-09-13T12:00:00Z")
        mockService.currentGroups = [QuotaGroup(displayName: "Gemini Models", description: "Models: Flash, Pro", buckets: [bDecreased])]
        
        await vm.refresh()
        XCTAssertTrue(vm.isAntigravityActive)
        XCTAssertNotNil(vm.lastAIActivityDate)
        
        // Deactivate burst mode
        vm.deactivateBurstMode()
        XCTAssertFalse(vm.isAntigravityActive)
    }
    
    @MainActor
    func testGenerateScreenshots() throws {
        guard ProcessInfo.processInfo.environment["GENERATE_SCREENSHOTS"] == "1" else {
            print(">>> Skipping screenshot regeneration (set GENERATE_SCREENSHOTS=1 to regenerate)")
            return
        }
        
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        
        let now = Date()
        let fakeNow = now
        let cal = Calendar.current
        
        let gFiveReset = cal.date(byAdding: .minute, value: 183, to: fakeNow)! // 3h 3m
        let gWeeklyReset = cal.date(byAdding: .minute, value: 2590, to: fakeNow)! // 1d 19h 10m
        let cFiveReset = cal.date(byAdding: .minute, value: 296, to: fakeNow)! // 4h 56m
        let cWeeklyReset = cal.date(byAdding: .minute, value: 7320, to: fakeNow)! // 5d 2h
        
        let iso = ISO8601DateFormatter()
        let gFive = QuotaBucket(bucketId: "5h", displayName: "5-Hour Reset", window: "5h", remainingFraction: 0.75, resetTime: iso.string(from: gFiveReset))
        let gWeekly = QuotaBucket(bucketId: "weekly", displayName: "Weekly Reset", window: "weekly", remainingFraction: 0.70, resetTime: iso.string(from: gWeeklyReset))
        let geminiGroup = QuotaGroup(displayName: "Gemini Models", description: "Gemini Flash, Gemini Pro", buckets: [gFive, gWeekly])
        
        let cFive = QuotaBucket(bucketId: "5h", displayName: "5-Hour Reset", window: "5h", remainingFraction: 1.0, resetTime: iso.string(from: cFiveReset))
        let cWeekly = QuotaBucket(bucketId: "weekly", displayName: "Weekly Reset", window: "weekly", remainingFraction: 0.33, resetTime: iso.string(from: cWeeklyReset))
        let claudeGroup = QuotaGroup(displayName: "Claude and GPT models", description: "Claude Opus, Claude Sonnet, GPT-OSS", buckets: [cFive, cWeekly])
        
        final class MockService: QuotaServiceProtocol {
            let groups: [QuotaGroup]
            init(groups: [QuotaGroup]) { self.groups = groups }
            func fetchQuotaSummary() async throws -> QuotaResponseData {
                return QuotaResponseData(groups: groups)
            }
        }
        
        let mockService = MockService(groups: [geminiGroup, claudeGroup])
        let vm = QuotaViewModel(service: mockService)
        vm.groups = [geminiGroup, claudeGroup]
        vm.isServerOnline = true
        vm.isAntigravityActive = true
        vm.currentNow = fakeNow
        vm.lastUpdated = fakeNow
        vm.isLoading = false
        vm.localization.currentLanguage = .en
        
        let assetsDir = URL(fileURLWithPath: "/Users/badugiss/work/badugisoft/antigravity-quota/assets")
        
        // 1. Render Dark Menu Bar Summary
        let menuBarText = "✦ G:75% · C:100%"
        let textFont = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: textFont,
            .foregroundColor: NSColor.white
        ]
        let attrString = NSAttributedString(string: menuBarText, attributes: textAttributes)
        let textSize = attrString.size()
        let barRect = NSRect(x: 0, y: 0, width: ceil(textSize.width) + 24, height: 26)
        
        let barImage = NSImage(size: barRect.size)
        barImage.lockFocus()
        NSColor.black.setFill()
        barRect.fill()
        attrString.draw(at: NSPoint(x: 12, y: (barRect.height - textSize.height) / 2))
        barImage.unlockFocus()
        
        if let tiff = barImage.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff), let png = rep.representation(using: .png, properties: [:]) {
            try png.write(to: assetsDir.appendingPathComponent("menubar_summary.png"))
            print(">>> Saved menubar_summary.png")
        }
        
        // Setup anchor window at top of screen
        let screenRect = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let topBarWindow = NSWindow(
            contentRect: NSRect(x: screenRect.midX - 100, y: screenRect.maxY - 30, width: 200, height: 28),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        topBarWindow.isOpaque = false
        topBarWindow.backgroundColor = .clear
        topBarWindow.orderFront(nil)
        
        let anchorView = NSView(frame: NSRect(x: 80, y: 2, width: 40, height: 24))
        topBarWindow.contentView?.addSubview(anchorView)
        
        // Helper to capture popover window
        func capturePopover(isCompact: Bool, filename: String) throws {
            vm.isCompactMode = isCompact
            vm.isServerOnline = true
            vm.isAntigravityActive = true
            vm.isLoading = false
            
            let popover = NSPopover()
            popover.contentSize = NSSize(width: 340, height: isCompact ? 275 : 470)
            popover.behavior = .transient
            popover.contentViewController = NSHostingController(rootView: MenuBarPopoverView(viewModel: vm))
            
            popover.show(relativeTo: anchorView.bounds, of: anchorView, preferredEdge: .minY)
            
            if let win = popover.contentViewController?.view.window {
                win.makeKeyAndOrderFront(nil)
                if let effectView = win.contentView?.superview as? NSVisualEffectView {
                    effectView.state = .active
                }
            }
            
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.35))
            
            if let win = popover.contentViewController?.view.window {
                let winID = CGWindowID(win.windowNumber)
                if let cgImage = CGWindowListCreateImage(.null, .optionIncludingWindow, winID, [.bestResolution]) {
                    let rep = NSBitmapImageRep(cgImage: cgImage)
                    if let data = rep.representation(using: .png, properties: [:]) {
                        try data.write(to: assetsDir.appendingPathComponent(filename))
                        print(">>> Saved \(filename), size: \(cgImage.width)x\(cgImage.height)")
                    }
                }
            }
            
            popover.performClose(nil)
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.2))
        }
        
        try capturePopover(isCompact: false, filename: "popover_standard.png")
        try capturePopover(isCompact: true, filename: "popover_compact.png")
        
        // 3. Render macOS Widgets (Small 1x1 & Medium 1x2)
        let snapshot = QuotaSnapshot(
            timestamp: fakeNow,
            isOnline: true,
            groups: [geminiGroup, claudeGroup],
            description: "Antigravity Pro Quota"
        )
        
        func captureWidget<V: View>(view: V, size: NSSize, filename: String) throws {
            let win = NSWindow(
                contentRect: NSRect(x: 100, y: 100, width: size.width + 20, height: size.height + 20),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            win.isOpaque = false
            win.backgroundColor = .clear
            win.appearance = NSAppearance(named: .darkAqua)
            let controller = NSHostingController(rootView:
                view
                    .frame(width: size.width, height: size.height)
                    .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color(nsColor: NSColor(calibratedRed: 0.18, green: 0.18, blue: 0.20, alpha: 0.95))))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 4)
                    .padding(10)
                    .environment(\.colorScheme, .dark)
            )
            win.contentViewController = controller
            win.orderFront(nil)
            win.makeKeyAndOrderFront(nil)
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.35))
            
            let winID = CGWindowID(win.windowNumber)
            if let cgImage = CGWindowListCreateImage(.null, .optionIncludingWindow, winID, [.bestResolution]) {
                let rep = NSBitmapImageRep(cgImage: cgImage)
                if let data = rep.representation(using: .png, properties: [:]) {
                    try data.write(to: assetsDir.appendingPathComponent(filename))
                    print(">>> Saved \(filename), size: \(cgImage.width)x\(cgImage.height)")
                }
            }
            win.orderOut(nil)
        }
        
        try captureWidget(
            view: SmallQuotaWidgetView(snapshot: snapshot, date: fakeNow, language: .en),
            size: NSSize(width: 155, height: 155),
            filename: "widget_small.png"
        )
        
        try captureWidget(
            view: MediumQuotaWidgetView(snapshot: snapshot, date: fakeNow, language: .en),
            size: NSSize(width: 325, height: 155),
            filename: "widget_medium.png"
        )
        
        topBarWindow.orderOut(nil)
    }
    
    // MARK: - New Feature Unit Tests
    
    func testQuotaBucketRefillDetectionAndCopy() {
        let now = Date()
        let pastDate = now.addingTimeInterval(-60) // 1 minute ago
        let futureDate = now.addingTimeInterval(3600) // 1 hour later
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        // 1. Bucket whose resetTime has already passed and quota was 20%
        let expiredBucket = QuotaBucket(
            bucketId: "test-5h",
            displayName: "Test 5h",
            window: "5h",
            remainingFraction: 0.2,
            resetTime: formatter.string(from: pastDate)
        )
        XCTAssertTrue(expiredBucket.isRefilled(at: now), "Bucket with past resetDate should be marked refilled")
        
        let refilled = expiredBucket.refilledCopy()
        XCTAssertEqual(refilled.remainingFraction, 1.0)
        XCTAssertEqual(refilled.remainingPercentage, 100)
        XCTAssertNil(refilled.resetTime)
        
        // 2. Bucket whose resetTime is in the future
        let pendingBucket = QuotaBucket(
            bucketId: "test-future",
            displayName: "Test Future",
            window: "5h",
            remainingFraction: 0.5,
            resetTime: formatter.string(from: futureDate)
        )
        XCTAssertFalse(pendingBucket.isRefilled(at: now), "Bucket with future resetDate should NOT be marked refilled")
        
        // 3. Bucket already at 100%
        let fullBucket = QuotaBucket(
            bucketId: "test-full",
            displayName: "Test Full",
            window: "5h",
            remainingFraction: 1.0,
            resetTime: formatter.string(from: pastDate)
        )
        XCTAssertFalse(fullBucket.isRefilled(at: now), "Bucket already at 100% does not need refill")
    }
    
    func testAppSettingsDefaultsAndPersistence() {
        let settings = AppSettings.shared
        
        // Check default states
        XCTAssertTrue(settings.showMenuBarText)
        XCTAssertEqual(settings.menuBarGaugeSource, .gemini5h, "Default gauge source must be gemini5h")
        XCTAssertTrue(settings.notifyQuotaRefilled)
        XCTAssertTrue(settings.notifyFiveHourReset)
        XCTAssertTrue(settings.notifyWeeklyReset)
        
        // Test toggles
        settings.showMenuBarText = false
        XCTAssertFalse(settings.showMenuBarText)
        settings.showMenuBarText = true
        XCTAssertTrue(settings.showMenuBarText)
        
        settings.menuBarGaugeSource = .claudeWeekly
        XCTAssertEqual(settings.menuBarGaugeSource, .claudeWeekly)
        settings.menuBarGaugeSource = .gemini5h
        XCTAssertEqual(settings.menuBarGaugeSource, .gemini5h)
        
        // Remote SSH settings
        settings.enableRemoteSSH = true
        XCTAssertTrue(settings.enableRemoteSSH)
        settings.enableRemoteSSH = false
        XCTAssertFalse(settings.enableRemoteSSH)
        
        settings.remoteSSHHost = "user@test-host"
        XCTAssertEqual(settings.remoteSSHHost, "user@test-host")
        
        settings.remoteSSHInterval = 120
        XCTAssertEqual(settings.remoteSSHInterval, 120)
    }
    
    func testMenuBarIconRenderer() {
        let renderer = MenuBarIconRenderer.shared
        
        let onlineIcon = renderer.renderIcon(remainingFraction: 0.75, isOnline: true)
        XCTAssertEqual(onlineIcon.size.width, 18)
        XCTAssertEqual(onlineIcon.size.height, 18)
        XCTAssertTrue(onlineIcon.isTemplate)
        
        let offlineIcon = renderer.renderIcon(remainingFraction: 0.20, isOnline: false)
        XCTAssertEqual(offlineIcon.size.width, 18)
        XCTAssertEqual(offlineIcon.size.height, 18)
        XCTAssertTrue(offlineIcon.isTemplate)
    }
    
    func testLocalizedStringsSettingsAndNotificationsAllLanguages() {
        for lang in AppLanguage.allCases {
            let settingsTitle = LocalizedStringKey.settings.string(for: lang)
            XCTAssertFalse(settingsTitle.isEmpty, "Missing settings translation for \(lang)")
            
            let general = LocalizedStringKey.generalTab.string(for: lang)
            XCTAssertFalse(general.isEmpty, "Missing generalTab translation for \(lang)")
            
            let notifications = LocalizedStringKey.notificationsTab.string(for: lang)
            XCTAssertFalse(notifications.isEmpty, "Missing notificationsTab translation for \(lang)")
            
            let gaugeTarget = LocalizedStringKey.menuBarGaugeSource.string(for: lang)
            XCTAssertFalse(gaugeTarget.isEmpty, "Missing menuBarGaugeSource translation for \(lang)")
            
            let g5h = LocalizedStringKey.gaugeGemini5h.string(for: lang)
            XCTAssertFalse(g5h.isEmpty, "Missing gaugeGemini5h translation for \(lang)")
            
            let launch = LocalizedStringKey.launchAtLogin.string(for: lang)
            XCTAssertFalse(launch.isEmpty, "Missing launchAtLogin translation for \(lang)")
            
            let notifyRefilled = LocalizedStringKey.notificationTitleRefilled.string(for: lang)
            XCTAssertFalse(notifyRefilled.isEmpty, "Missing notificationTitleRefilled for \(lang)")
            
            let body = LocalizedStringKey.notificationBodyRefilled(model: "Gemini", window: "5h").string(for: lang)
            XCTAssertTrue(body.contains("Gemini"), "Body should interpolate model name for \(lang)")
            
            // Remote SSH Keys
            XCTAssertFalse(LocalizedStringKey.remoteTab.string(for: lang).isEmpty, "Missing remoteTab for \(lang)")
            XCTAssertFalse(LocalizedStringKey.enableRemoteSSH.string(for: lang).isEmpty, "Missing enableRemoteSSH for \(lang)")
            XCTAssertFalse(LocalizedStringKey.remoteSSHHost.string(for: lang).isEmpty, "Missing remoteSSHHost for \(lang)")
            XCTAssertFalse(LocalizedStringKey.remoteSSHInterval.string(for: lang).isEmpty, "Missing remoteSSHInterval for \(lang)")
            XCTAssertFalse(LocalizedStringKey.testConnection.string(for: lang).isEmpty, "Missing testConnection for \(lang)")
            XCTAssertFalse(LocalizedStringKey.sshNotice.string(for: lang).isEmpty, "Missing sshNotice for \(lang)")
        }
    }
}
