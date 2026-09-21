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
        case .quotaUnused:
            return "Ungenutzt"
            
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
            
        case .settings:
            return "Einstellungen"
        case .generalTab:
            return "Allgemein"
        case .notificationsTab:
            return "Mitteilungen"
        case .launchAtLogin:
            return "Bei der Anmeldung starten"
        case .launchAtLoginDescription:
            return "Beim Starten Ihres Mac automatisch in der Menüleiste öffnen."
        case .menuBarStyle:
            return "Menüleisten-Anzeige"
        case .menuBarIconAndText:
            return "Symbol & Kontingent"
        case .menuBarIconOnly:
            return "Nur Symbol"
        case .menuBarGaugeSource:
            return "Ziel für Kreisdiagramm"
        case .gaugeGemini5h:
            return "Gemini (5 Stunden)"
        case .gaugeGeminiWeekly:
            return "Gemini (Wöchentlich)"
        case .gaugeClaude5h:
            return "Claude / GPT (5 Stunden)"
        case .gaugeClaudeWeekly:
            return "Claude / GPT (Wöchentlich)"
        case .popoverStyle:
            return "Popover-Stil"
        case .standardMode:
            return "Standard"
        case .compactMode:
            return "Kompakt"
        case .language:
            return "Sprache"
            
        case .enableNotifications:
            return "Kontingent-Mitteilungen aktivieren"
        case .notifyFiveHour:
            return "5-Stunden-Kontingent-Reset-Mitteilung"
        case .notifyWeekly:
            return "Wöchentliche Kontingent-Reset-Mitteilung"
        case .timeSensitiveAlert:
            return "Dringliche Mitteilung (Fokus durchbrechen)"
        case .timeSensitiveDescription:
            return "Mitteilungen auch im Nicht-Stören- oder Fokusmodus sofort als Banner anzeigen."
        case .sendTestNotification:
            return "Testmitteilung senden"
        case .notificationTitleRefilled:
            return "✦ Antigravity Kontingent aufgefüllt"
        case .notificationBodyRefilled(let model, let window):
            return "Das \(window)-Kontingent für \(model) wurde auf 100% aufgefüllt. Sie können weiterarbeiten!"
        case .notificationTestBody:
            return "Testmitteilung erfolgreich empfangen. Sie werden bei Kontingent-Resets benachrichtigt."
        case .notificationPermissionDenied:
            return "Bitte Mitteilungen für Antigravity Quota in den macOS-Systemeinstellungen > Mitteilungen erlauben."
        case .notificationPermissionRequired:
            return "Mitteilungsberechtigung erforderlich"
        case .notificationPermissionDescription:
            return "Um Kontingent-Reset-Mitteilungen zu erhalten, müssen Mitteilungen in den macOS-Systemeinstellungen erlaubt sein."
        case .openSystemSettings:
            return "macOS-Systemeinstellungen öffnen"
        case .requestPermission:
            return "Mitteilungen erlauben"
        case .notificationPermissionGranted:
            return "macOS-Mitteilungen sind aktiviert und aktiv."
            
        case .remoteTab:
            return "Remote"
        case .enableRemoteSSH:
            return "Remote-SSH-Kontingentabfrage aktivieren"
        case .enableRemoteSSHDescription:
            return "Fragt Kontingente via SSH von einem Remote-Rechner ab, wenn Antigravity lokal nicht läuft."
        case .remoteSSHHost:
            return "SSH-Host"
        case .remoteSSHHostPlaceholder:
            return "user@192.168.1.10 oder ssh_config-Alias"
        case .remoteSSHInterval:
            return "Remote-Abfrageintervall"
        case .remoteInterval30s:
            return "30 Sekunden"
        case .remoteInterval60s:
            return "1 Minute (Standard)"
        case .remoteInterval120s:
            return "2 Minuten"
        case .remoteInterval300s:
            return "5 Minuten"
        case .testConnection:
            return "Verbindung testen"
        case .testingConnection:
            return "Verbindung wird getestet..."
        case .testConnectionSuccess:
            return "Verbindung erfolgreich (Kontingent empfangen)"
        case .testConnectionFailed(let details):
            return "Verbindung fehlgeschlagen: \(details)"
        case .sshNotice:
            return "SSH-Schlüssel-Authentifizierung muss eingerichtet sein, um ohne Passwortabfrage verbinden zu können."
        }
    }
}
