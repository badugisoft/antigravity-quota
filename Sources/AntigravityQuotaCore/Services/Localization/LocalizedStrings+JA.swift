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
        }
    }
}
