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
            
        case .settings:
            return "Paramètres"
        case .generalTab:
            return "Général"
        case .notificationsTab:
            return "Notifications"
        case .launchAtLogin:
            return "Lancer au démarrage"
        case .launchAtLoginDescription:
            return "Lancer automatiquement dans la barre des menus au démarrage du Mac."
        case .menuBarStyle:
            return "Affichage de la barre des menus"
        case .menuBarIconAndText:
            return "Icône et pourcentages de quota"
        case .menuBarIconOnly:
            return "Icône seule"
        case .menuBarGaugeSource:
            return "Cible de la jauge circulaire"
        case .gaugeGemini5h:
            return "Gemini (5 heures)"
        case .gaugeGeminiWeekly:
            return "Gemini (Hebdomadaire)"
        case .gaugeClaude5h:
            return "Claude / GPT (5 heures)"
        case .gaugeClaudeWeekly:
            return "Claude / GPT (Hebdomadaire)"
        case .popoverStyle:
            return "Style du popover"
        case .standardMode:
            return "Standard"
        case .compactMode:
            return "Compact"
        case .language:
            return "Langue"
            
        case .enableNotifications:
            return "Activer les notifications de quota"
        case .notifyFiveHour:
            return "Alerte de réinitialisation du quota 5h"
        case .notifyWeekly:
            return "Alerte de réinitialisation du quota hebdomadaire"
        case .timeSensitiveAlert:
            return "Notification urgente (outrepasser le mode Concentration)"
        case .timeSensitiveDescription:
            return "Afficher immédiatement les bannières même en mode Ne pas déranger ou Concentration."
        case .sendTestNotification:
            return "Envoyer une notification test"
        case .notificationTitleRefilled:
            return "✦ Quota Antigravity rechargé"
        case .notificationBodyRefilled(let model, let window):
            return "Le quota \(window) pour \(model) a été rechargé à 100%. Vous pouvez reprendre votre travail !"
        case .notificationTestBody:
            return "Notification test reçue avec succès. Vous serez averti lors des réinitialisations de quota."
        case .notificationPermissionDenied:
            return "Veuillez autoriser les notifications pour Antigravity Quota dans Réglages Système > Notifications."
        case .notificationPermissionRequired:
            return "Autorisation de notification requise"
        case .notificationPermissionDescription:
            return "Pour recevoir les alertes de recharge de quota, les notifications doivent être activées dans les Réglages Système."
        case .openSystemSettings:
            return "Ouvrir les Réglages Système"
        case .requestPermission:
            return "Autoriser les notifications"
        case .notificationPermissionGranted:
            return "Les notifications système macOS sont activées."
            
        case .remoteTab:
            return "Distant"
        case .enableRemoteSSH:
            return "Activer la requête de quota SSH distante"
        case .enableRemoteSSHDescription:
            return "Interroge le quota depuis une machine distante via SSH quand Antigravity n'est pas actif localement."
        case .remoteSSHHost:
            return "Hôte SSH"
        case .remoteSSHHostPlaceholder:
            return "user@192.168.1.10 ou alias ssh_config"
        case .remoteSSHInterval:
            return "Intervalle d'interrogation distante"
        case .remoteInterval30s:
            return "30 secondes"
        case .remoteInterval60s:
            return "1 minute (Défaut)"
        case .remoteInterval120s:
            return "2 minutes"
        case .remoteInterval300s:
            return "5 minutes"
        case .testConnection:
            return "Tester la connexion"
        case .testingConnection:
            return "Test de connexion..."
        case .testConnectionSuccess:
            return "Connexion réussie (quota reçu)"
        case .testConnectionFailed(let details):
            return "Échec de connexion : \(details)"
        case .sshNotice:
            return "L'authentification par clé SSH doit être configurée au préalable pour se connecter sans mot de passe."
        }
    }
}
