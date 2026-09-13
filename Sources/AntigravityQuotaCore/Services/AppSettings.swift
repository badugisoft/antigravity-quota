import Foundation
import ServiceManagement
import Combine

/// Target quota bucket reflected in the menu bar circular progress gauge.
public enum MenuBarGaugeSource: String, CaseIterable, Identifiable, Codable {
    case gemini5h = "gemini5h"
    case geminiWeekly = "geminiWeekly"
    case claude5h = "claude5h"
    case claudeWeekly = "claudeWeekly"
    
    public var id: String { rawValue }
}

/// Manages user preferences and persistent settings across the application.
public final class AppSettings: ObservableObject {
    public static let shared = AppSettings()
    
    // MARK: - Keys
    private enum Keys {
        static let showMenuBarText = "showMenuBarText"
        static let menuBarGaugeSource = "menuBarGaugeSource"
        static let launchAtLogin = "launchAtLogin"
        static let notifyQuotaRefilled = "notifyQuotaRefilled"
        static let notifyFiveHourReset = "notifyFiveHourReset"
        static let notifyWeeklyReset = "notifyWeeklyReset"
        static let isCompactMode = "isCompactMode"
    }
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Published Properties
    
    /// Which quota bucket is displayed in the menu bar circular gauge ring. Default is .gemini5h.
    @Published public var menuBarGaugeSource: MenuBarGaugeSource {
        didSet { defaults.set(menuBarGaugeSource.rawValue, forKey: Keys.menuBarGaugeSource) }
    }
    
    /// Whether to display quota percentages in the macOS menu bar next to the icon. Default is true.
    @Published public var showMenuBarText: Bool {
        didSet { defaults.set(showMenuBarText, forKey: Keys.showMenuBarText) }
    }
    
    /// Whether the application automatically launches when the user logs into macOS. Default is false.
    @Published public var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
            applyLaunchAtLogin(enabled: launchAtLogin)
        }
    }
    
    /// Master toggle for quota refill notifications. Default is true.
    @Published public var notifyQuotaRefilled: Bool {
        didSet { defaults.set(notifyQuotaRefilled, forKey: Keys.notifyQuotaRefilled) }
    }
    
    /// Whether to send a notification when a 5-hour quota bucket is refilled. Default is true.
    @Published public var notifyFiveHourReset: Bool {
        didSet { defaults.set(notifyFiveHourReset, forKey: Keys.notifyFiveHourReset) }
    }
    
    /// Whether to send a notification when a weekly quota bucket is refilled. Default is true.
    @Published public var notifyWeeklyReset: Bool {
        didSet { defaults.set(notifyWeeklyReset, forKey: Keys.notifyWeeklyReset) }
    }
    
    /// Whether the popover uses compact or standard card layout.
    @Published public var isCompactMode: Bool {
        didSet { defaults.set(isCompactMode, forKey: Keys.isCompactMode) }
    }
    
    public init() {
        // Default menuBarGaugeSource is .gemini5h
        if let savedSource = defaults.string(forKey: Keys.menuBarGaugeSource),
           let source = MenuBarGaugeSource(rawValue: savedSource) {
            self.menuBarGaugeSource = source
        } else {
            self.menuBarGaugeSource = .gemini5h
        }
        
        // Default showMenuBarText is true unless explicitly set to false
        if defaults.object(forKey: Keys.showMenuBarText) == nil {
            self.showMenuBarText = true
        } else {
            self.showMenuBarText = defaults.bool(forKey: Keys.showMenuBarText)
        }
        
        self.launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        
        // Notification defaults
        if defaults.object(forKey: Keys.notifyQuotaRefilled) == nil {
            self.notifyQuotaRefilled = true
        } else {
            self.notifyQuotaRefilled = defaults.bool(forKey: Keys.notifyQuotaRefilled)
        }
        
        if defaults.object(forKey: Keys.notifyFiveHourReset) == nil {
            self.notifyFiveHourReset = true
        } else {
            self.notifyFiveHourReset = defaults.bool(forKey: Keys.notifyFiveHourReset)
        }
        
        if defaults.object(forKey: Keys.notifyWeeklyReset) == nil {
            self.notifyWeeklyReset = true
        } else {
            self.notifyWeeklyReset = defaults.bool(forKey: Keys.notifyWeeklyReset)
        }
        
        self.isCompactMode = defaults.bool(forKey: Keys.isCompactMode)
        
        // Sync launch at login status from system if available
        syncLaunchAtLoginStatus()
    }
    
    // MARK: - ServiceManagement Integration
    
    private func syncLaunchAtLoginStatus() {
        if #available(macOS 13.0, *) {
            // Check current SMAppService status
            let currentStatus = SMAppService.mainApp.status
            if currentStatus == .enabled && !self.launchAtLogin {
                self.launchAtLogin = true
            } else if currentStatus == .notRegistered && self.launchAtLogin {
                // If system says not registered, keep in sync
                self.launchAtLogin = false
            }
        }
    }
    
    private func applyLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            // SMAppService works only when running inside an application bundle
            guard Bundle.main.bundleIdentifier != nil, Bundle.main.bundlePath.hasSuffix(".app") else {
                return
            }
            do {
                if enabled {
                    if SMAppService.mainApp.status != .enabled {
                        try SMAppService.mainApp.register()
                    }
                } else {
                    if SMAppService.mainApp.status == .enabled {
                        try SMAppService.mainApp.unregister()
                    }
                }
            } catch {
                print("[AppSettings] Failed to update launchAtLogin: \(error.localizedDescription)")
            }
        }
    }
}
