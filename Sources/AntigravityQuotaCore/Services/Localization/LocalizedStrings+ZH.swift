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
            
        case .settings:
            return "设置"
        case .generalTab:
            return "通用"
        case .notificationsTab:
            return "通知"
        case .launchAtLogin:
            return "开机自动启动"
        case .launchAtLoginDescription:
            return "Mac 启动时在菜单栏中自动运行。"
        case .menuBarStyle:
            return "菜单栏显示"
        case .menuBarIconAndText:
            return "图标与配额百分比"
        case .menuBarIconOnly:
            return "仅图标"
        case .menuBarGaugeSource:
            return "圆环刻度显示目标"
        case .gaugeGemini5h:
            return "Gemini（5小时）"
        case .gaugeGeminiWeekly:
            return "Gemini（每周）"
        case .gaugeClaude5h:
            return "Claude / GPT（5小时）"
        case .gaugeClaudeWeekly:
            return "Claude / GPT（每周）"
        case .popoverStyle:
            return "弹出窗口样式"
        case .standardMode:
            return "标准模式"
        case .compactMode:
            return "紧凑模式"
        case .language:
            return "语言"
            
        case .enableNotifications:
            return "启用配额补充通知"
        case .notifyFiveHour:
            return "5小时配额重置提醒"
        case .notifyWeekly:
            return "每周配额重置提醒"
        case .timeSensitiveAlert:
            return "时间敏感通知（穿透专注模式）"
        case .timeSensitiveDescription:
            return "在勿扰模式或专注模式下也立即显示横幅通知。"
        case .sendTestNotification:
            return "发送测试通知"
        case .notificationTitleRefilled:
            return "✦ Antigravity 配额已重置"
        case .notificationBodyRefilled(let model, let window):
            return "\(model) 的 \(window) 配额已恢复至 100%。您可以继续使用！"
        case .notificationTestBody:
            return "测试通知接收成功。配额重置时您将收到提醒。"
        case .notificationPermissionDenied:
            return "请在 macOS [系统设置] > [通知] 中允许 Antigravity Quota 的通知。"
        case .notificationPermissionRequired:
            return "需要通知权限"
        case .notificationPermissionDescription:
            return "若要接收配额补充提醒，必须在 macOS 系统设置中启用通知。"
        case .openSystemSettings:
            return "打开 macOS 系统设置"
        case .requestPermission:
            return "允许通知权限"
        case .notificationPermissionGranted:
            return "macOS 系统通知已启用。"
            
        case .remoteTab:
            return "远程"
        case .enableRemoteSSH:
            return "启用远程 SSH 配额查询"
        case .enableRemoteSSHDescription:
            return "当本地未运行 Antigravity 进程时，通过 SSH 从远程主机查询配额。"
        case .remoteSSHHost:
            return "SSH 主机"
        case .remoteSSHHostPlaceholder:
            return "user@192.168.1.10 或 ssh_config 别名"
        case .remoteSSHInterval:
            return "远程轮询间隔"
        case .remoteInterval30s:
            return "30 秒"
        case .remoteInterval60s:
            return "1 分钟 (默认)"
        case .remoteInterval120s:
            return "2 分钟"
        case .remoteInterval300s:
            return "5 分钟"
        case .testConnection:
            return "测试连接"
        case .testingConnection:
            return "正在测试连接..."
        case .testConnectionSuccess:
            return "连接成功 (成功获取配额)"
        case .testConnectionFailed(let details):
            return "连接失败: \(details)"
        case .sshNotice:
            return "必须预先配置 SSH 密钥免密登录认证，以便无需密码即可连接。"
        }
    }
}
