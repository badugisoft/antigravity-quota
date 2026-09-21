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
        case .quotaUnused:
            return "미사용"
            
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
            
        case .settings:
            return "설정"
        case .generalTab:
            return "일반"
        case .notificationsTab:
            return "알림"
        case .launchAtLogin:
            return "로그인 시 자동 실행"
        case .launchAtLoginDescription:
            return "Mac 시작 시 백그라운드 메뉴바로 자동 실행됩니다."
        case .menuBarStyle:
            return "메뉴바 표시"
        case .menuBarIconAndText:
            return "아이콘 및 잔여 쿼터"
        case .menuBarIconOnly:
            return "아이콘만 표시"
        case .menuBarGaugeSource:
            return "원형 게이지 표시 기준"
        case .gaugeGemini5h:
            return "Gemini (5시간)"
        case .gaugeGeminiWeekly:
            return "Gemini (일주일)"
        case .gaugeClaude5h:
            return "Claude / GPT (5시간)"
        case .gaugeClaudeWeekly:
            return "Claude / GPT (일주일)"
        case .popoverStyle:
            return "팝오버 모드"
        case .standardMode:
            return "기본 모드"
        case .compactMode:
            return "컴팩트 모드"
        case .language:
            return "언어"
            
        case .enableNotifications:
            return "쿼터 충전 알림 받기"
        case .notifyFiveHour:
            return "5시간 쿼터 충전 알림"
        case .notifyWeekly:
            return "일주일 쿼터 충전 알림"
        case .timeSensitiveAlert:
            return "시간 민감 알림 (집중 모드 관통)"
        case .timeSensitiveDescription:
            return "방해금지 및 집중 모드 중에도 화면에 즉시 알림 배너를 표시합니다."
        case .sendTestNotification:
            return "테스트 알림 보내기"
        case .notificationTitleRefilled:
            return "✦ Antigravity 쿼터 충전 완료"
        case .notificationBodyRefilled(let model, let window):
            return "\(model)의 \(window) 쿼터가 100% 충전되었습니다. 다시 작업하실 수 있습니다!"
        case .notificationTestBody:
            return "알림이 정상적으로 수신되었습니다. 쿼터 완충 시 알림을 받으실 수 있습니다."
        case .notificationPermissionDenied:
            return "macOS [시스템 설정] > [알림]에서 Antigravity Quota 알림을 허용해 주세요."
        case .notificationPermissionRequired:
            return "알림 권한 필요"
        case .notificationPermissionDescription:
            return "쿼터 충전 알림을 받으려면 macOS 시스템 설정에서 알림을 허용해야 합니다."
        case .openSystemSettings:
            return "macOS 시스템 설정 열기"
        case .requestPermission:
            return "알림 권한 허용하기"
        case .notificationPermissionGranted:
            return "macOS 시스템 알림이 허용되어 있습니다."
            
        case .remoteTab:
            return "원격"
        case .enableRemoteSSH:
            return "원격 SSH 쿼터 조회 사용"
        case .enableRemoteSSHDescription:
            return "로컬 머신에 Antigravity 프로세스가 없을 때 원격 머신에서 쿼터를 조회합니다."
        case .remoteSSHHost:
            return "SSH 호스트"
        case .remoteSSHHostPlaceholder:
            return "user@192.168.1.10 또는 ssh_config 별칭"
        case .remoteSSHInterval:
            return "원격 조회 주기"
        case .remoteInterval30s:
            return "30초"
        case .remoteInterval60s:
            return "1분 (기본)"
        case .remoteInterval120s:
            return "2분"
        case .remoteInterval300s:
            return "5분"
        case .testConnection:
            return "연결 테스트"
        case .testingConnection:
            return "연결 확인 중..."
        case .testConnectionSuccess:
            return "연결 성공 (쿼터 정상 수신)"
        case .testConnectionFailed(let details):
            return "연결 실패: \(details)"
        case .sshNotice:
            return "비밀번호 입력 없이 접속할 수 있도록 SSH Key 기반 인증이 사전에 설정되어 있어야 합니다."
        }
    }
}
