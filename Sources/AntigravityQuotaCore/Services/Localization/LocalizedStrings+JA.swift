import Foundation

// MARK: - Japanese (日本語)
extension LocalizedStringKey {
    var japaneseString: String {

        switch self {
        case .menuBarWaiting:
            return "✦ AGY: 待機中"
        case .statusOffline:
            return "オフライン"
        case .statusActive(let s):
            return "⚡️ \(s)秒"
        case .statusIdle(let m):
            return "\(m)分"
            
        case .tooltipSwitchToCompact:
            return "コンパクトモードに切り替え"
        case .tooltipSwitchToStandard:
            return "標準モードに切り替え"
        case .tooltipSwitchLanguage:
            return "言語を切り替え"
            
        case .loadingQuota:
            return "利用枠の情報を読み込み中..."
        case .waitingForConnection:
            return "Antigravity の接続待機中"
        case .connectionDescription:
            return "Antigravity の起動時に利用枠が自動同期されます。"
            
        case .fiveHourResetTitle:
            return "5時間周期リセット"
        case .weeklyResetTitle:
            return "週間周期リセット"
        case .fiveHourShort:
            return "5時間"
        case .weeklyShort:
            return "週間"
        case .remaining(let pct):
            return "残り \(pct)%"
        case .used(let pct):
            return "(使用 \(pct)%)"
            
        case .countdownDaysHours(let d, let h):
            return "残り \(d)日 \(h)時間"
        case .countdownHoursMinutes(let h, let m):
            return "残り \(h)時間 \(m)分"
        case .countdownMinutesSeconds(let m, let s):
            return "残り \(m)分 \(s)秒"
        case .countdownSeconds(let s):
            return "残り \(s)秒"
        case .resetComplete:
            return "リセット完了"
            
        case .refresh:
            return "更新"
        case .quit:
            return "終了"
        case .lastUpdated(let t):
            return "最終更新: \(t)"
            
        case .errorServerNotFound:
            return "Antigravity が起動していないか、エンドポイントを検出できません。"
        case .errorInvalidResponse:
            return "サーバーから無効な応答を受信しました。"
        case .errorHttp(let code):
            return "HTTP エラーが発生しました (コード: \(code))"
        case .errorDecoding(let details):
            return "データの解析に失敗しました: \(details)"
        case .errorNetwork(let details):
            return "ネットワーク接続エラー: \(details)"
            
        case .settings:
            return "設定"
        case .generalTab:
            return "一般"
        case .notificationsTab:
            return "通知"
        case .launchAtLogin:
            return "ログイン時に自動起動"
        case .launchAtLoginDescription:
            return "Mac 起動時にメニューバーで自動的に実行されます。"
        case .menuBarStyle:
            return "メニューバー表示"
        case .menuBarIconAndText:
            return "アイコンとクォータ残量"
        case .menuBarIconOnly:
            return "アイコンのみ"
        case .menuBarGaugeSource:
            return "円形ゲージ表示対象"
        case .gaugeGemini5h:
            return "Gemini (5時間)"
        case .gaugeGeminiWeekly:
            return "Gemini (週間)"
        case .gaugeClaude5h:
            return "Claude / GPT (5時間)"
        case .gaugeClaudeWeekly:
            return "Claude / GPT (週間)"
        case .popoverStyle:
            return "ポップオーバースタイル"
        case .standardMode:
            return "標準モード"
        case .compactMode:
            return "コンパクトモード"
        case .language:
            return "言語"
            
        case .enableNotifications:
            return "クォータ回復通知を有効にする"
        case .notifyFiveHour:
            return "5時間クォータリセット通知"
        case .notifyWeekly:
            return "週間クォータリセット通知"
        case .timeSensitiveAlert:
            return "即時通知 (集中モード貫通)"
        case .timeSensitiveDescription:
            return "おやすみモードや集中モード中でもバナー通知を即座に表示します。"
        case .sendTestNotification:
            return "テスト通知を送信"
        case .notificationTitleRefilled:
            return "✦ Antigravity クォータ回復完了"
        case .notificationBodyRefilled(let model, let window):
            return "\(model) の \(window) クォータが 100% 回復しました。作業を再開できます！"
        case .notificationTestBody:
            return "テスト通知が正常に届きました。クォータ回復時に通知されます。"
        case .notificationPermissionDenied:
            return "macOSの [システム設定] > [通知] で Antigravity Quota の通知を許可してください。"
        case .notificationPermissionRequired:
            return "通知権限が必要です"
        case .notificationPermissionDescription:
            return "クォータ回復通知を受け取るには、macOSシステム設定で通知を許可する必要があります。"
        case .openSystemSettings:
            return "macOS システム設定を開く"
        case .requestPermission:
            return "通知権限を許可"
        case .notificationPermissionGranted:
            return "macOS システム通知が許可されています。"
        }
    }
}
