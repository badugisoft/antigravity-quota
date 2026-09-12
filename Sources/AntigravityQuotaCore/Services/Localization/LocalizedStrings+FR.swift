import Foundation

// MARK: - French (Français)
extension LocalizedStringKey {
    var frenchString: String {

        switch self {
        case .menuBarWaiting:
            return "✦ AGY: En attente"
        case .statusOffline:
            return "Hors ligne"
        case .statusActive(let s):
            return "⚡️ \(s)s"
        case .statusIdle(let m):
            return "\(m)m"
            
        case .tooltipSwitchToCompact:
            return "Passer en mode compact"
        case .tooltipSwitchToStandard:
            return "Passer en mode standard"
        case .tooltipSwitchLanguage:
            return "Changer de langue"
            
        case .loadingQuota:
            return "Chargement des quotas..."
        case .waitingForConnection:
            return "En attente d'Antigravity"
        case .connectionDescription:
            return "Les quotas se synchronisent automatiquement lorsqu'Antigravity est actif."
            
        case .fiveHourResetTitle:
            return "Réinitialisation 5h"
        case .weeklyResetTitle:
            return "Réinitialisation hebdomadaire"
        case .fiveHourShort:
            return "5 h"
        case .weeklyShort:
            return "Hebdo"
        case .remaining(let pct):
            return "Restant \(pct)%"
        case .used(let pct):
            return "(Utilisé \(pct)%)"
            
        case .countdownDaysHours(let d, let h):
            return "Reste \(d)j \(h)h"
        case .countdownHoursMinutes(let h, let m):
            return "Reste \(h)h \(m)min"
        case .countdownMinutesSeconds(let m, let s):
            return "Reste \(m)min \(s)s"
        case .countdownSeconds(let s):
            return "Reste \(s)s"
        case .resetComplete:
            return "Réinitialisation terminée"
            
        case .refresh:
            return "Actualiser"
        case .quit:
            return "Quitter"
        case .lastUpdated(let t):
            return "Dernière mise à jour: \(t)"
            
        case .errorServerNotFound:
            return "Antigravity n'est pas lancé ou le point de terminaison est introuvable."
        case .errorInvalidResponse:
            return "Réponse du serveur non valide reçue."
        case .errorHttp(let code):
            return "Erreur HTTP survenue (Code: \(code))"
        case .errorDecoding(let details):
            return "Échec de l'analyse des données: \(details)"
        case .errorNetwork(let details):
            return "Erreur de connexion réseau: \(details)"
        }
    }
}
