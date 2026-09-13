import Foundation

/// Root envelope for the Connect RPC response.
public struct QuotaEnvelope: Codable {
    public let response: QuotaResponseData?
    
    public init(response: QuotaResponseData?) {
        self.response = response
    }
}

/// Response payload containing quota groups and metadata.
public struct QuotaResponseData: Codable {
    public let groups: [QuotaGroup]
    public let description: String?
    
    public init(groups: [QuotaGroup], description: String? = nil) {
        self.groups = groups
        self.description = description
    }
}

/// A logical grouping of model quotas (e.g., Gemini Models, Claude/GPT models).
public struct QuotaGroup: Codable, Identifiable {
    public var id: String { displayName }
    public let displayName: String
    public let description: String?
    public let buckets: [QuotaBucket]
    
    public init(displayName: String, description: String? = nil, buckets: [QuotaBucket]) {
        self.displayName = displayName
        self.description = description
        self.buckets = buckets
    }
    
    /// Finds the 5-hour window bucket if available.
    public var fiveHourBucket: QuotaBucket? {
        buckets.first(where: { $0.window == "5h" || $0.bucketId.contains("5h") })
    }
    
    /// Finds the weekly window bucket if available.
    public var weeklyBucket: QuotaBucket? {
        buckets.first(where: { $0.window == "weekly" || $0.bucketId.contains("weekly") })
    }
}

/// An individual quota bucket representing a rate-limit window.
public struct QuotaBucket: Codable, Identifiable {
    public var id: String { bucketId }
    public let bucketId: String
    public let displayName: String
    public let description: String?
    public let window: String?
    public let remainingFraction: Double
    public let resetTime: String?
    
    public init(
        bucketId: String,
        displayName: String,
        description: String? = nil,
        window: String? = nil,
        remainingFraction: Double,
        resetTime: String? = nil
    ) {
        self.bucketId = bucketId
        self.displayName = displayName
        self.description = description
        self.window = window
        self.remainingFraction = remainingFraction
        self.resetTime = resetTime
    }
    
    /// Remaining percentage clamped between 0% and 100%.
    public var remainingPercentage: Int {
        let clamped = max(0.0, min(1.0, remainingFraction))
        return Int(round(clamped * 100.0))
    }
    
    /// Used percentage (100% - remaining).
    public var usedPercentage: Int {
        return max(0, 100 - remainingPercentage)
    }
    
    /// Reset timestamp parsed from ISO 8601 string.
    public var parsedResetDate: Date? {
        guard let resetTime else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: resetTime) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: resetTime)
    }
    
    /// Time remaining until reset in seconds.
    public func timeRemaining(from now: Date = Date()) -> TimeInterval {
        guard let resetDate = parsedResetDate else { return 0 }
        return max(0, resetDate.timeIntervalSince(now))
    }
    
    /// Formatted human-readable countdown string supporting multi-language.
    public func formattedTimeRemaining(from now: Date = Date(), language: AppLanguage = .en) -> String {
        guard let resetDate = parsedResetDate else {
            return "-"
        }
        let interval = resetDate.timeIntervalSince(now)
        guard interval > 0 else {
            return LocalizedStringKey.resetComplete.string(for: language)
        }
        
        let seconds = Int(interval)
        let days = seconds / 86400
        let hours = (seconds % 86400) / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if days > 0 {
            return LocalizedStringKey.countdownDaysHours(days: days, hours: hours).string(for: language)
        } else if hours > 0 {
            return LocalizedStringKey.countdownHoursMinutes(hours: hours, minutes: minutes).string(for: language)
        } else if minutes > 0 {
            return LocalizedStringKey.countdownMinutesSeconds(minutes: minutes, seconds: secs).string(for: language)
        } else {
            return LocalizedStringKey.countdownSeconds(seconds: secs).string(for: language)
        }
    }
    
    /// Returns true if this bucket had a resetTime that has now passed and the quota was not already 100%.
    public func isRefilled(at now: Date = Date()) -> Bool {
        guard let resetDate = parsedResetDate else { return false }
        return now >= resetDate && remainingPercentage < 100
    }
    
    /// Returns a copy of the bucket optimistically set to 100% capacity with resetTime cleared.
    public func refilledCopy() -> QuotaBucket {
        return QuotaBucket(
            bucketId: bucketId,
            displayName: displayName,
            description: description,
            window: window,
            remainingFraction: 1.0,
            resetTime: nil
        )
    }
}
