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
        }
    }
}
