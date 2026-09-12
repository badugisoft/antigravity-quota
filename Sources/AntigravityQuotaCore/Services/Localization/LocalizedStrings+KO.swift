import Foundation

// MARK: - Korean
extension LocalizedStringKey {
    var koreanString: String {

        switch self {
        case .menuBarWaiting:
            return "✦ AGY: 대기중"
        case .statusOffline:
            return "오프라인"
        case .statusActive(let s):
            return "⚡️ \(s)초"
        case .statusIdle(let m):
            return "\(m)분"
            
        case .tooltipSwitchToCompact:
            return "컴팩트 모드로 전환"
        case .tooltipSwitchToStandard:
            return "기본 모드로 전환"
        case .tooltipSwitchLanguage:
            return "언어 변경 (현재 언어: 한국어)"
            
        case .loadingQuota:
            return "쿼터 정보를 불러오는 중..."
        case .waitingForConnection:
            return "Antigravity 연결 대기 중"
        case .connectionDescription:
            return "Antigravity 앱이 실행되면 사용량이 자동으로 동기화됩니다."
            
        case .fiveHourResetTitle:
            return "5시간 주기 리셋"
        case .weeklyResetTitle:
            return "일주일 주기 리셋"
        case .fiveHourShort:
            return "5시간"
        case .weeklyShort:
            return "일주일"
        case .remaining(let pct):
            return "남은 용량 \(pct)%"
        case .used(let pct):
            return "(사용 \(pct)%)"
            
        case .countdownDaysHours(let d, let h):
            return "\(d)일 \(h)시간 남음"
        case .countdownHoursMinutes(let h, let m):
            return "\(h)시간 \(m)분 남음"
        case .countdownMinutesSeconds(let m, let s):
            return "\(m)분 \(s)초 남음"
        case .countdownSeconds(let s):
            return "\(s)초 남음"
        case .resetComplete:
            return "리셋 완료"
            
        case .refresh:
            return "새로고침"
        case .quit:
            return "종료"
        case .lastUpdated(let t):
            return "최종 업데이트: \(t)"
            
        case .errorServerNotFound:
            return "Antigravity가 실행 중이지 않거나 엔드포인트를 찾을 수 없습니다."
        case .errorInvalidResponse:
            return "유효하지 않은 응답을 받았습니다."
        case .errorHttp(let code):
            return "HTTP 오류 발생 (코드: \(code))"
        case .errorDecoding(let details):
            return "데이터 파싱 실패: \(details)"
        case .errorNetwork(let details):
            return "네트워크 오류: \(details)"
        }
    }
}
