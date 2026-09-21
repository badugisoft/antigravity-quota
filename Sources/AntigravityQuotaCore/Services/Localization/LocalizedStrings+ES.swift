import Foundation

// MARK: - Spanish (Español)
extension LocalizedStringKey {
    var spanishString: String {

        switch self {
        case .menuBarWaiting:
            return "✦ AGY: Esperando"
        case .statusOffline:
            return "Desconectado"
        case .statusActive(let s):
            return "⚡️ \(s)s"
        case .statusIdle(let m):
            return "\(m)m"
            
        case .tooltipSwitchToCompact:
            return "Cambiar a modo compacto"
        case .tooltipSwitchToStandard:
            return "Cambiar a modo estándar"
        case .tooltipSwitchLanguage:
            return "Cambiar idioma"
            
        case .loadingQuota:
            return "Cargando detalles de cuota..."
        case .waitingForConnection:
            return "Esperando a Antigravity"
        case .connectionDescription:
            return "La cuota se sincronizará automáticamente cuando Antigravity esté activo."
            
        case .fiveHourResetTitle:
            return "Reinicio de 5 horas"
        case .weeklyResetTitle:
            return "Reinicio semanal"
        case .fiveHourShort:
            return "5 h"
        case .weeklyShort:
            return "Sem."
        case .remaining(let pct):
            return "Restante \(pct)%"
        case .used(let pct):
            return "(Usado \(pct)%)"
            
        case .countdownDaysHours(let d, let h):
            return "Quedan \(d)d \(h)h"
        case .countdownHoursMinutes(let h, let m):
            return "Quedan \(h)h \(m)min"
        case .countdownMinutesSeconds(let m, let s):
            return "Quedan \(m)min \(s)s"
        case .countdownSeconds(let s):
            return "Quedan \(s)s"
        case .resetComplete:
            return "Reinicio completado"
        case .quotaUnused:
            return "Sin usar"
            
        case .refresh:
            return "Actualizar"
        case .quit:
            return "Salir"
        case .lastUpdated(let t):
            return "Última actualización: \(t)"
            
        case .errorServerNotFound:
            return "Antigravity no está ejecutándose o no se pudo encontrar el endpoint."
        case .errorInvalidResponse:
            return "Se recibió una respuesta no válida del servidor."
        case .errorHttp(let code):
            return "Se produjo un error HTTP (Código: \(code))"
        case .errorDecoding(let details):
            return "Error al procesar datos: \(details)"
        case .errorNetwork(let details):
            return "Error de conexión de red: \(details)"
            
        case .settings:
            return "Ajustes"
        case .generalTab:
            return "General"
        case .notificationsTab:
            return "Notificaciones"
        case .launchAtLogin:
            return "Abrir al iniciar sesión"
        case .launchAtLoginDescription:
            return "Abrir automáticamente en la barra de menús al encender el Mac."
        case .menuBarStyle:
            return "Aspecto en la barra de menús"
        case .menuBarIconAndText:
            return "Icono y porcentajes de cuota"
        case .menuBarIconOnly:
            return "Solo icono"
        case .menuBarGaugeSource:
            return "Objetivo del indicador circular"
        case .gaugeGemini5h:
            return "Gemini (5 horas)"
        case .gaugeGeminiWeekly:
            return "Gemini (Semanal)"
        case .gaugeClaude5h:
            return "Claude / GPT (5 horas)"
        case .gaugeClaudeWeekly:
            return "Claude / GPT (Semanal)"
        case .popoverStyle:
            return "Estilo del popover"
        case .standardMode:
            return "Estándar"
        case .compactMode:
            return "Compacto"
        case .language:
            return "Idioma"
            
        case .enableNotifications:
            return "Activar notificaciones de recarga de cuota"
        case .notifyFiveHour:
            return "Alerta de reinicio de cuota de 5 horas"
        case .notifyWeekly:
            return "Alerta de reinicio de cuota semanal"
        case .timeSensitiveAlert:
            return "Notificación urgente (ignora los modos de concentración)"
        case .timeSensitiveDescription:
            return "Muestra notificaciones de banner de inmediato incluso en modo No molestar."
        case .sendTestNotification:
            return "Enviar notificación de prueba"
        case .notificationTitleRefilled:
            return "✦ Cuota de Antigravity recargada"
        case .notificationBodyRefilled(let model, let window):
            return "La cuota de \(window) para \(model) se ha recargado al 100%. ¡Ya puedes reanudar el trabajo!"
        case .notificationTestBody:
            return "Notificación de prueba recibida correctamente. Recibirás avisos al recargarse las cuotas."
        case .notificationPermissionDenied:
            return "Permite las notificaciones de Antigravity Quota en Ajustes del Sistema > Notificaciones."
        case .notificationPermissionRequired:
            return "Permiso de notificación requerido"
        case .notificationPermissionDescription:
            return "Para recibir alertas de recarga de cuota, debes permitir las notificaciones en Ajustes del Sistema de macOS."
        case .openSystemSettings:
            return "Abrir Ajustes del Sistema de macOS"
        case .requestPermission:
            return "Permitir notificaciones"
        case .notificationPermissionGranted:
            return "Las notificaciones del sistema macOS están activadas."
            
        case .remoteTab:
            return "Remoto"
        case .enableRemoteSSH:
            return "Habilitar consulta de cuota por SSH remoto"
        case .enableRemoteSSHDescription:
            return "Consulta la cuota desde una máquina remota mediante SSH cuando Antigravity no se ejecuta localmente."
        case .remoteSSHHost:
            return "Host SSH"
        case .remoteSSHHostPlaceholder:
            return "user@192.168.1.10 o alias de ssh_config"
        case .remoteSSHInterval:
            return "Intervalo de sondeo remoto"
        case .remoteInterval30s:
            return "30 segundos"
        case .remoteInterval60s:
            return "1 minuto (Predeterminado)"
        case .remoteInterval120s:
            return "2 minutos"
        case .remoteInterval300s:
            return "5 minutos"
        case .testConnection:
            return "Probar conexión"
        case .testingConnection:
            return "Probando conexión..."
        case .testConnectionSuccess:
            return "Conexión exitosa (cuota recibida)"
        case .testConnectionFailed(let details):
            return "Error de conexión: \(details)"
        case .sshNotice:
            return "La autenticación por clave SSH debe configurarse previamente para conectarse sin solicitar contraseña."
        }
    }
}
