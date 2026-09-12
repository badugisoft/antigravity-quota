import Foundation
import Combine

/// Supported application languages.
public enum AppLanguage: String, CaseIterable, Identifiable {
    case en = "en"
    case ko = "ko"
    case zh = "zh"
    case ja = "ja"
    case de = "de"
    case fr = "fr"
    case es = "es"
    
    public var id: String { rawValue }
    
    /// User-facing display name in native tongue.
    public var displayName: String {
        switch self {
        case .en: return "English"
        case .ko: return "한국어"
        case .zh: return "简体中文"
        case .ja: return "日本語"
        case .de: return "Deutsch"
        case .fr: return "Français"
        case .es: return "Español"
        }
    }
    
    /// Short 2-letter abbreviation for compact UI buttons.
    public var shortName: String {
        switch self {
        case .en: return "EN"
        case .ko: return "KO"
        case .zh: return "ZH"
        case .ja: return "JA"
        case .de: return "DE"
        case .fr: return "FR"
        case .es: return "ES"
        }
    }
    
    /// Canonical locale for language-sensitive formatting (dates, times, numbers).
    public var locale: Locale {
        switch self {
        case .en: return Locale(identifier: "en_US")
        case .ko: return Locale(identifier: "ko_KR")
        case .zh: return Locale(identifier: "zh_Hans_CN")
        case .ja: return Locale(identifier: "ja_JP")
        case .de: return Locale(identifier: "de_DE")
        case .fr: return Locale(identifier: "fr_FR")
        case .es: return Locale(identifier: "es_ES")
        }
    }
    
    /// Current language preference resolved from UserDefaults or system locale (thread-safe).
    public static var currentPreference: AppLanguage {
        if let saved = UserDefaults.standard.string(forKey: "appLanguage"),
           let language = AppLanguage(rawValue: saved) {
            return language
        }
        let preferred = Locale.preferredLanguages.first?.lowercased() ?? "en"
        if preferred.starts(with: "ko") { return .ko }
        if preferred.starts(with: "zh") { return .zh }
        if preferred.starts(with: "ja") { return .ja }
        if preferred.starts(with: "de") { return .de }
        if preferred.starts(with: "fr") { return .fr }
        if preferred.starts(with: "es") { return .es }
        return .en
    }
}

/// Central localization manager providing reactive language switching and string lookups.
@MainActor
public final class LocalizationManager: ObservableObject {
    public static let shared = LocalizationManager()
    
    private static let userDefaultsKey = "appLanguage"
    
    @Published public var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: Self.userDefaultsKey)
        }
    }
    
    public init() {
        self.currentLanguage = AppLanguage.currentPreference
    }
    
    /// Cycles to the next supported language.
    public func toggleLanguage() {
        let all = AppLanguage.allCases
        if let index = all.firstIndex(of: currentLanguage) {
            let nextIndex = (index + 1) % all.count
            currentLanguage = all[nextIndex]
        } else {
            currentLanguage = .en
        }
    }
    
    // MARK: - Localized Strings Lookup
    
    public func string(_ key: LocalizedStringKey) -> String {
        key.string(for: currentLanguage)
    }
}

/// Strongly typed keys for all user-facing strings across the application.
public enum LocalizedStringKey {
    // Menu Bar & Status
    case menuBarWaiting
    case statusOffline
    case statusActive(seconds: Int)
    case statusIdle(minutes: Int)
    
    // Header & Tooltips
    case tooltipSwitchToCompact
    case tooltipSwitchToStandard
    case tooltipSwitchLanguage
    
    // Empty & Connection States
    case loadingQuota
    case waitingForConnection
    case connectionDescription
    
    // Group & Card Labels
    case fiveHourResetTitle
    case weeklyResetTitle
    case fiveHourShort
    case weeklyShort
    case remaining(percent: Int)
    case used(percent: Int)
    
    // Countdown Formats
    case countdownDaysHours(days: Int, hours: Int)
    case countdownHoursMinutes(hours: Int, minutes: Int)
    case countdownMinutesSeconds(minutes: Int, seconds: Int)
    case countdownSeconds(seconds: Int)
    case resetComplete
    
    // Action Buttons & Info
    case refresh
    case quit
    case lastUpdated(time: String)
    
    // Error Descriptions
    case errorServerNotFound
    case errorInvalidResponse
    case errorHttp(code: Int)
    case errorDecoding(details: String)
    case errorNetwork(details: String)
    
    public func string(for language: AppLanguage) -> String {
        switch language {
        case .en: return englishString
        case .ko: return koreanString
        case .zh: return chineseString
        case .ja: return japaneseString
        case .de: return germanString
        case .fr: return frenchString
        case .es: return spanishString
        }
    }
}

// MARK: - Localized Date & Time Formatting

extension Date {
    /// Formats time with medium precision (hours, minutes, seconds) localized to the specified language.
    public func formattedTime(for language: AppLanguage) -> String {
        let formatter = DateFormatter()
        formatter.locale = language.locale
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter.string(from: self)
    }
    
    /// Formats time with short precision (hours, minutes) localized to the specified language.
    public func formattedShortTime(for language: AppLanguage) -> String {
        let formatter = DateFormatter()
        formatter.locale = language.locale
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: self)
    }
}
