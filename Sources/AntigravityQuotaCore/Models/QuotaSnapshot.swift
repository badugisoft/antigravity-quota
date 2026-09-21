import Foundation

/// Snapshot representing the latest quota state to be shared with widgets.
public struct QuotaSnapshot: Codable {
    public let timestamp: Date
    public let isOnline: Bool
    public let groups: [QuotaGroup]
    public let description: String?
    public let languageCode: String?
    
    public init(
        timestamp: Date = Date(),
        isOnline: Bool = true,
        groups: [QuotaGroup],
        description: String? = nil,
        languageCode: String? = nil
    ) {
        self.timestamp = timestamp
        self.isOnline = isOnline
        self.groups = groups
        self.description = description
        self.languageCode = languageCode
    }
    
    public var preferredLanguage: AppLanguage {
        if let code = languageCode, let lang = AppLanguage(rawValue: code) {
            return lang
        }
        return AppLanguage.currentPreference
    }
    
    // MARK: - Helper Accessors
    
    public var geminiGroup: QuotaGroup? {
        groups.first(where: { $0.displayName.localizedCaseInsensitiveContains("gemini") })
    }
    
    public var claudeGptGroup: QuotaGroup? {
        groups.first(where: {
            $0.displayName.localizedCaseInsensitiveContains("claude") ||
            $0.displayName.localizedCaseInsensitiveContains("gpt")
        })
    }
    
    /// Finds the earliest reset Date across all buckets that are not yet 100% full.
    public var nearestResetDate: Date? {
        var nearest: Date?
        for group in groups {
            for bucket in group.buckets {
                guard !bucket.isFull else { continue }
                if let reset = bucket.parsedResetDate, reset > Date() {
                    if let cur = nearest {
                        if reset < cur { nearest = reset }
                    } else {
                        nearest = reset
                    }
                }
            }
        }
        return nearest
    }
    
    /// Formatted countdown for the nearest reset date.
    public func formattedNearestReset(from now: Date = Date(), language: AppLanguage = .en) -> String {
        guard let reset = nearestResetDate else {
            let hasBuckets = groups.contains(where: { !$0.buckets.isEmpty })
            if isOnline && hasBuckets && groups.allSatisfy({ $0.buckets.allSatisfy { $0.isFull } }) {
                return LocalizedStringKey.quotaUnused.string(for: language)
            }
            return "-"
        }
        let interval = reset.timeIntervalSince(now)
        guard interval > 0 else {
            return LocalizedStringKey.resetComplete.string(for: language)
        }
        
        let seconds = Int(interval)
        let days = seconds / 86400
        let hours = (seconds % 86400) / 3600
        let minutes = (seconds % 3600) / 60
        
        if days > 0 {
            return LocalizedStringKey.countdownDaysHours(days: days, hours: hours).string(for: language)
        } else if hours > 0 {
            return LocalizedStringKey.countdownHoursMinutes(hours: hours, minutes: minutes).string(for: language)
        } else {
            return "\(max(1, minutes))m"
        }
    }
    
    /// Fallback / placeholder snapshot for previews and offline initial states.
    public static var placeholder: QuotaSnapshot {
        let sampleGeminiBuckets = [
            QuotaBucket(
                bucketId: "gemini-5h",
                displayName: "Gemini 5-Hour",
                description: nil,
                window: "5h",
                remainingFraction: 0.95,
                resetTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600 * 3))
            ),
            QuotaBucket(
                bucketId: "gemini-weekly",
                displayName: "Gemini Weekly",
                description: nil,
                window: "weekly",
                remainingFraction: 0.88,
                resetTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400 * 4))
            )
        ]
        
        let sampleClaudeBuckets = [
            QuotaBucket(
                bucketId: "claude-5h",
                displayName: "Claude 5-Hour",
                description: nil,
                window: "5h",
                remainingFraction: 0.75,
                resetTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600 * 2))
            ),
            QuotaBucket(
                bucketId: "claude-weekly",
                displayName: "Claude Weekly",
                description: nil,
                window: "weekly",
                remainingFraction: 0.60,
                resetTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400 * 3))
            )
        ]
        
        return QuotaSnapshot(
            timestamp: Date(),
            isOnline: true,
            groups: [
                QuotaGroup(displayName: "Gemini Models", buckets: sampleGeminiBuckets),
                QuotaGroup(displayName: "Claude & Others", buckets: sampleClaudeBuckets)
            ],
            description: "Antigravity Pro Quota"
        )
    }
    
    public static var offline: QuotaSnapshot {
        QuotaSnapshot(
            timestamp: Date(),
            isOnline: false,
            groups: [],
            description: nil
        )
    }
}
