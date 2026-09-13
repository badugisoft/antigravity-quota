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
    
    // AI Burst Activity tracking
    public let burstDuration: TimeInterval = 180.0 // 3 minutes cooldown
    public private(set) var lastAIActivityDate: Date?
    
    private let antigravityBundleId = "com.google.antigravity"
    
    public init(
        service: QuotaServiceProtocol = QuotaService.shared,
        localization: LocalizationManager? = nil
    ) {
        self.service = service
        self.localization = localization ?? LocalizationManager.shared
        self.isCompactMode = UserDefaults.standard.bool(forKey: "isCompactMode")
        
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
        
        // When user switches to Antigravity, immediately trigger a refresh to catch new quota changes
        center.publisher(for: NSWorkspace.didActivateApplicationNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let self = self else { return }
                if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                    let isAntigravity = (app.bundleIdentifier == self.antigravityBundleId || app.localizedName == "Antigravity")
                    if isAntigravity {
                        Task { await self.refresh() }
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
                        self.deactivateBurstMode()
                        self.isServerOnline = false
                        self.updateMenuBarSummary()
                        
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
    
    // MARK: - Timers & Adaptive Polling
    
    public func startTimers() {
        // Update currentNow every second for live countdown clocks & check burst expiry
        countdownTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                guard let self = self else { return }
                self.currentNow = now
                
                // Automatically step down to idle (60s) after burst duration expires with no new AI quota usage
                if self.isAntigravityActive, let lastActivity = self.lastAIActivityDate {
                    if now.timeIntervalSince(lastActivity) >= self.burstDuration {
                        self.deactivateBurstMode()
                    }
                }
            }
        
        restartRefreshTimer()
    }
    
    public func activateBurstMode() {
        lastAIActivityDate = Date()
        if !isAntigravityActive {
            isAntigravityActive = true
            restartRefreshTimer()
        }
    }
    
    public func deactivateBurstMode() {
        lastAIActivityDate = nil
        if isAntigravityActive {
            isAntigravityActive = false
            restartRefreshTimer()
        }
    }
    
    private func restartRefreshTimer() {
        refreshTimer?.cancel()
        
        // 15 seconds during active AI work sessions, 60 seconds when idle
        let interval: TimeInterval = isAntigravityActive ? 15.0 : 60.0
        
        refreshTimer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.refresh()
                }
            }
    }
    
    public func didQuotaDecrease(from oldGroups: [QuotaGroup], to newGroups: [QuotaGroup]) -> Bool {
        guard !oldGroups.isEmpty, !newGroups.isEmpty else { return false }
        for oldGroup in oldGroups {
            guard let newGroup = newGroups.first(where: { $0.displayName == oldGroup.displayName }) else { continue }
            for oldBucket in oldGroup.buckets {
                guard let newBucket = newGroup.buckets.first(where: { $0.bucketId == oldBucket.bucketId }) else { continue }
                if newBucket.remainingFraction < oldBucket.remainingFraction - 0.0001 {
                    return true
                }
            }
        }
        return false
    }
    
    public func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await service.fetchQuotaSummary()
            
            // If quota decreased, activate burst mode (15s polling)
            if didQuotaDecrease(from: self.groups, to: data.groups) {
                activateBurstMode()
            }
            
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
