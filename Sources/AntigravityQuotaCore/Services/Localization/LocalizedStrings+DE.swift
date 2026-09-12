import Foundation

// MARK: - German (Deutsch)
extension LocalizedStringKey {
    var germanString: String {

        switch self {
        case .menuBarWaiting:
            return "✦ AGY: Warten"
        case .statusOffline:
            return "Offline"
        case .statusActive(let s):
            return "⚡️ \(s)s"
        case .statusIdle(let m):
            return "\(m)m"
            
        case .tooltipSwitchToCompact:
            return "In den Kompaktmodus wechseln"
        case .tooltipSwitchToStandard:
            return "In den Standardmodus wechseln"
        case .tooltipSwitchLanguage:
            return "Sprache wechseln"
            
        case .loadingQuota:
            return "Kontingentdetails werden geladen..."
        case .waitingForConnection:
            return "Warten auf Antigravity"
        case .connectionDescription:
            return "Das Kontingent wird automatisch synchronisiert, wenn Antigravity aktiv ist."
            
        case .fiveHourResetTitle:
            return "5-Stunden-Reset"
        case .weeklyResetTitle:
            return "Wöchentlicher Reset"
        case .fiveHourShort:
            return "5 Std."
        case .weeklyShort:
            return "Woche"
        case .remaining(let pct):
            return "Verbleibend \(pct)%"
        case .used(let pct):
            return "(Verbraucht \(pct)%)"
            
        case .countdownDaysHours(let d, let h):
            return "Noch \(d) T. \(h) Std."
        case .countdownHoursMinutes(let h, let m):
            return "Noch \(h) Std. \(m) Min."
        case .countdownMinutesSeconds(let m, let s):
            return "Noch \(m) Min. \(s) Sek."
        case .countdownSeconds(let s):
            return "Noch \(s) Sek."
        case .resetComplete:
            return "Reset abgeschlossen"
            
        case .refresh:
            return "Aktualisieren"
        case .quit:
            return "Beenden"
        case .lastUpdated(let t):
            return "Zuletzt aktualisiert: \(t)"
            
        case .errorServerNotFound:
            return "Antigravity läuft nicht oder der Endpunkt wurde nicht gefunden."
        case .errorInvalidResponse:
            return "Ungültige Antwort vom Server empfangen."
        case .errorHttp(let code):
            return "HTTP-Fehler aufgetreten (Code: \(code))"
        case .errorDecoding(let details):
            return "Daten konnten nicht verarbeitet werden: \(details)"
        case .errorNetwork(let details):
            return "Netzwerkverbindungsfehler: \(details)"
        }
    }
}
