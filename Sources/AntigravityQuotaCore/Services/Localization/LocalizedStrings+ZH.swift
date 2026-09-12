import Foundation

// MARK: - Simplified Chinese (简体中文)
extension LocalizedStringKey {
    var chineseString: String {

        switch self {
        case .menuBarWaiting:
            return "✦ AGY: 等待中"
        case .statusOffline:
            return "离线"
        case .statusActive(let s):
            return "⚡️ \(s)秒"
        case .statusIdle(let m):
            return "\(m)分钟"
            
        case .tooltipSwitchToCompact:
            return "切换至紧凑模式"
        case .tooltipSwitchToStandard:
            return "切换至标准模式"
        case .tooltipSwitchLanguage:
            return "切换语言"
            
        case .loadingQuota:
            return "正在加载配额详情..."
        case .waitingForConnection:
            return "等待 Antigravity 连接"
        case .connectionDescription:
            return "Antigravity 运行时将自动同步配额。"
            
        case .fiveHourResetTitle:
            return "5小时周期重置"
        case .weeklyResetTitle:
            return "每周周期重置"
        case .fiveHourShort:
            return "5小时"
        case .weeklyShort:
            return "每周"
        case .remaining(let pct):
            return "剩余 \(pct)%"
        case .used(let pct):
            return "(已用 \(pct)%)"
            
        case .countdownDaysHours(let d, let h):
            return "剩余 \(d)天 \(h)小时"
        case .countdownHoursMinutes(let h, let m):
            return "剩余 \(h)小时 \(m)分"
        case .countdownMinutesSeconds(let m, let s):
            return "剩余 \(m)分 \(s)秒"
        case .countdownSeconds(let s):
            return "剩余 \(s)秒"
        case .resetComplete:
            return "重置完成"
            
        case .refresh:
            return "刷新"
        case .quit:
            return "退出"
        case .lastUpdated(let t):
            return "上次更新: \(t)"
            
        case .errorServerNotFound:
            return "Antigravity 未运行或无法发现端点。"
        case .errorInvalidResponse:
            return "收到来自服务器的无效响应。"
        case .errorHttp(let code):
            return "发生 HTTP 错误 (状态码: \(code))"
        case .errorDecoding(let details):
            return "数据解析失败: \(details)"
        case .errorNetwork(let details):
            return "网络连接错误: \(details)"
        }
    }
}
