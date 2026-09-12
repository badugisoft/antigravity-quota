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
        }
    }
}
