import Cocoa
import Foundation
import Combine
import AntigravityQuotaCore

/// Main ViewModel managing quota state, timers, adaptive intervals, and menu bar summary text.
@MainActor
public final class QuotaViewModel: ObservableObject {
    @Published public var groups: [QuotaGroup] = []
    @Published public var quotaDescription: String?
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var lastUpdated: Date?
    @Published public var isServerOnline: Bool = false
    @Published public var currentNow: Date = Date()
    @Published public var isAntigravityActive: Bool = false
    
    // Compact mode preference persisted in UserDefaults
    @Published public var isCompactMode: Bool {
        didSet {
            UserDefaults.standard.set(isCompactMode, forKey: "isCompactMode")
        }
    }
    
    // Menu bar summary title
    @Published public var menuBarSummary: String = "✦ AGY ..."
    
    private let service: QuotaServiceProtocol
    public let localization: LocalizationManager
    private var refreshTimer: AnyCancellable?
    private var countdownTimer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    private let antigravityBundleId = "com.google.antigravity"
    
    public init(
        service: QuotaServiceProtocol = QuotaService.shared,
        localization: LocalizationManager? = nil
    ) {
        self.service = service
        self.localization = localization ?? LocalizationManager.shared
        self.isCompactMode = UserDefaults.standard.bool(forKey: "isCompactMode")
        
        checkActiveApplication()
        setupWorkspaceMonitoring()
        setupLocalizationObserver()
        startTimers()
        
        Task {
            await refresh()
        }
    }
    
    deinit {
        refreshTimer?.cancel()
        countdownTimer?.cancel()
        cancellables.removeAll()
    }
    
    // MARK: - Workspace Monitoring
    
    private func setupWorkspaceMonitoring() {
        let center = NSWorkspace.shared.notificationCenter
        
        // Detect application activation (window focus switch)
        center.publisher(for: NSWorkspace.didActivateApplicationNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let self = self else { return }
                if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                    let isActive = (app.bundleIdentifier == self.antigravityBundleId || app.localizedName == "Antigravity")
                    if self.isAntigravityActive != isActive {
                        self.isAntigravityActive = isActive
                        self.restartRefreshTimer()
                        if isActive {
                            Task { await self.refresh() }
                        }
                    }
                }
            }
            .store(in: &cancellables)
            
        // Detect application termination
        center.publisher(for: NSWorkspace.didTerminateApplicationNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let self = self else { return }
                if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                    if app.bundleIdentifier == self.antigravityBundleId || app.localizedName == "Antigravity" {
                        self.isAntigravityActive = false
                        self.isServerOnline = false
                        self.updateMenuBarSummary()
                        self.restartRefreshTimer()
                        
                        let snapshot = QuotaSnapshot(
                            timestamp: Date(),
                            isOnline: false,
                            groups: self.groups,
                            description: self.quotaDescription,
                            languageCode: self.localization.currentLanguage.rawValue
                        )
                        QuotaDataStore.shared.save(snapshot: snapshot)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupLocalizationObserver() {
        localization.$currentLanguage
            .receive(on: RunLoop.main)
            .sink { [weak self] lang in
                guard let self = self else { return }
                self.updateMenuBarSummary()
                let snapshot = QuotaSnapshot(
                    timestamp: Date(),
                    isOnline: self.isServerOnline,
                    groups: self.groups,
                    description: self.quotaDescription,
                    languageCode: lang.rawValue
                )
                QuotaDataStore.shared.save(snapshot: snapshot)
            }
            .store(in: &cancellables)
    }
    
    private func checkActiveApplication() {
        if let frontApp = NSWorkspace.shared.frontmostApplication {
            isAntigravityActive = (frontApp.bundleIdentifier == antigravityBundleId || frontApp.localizedName == "Antigravity")
        }
    }
    
    // MARK: - Timers & Adaptive Polling
    
    public func startTimers() {
        // Update currentNow every second for live countdown clocks
        countdownTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                self?.currentNow = now
            }
        
        restartRefreshTimer()
    }
    
    private func restartRefreshTimer() {
        refreshTimer?.cancel()
        
        // 15 seconds when working in Antigravity, 60 seconds when idle / running other apps
        let interval: TimeInterval = isAntigravityActive ? 15.0 : 60.0
        
        refreshTimer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.refresh()
                }
            }
    }
    
    public func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await service.fetchQuotaSummary()
            self.groups = data.groups
            self.quotaDescription = data.description
            self.lastUpdated = Date()
            self.isServerOnline = true
            updateMenuBarSummary()
            
            let snapshot = QuotaSnapshot(
                timestamp: Date(),
                isOnline: true,
                groups: data.groups,
                description: data.description,
                languageCode: self.localization.currentLanguage.rawValue
            )
            QuotaDataStore.shared.save(snapshot: snapshot)
        } catch {
            self.errorMessage = error.localizedDescription
            self.isServerOnline = false
            updateMenuBarSummary()
            
            let snapshot = QuotaSnapshot(
                timestamp: Date(),
                isOnline: false,
                groups: self.groups,
                description: self.quotaDescription,
                languageCode: self.localization.currentLanguage.rawValue
            )
            QuotaDataStore.shared.save(snapshot: snapshot)
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Accessors
    
    public var geminiGroup: QuotaGroup? {
        groups.first(where: { $0.displayName.localizedCaseInsensitiveContains("gemini") })
    }
    
    public var claudeGptGroup: QuotaGroup? {
        groups.first(where: {
            $0.displayName.localizedCaseInsensitiveContains("claude") ||
            $0.displayName.localizedCaseInsensitiveContains("gpt")
        })
    }
    
    // MARK: - Menu Bar Summary
    
    private func updateMenuBarSummary() {
        if !isServerOnline {
            if groups.isEmpty {
                menuBarSummary = localization.string(.menuBarWaiting)
            } else {
                // Keep previous quota values but prepend pause icon
                var parts: [String] = []
                if let gGroup = geminiGroup, let bucket = gGroup.fiveHourBucket {
                    parts.append("G:\(bucket.remainingPercentage)%")
                }
                if let cGroup = claudeGptGroup, let bucket = cGroup.fiveHourBucket {
                    parts.append("C:\(bucket.remainingPercentage)%")
                }
                menuBarSummary = "⏸️ " + parts.joined(separator: " · ")
            }
            return
        }
        
        var parts: [String] = []
        var isAnyLow = false
        
        if let gGroup = geminiGroup, let bucket = gGroup.fiveHourBucket {
            let pct = bucket.remainingPercentage
            parts.append("G:\(pct)%")
            if pct < 20 { isAnyLow = true }
        }
        
        if let cGroup = claudeGptGroup, let bucket = cGroup.fiveHourBucket {
            let pct = bucket.remainingPercentage
            parts.append("C:\(pct)%")
            if pct < 20 { isAnyLow = true }
        }
        
        let prefix = isAnyLow ? "⚠️ " : "✦ "
        if parts.isEmpty {
            menuBarSummary = "\(prefix)AGY"
        } else {
            menuBarSummary = "\(prefix)\(parts.joined(separator: " · "))"
        }
    }
}
