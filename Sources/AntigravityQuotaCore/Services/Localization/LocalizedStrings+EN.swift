import Foundation

// MARK: - English
extension LocalizedStringKey {
    var englishString: String {

        switch self {
        case .menuBarWaiting:
            return "✦ AGY: Waiting"
        case .statusOffline:
            return "Offline"
        case .statusActive(let s):
            return "⚡️ \(s)s"
        case .statusIdle(let m):
            return "\(m)m"
            
        case .tooltipSwitchToCompact:
            return "Switch to Compact Mode"
        case .tooltipSwitchToStandard:
            return "Switch to Standard Mode"
        case .tooltipSwitchLanguage:
            return "Switch Language (Current: English)"
            
        case .loadingQuota:
            return "Loading quota details..."
        case .waitingForConnection:
            return "Waiting for Antigravity"
        case .connectionDescription:
            return "Quota will sync automatically when Antigravity is active."
            
        case .fiveHourResetTitle:
            return "5-Hour Reset"
        case .weeklyResetTitle:
            return "Weekly Reset"
        case .fiveHourShort:
            return "5h"
        case .weeklyShort:
            return "Weekly"
        case .remaining(let pct):
            return "Remaining \(pct)%"
        case .used(let pct):
            return "(Used \(pct)%)"
            
        case .countdownDaysHours(let d, let h):
            return "\(d)d \(h)h left"
        case .countdownHoursMinutes(let h, let m):
            return "\(h)h \(m)m left"
        case .countdownMinutesSeconds(let m, let s):
            return "\(m)m \(s)s left"
        case .countdownSeconds(let s):
            return "\(s)s left"
        case .resetComplete:
            return "Reset complete"
        case .quotaUnused:
            return "Unused"
            
        case .refresh:
            return "Refresh"
        case .quit:
            return "Quit"
        case .lastUpdated(let t):
            return "Last updated: \(t)"
            
        case .errorServerNotFound:
            return "Antigravity is not running or endpoint could not be discovered."
        case .errorInvalidResponse:
            return "Received an invalid response from server."
        case .errorHttp(let code):
            return "HTTP error occurred (Code: \(code))"
        case .errorDecoding(let details):
            return "Failed to parse data: \(details)"
        case .errorNetwork(let details):
            return "Network connection error: \(details)"
            
        case .settings:
            return "Settings"
        case .generalTab:
            return "General"
        case .notificationsTab:
            return "Notifications"
        case .launchAtLogin:
            return "Launch at Login"
        case .launchAtLoginDescription:
            return "Automatically launch in the menu bar when your Mac starts up."
        case .menuBarStyle:
            return "Menu Bar Display"
        case .menuBarIconAndText:
            return "Icon & Quota Percentages"
        case .menuBarIconOnly:
            return "Icon Only"
        case .menuBarGaugeSource:
            return "Gauge Target Quota"
        case .gaugeGemini5h:
            return "Gemini (5-Hour)"
        case .gaugeGeminiWeekly:
            return "Gemini (Weekly)"
        case .gaugeClaude5h:
            return "Claude / GPT (5-Hour)"
        case .gaugeClaudeWeekly:
            return "Claude / GPT (Weekly)"
        case .popoverStyle:
            return "Popover Style"
        case .standardMode:
            return "Standard"
        case .compactMode:
            return "Compact"
        case .language:
            return "Language"
            
        case .enableNotifications:
            return "Enable Quota Notifications"
        case .notifyFiveHour:
            return "5-Hour Quota Reset Alert"
        case .notifyWeekly:
            return "Weekly Quota Reset Alert"
        case .timeSensitiveAlert:
            return "Time-Sensitive Alert (Breaks through Focus)"
        case .timeSensitiveDescription:
            return "Deliver immediate notification banners even during Do Not Disturb or Focus modes."
        case .sendTestNotification:
            return "Send Test Notification"
        case .notificationTitleRefilled:
            return "✦ Antigravity Quota Refilled"
        case .notificationBodyRefilled(let model, let window):
            return "\(model) \(window) quota has been refilled to 100%. You can resume working!"
        case .notificationTestBody:
            return "Test notification received successfully. You will be alerted when quotas refill."
        case .notificationPermissionDenied:
            return "Please enable notifications for Antigravity Quota in macOS System Settings > Notifications."
        case .notificationPermissionRequired:
            return "Notification Permission Required"
        case .notificationPermissionDescription:
            return "To receive quota refill alerts, notifications must be enabled in macOS System Settings."
        case .openSystemSettings:
            return "Open macOS System Settings"
        case .requestPermission:
            return "Allow Notifications"
        case .notificationPermissionGranted:
            return "macOS notifications are enabled and active."
            
        case .remoteTab:
            return "Remote"
        case .enableRemoteSSH:
            return "Enable Remote SSH Query"
        case .enableRemoteSSHDescription:
            return "Queries quota from a remote machine via SSH when Antigravity is not running locally."
        case .remoteSSHHost:
            return "SSH Host"
        case .remoteSSHHostPlaceholder:
            return "user@192.168.1.10 or ssh_config alias"
        case .remoteSSHInterval:
            return "Remote Polling Interval"
        case .remoteInterval30s:
            return "30 seconds"
        case .remoteInterval60s:
            return "1 minute (Default)"
        case .remoteInterval120s:
            return "2 minutes"
        case .remoteInterval300s:
            return "5 minutes"
        case .testConnection:
            return "Test Connection"
        case .testingConnection:
            return "Testing connection..."
        case .testConnectionSuccess:
            return "Connection successful (quota received)"
        case .testConnectionFailed(let details):
            return "Connection failed: \(details)"
        case .sshNotice:
            return "SSH key-based authentication must be configured in advance so it can connect without a password prompt."
        }
    }
}
