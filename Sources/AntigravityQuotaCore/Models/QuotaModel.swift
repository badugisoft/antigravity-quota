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
        buckets.first(where: { $0.isFiveHourWindow })
    }
    
    /// Finds the weekly window bucket if available.
    public var weeklyBucket: QuotaBucket? {
        buckets.first(where: { $0.isWeeklyWindow })
    }
    
    /// Returns the primary bucket for summary/compact displays (5-hour preferred, otherwise first bucket).
    public var primaryBucket: QuotaBucket? {
        fiveHourBucket ?? buckets.first
    }
    
    /// Returns buckets ordered with 5-hour windows first, followed by weekly windows, then any others.
    public var orderedBuckets: [QuotaBucket] {
        let fiveHour = buckets.filter { $0.isFiveHourWindow }
        let weekly = buckets.filter { !$0.isFiveHourWindow && $0.isWeeklyWindow }
        let others = buckets.filter { !$0.isFiveHourWindow && !$0.isWeeklyWindow }
        return fiveHour + weekly + others
    }
    
    /// Derives a concise display name without hardcoding model names.
    public var shortDisplayName: String {
        var name = displayName.replacingOccurrences(of: " and ", with: " & ")
        for suffix in [" Models", " models"] {
            if name.hasSuffix(suffix) {
                name = String(name.dropLast(suffix.count))
                break
            }
        }
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Computes unique short abbreviations for a list of groups dynamically from their display names.
    public static func dynamicAbbreviations(for groups: [QuotaGroup]) -> [String: String] {
        let ignoredWords: Set<String> = ["models", "model", "and", "&", "quota", "limit"]
        var used: Set<String> = []
        var result: [String: String] = [:]
        
        for group in groups {
            let words = group.displayName
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty }
            let significant = words.filter { word in
                let lower = word.lowercased()
                return !ignoredWords.contains(lower) && word.rangeOfCharacter(from: .letters) != nil
            }
            
            var chosen: String?
            if let first = significant.first, let ch = first.first {
                let candidate = String(ch).uppercased()
                if !used.contains(candidate) {
                    chosen = candidate
                }
            }
            
            if chosen == nil, let last = significant.last, let ch = last.first {
                let candidate = String(ch).uppercased()
                if !used.contains(candidate) {
                    chosen = candidate
                }
            }
            
            if chosen == nil {
                for word in significant.reversed() {
                    if let ch = word.first {
                        let candidate = String(ch).uppercased()
                        if !used.contains(candidate) {
                            chosen = candidate
                            break
                        }
                    }
                }
            }
            
            if chosen == nil, let first = significant.first {
                let two = String(first.prefix(2)).uppercased()
                chosen = two
            }
            
            let finalAbbr = chosen ?? String(group.displayName.prefix(1)).uppercased()
            used.insert(finalAbbr)
            result[group.id] = finalAbbr
        }
        
        return result
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
    
    public var isFiveHourWindow: Bool {
        window == "5h" || bucketId.lowercased().contains("5h")
    }
    
    public var isWeeklyWindow: Bool {
        window == "weekly" || bucketId.lowercased().contains("week")
    }
    
    /// Returns a localized window title (short or full) based on the bucket window type.
    public func localizedWindowTitle(for language: AppLanguage, short: Bool) -> String {
        if isFiveHourWindow {
            return (short ? LocalizedStringKey.fiveHourShort : LocalizedStringKey.fiveHourResetTitle).string(for: language)
        } else if isWeeklyWindow {
            return (short ? LocalizedStringKey.weeklyShort : LocalizedStringKey.weeklyResetTitle).string(for: language)
        }
        return window ?? displayName
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
    
    /// Returns true if the quota is completely unused / 100% capacity (remainingFraction >= 1.0).
    public var isFull: Bool {
        return remainingFraction >= 1.0 - 0.0001
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
    
    /// Time remaining until reset in seconds. Returns 0 if quota is already 100% full.
    public func timeRemaining(from now: Date = Date()) -> TimeInterval {
        guard !isFull, let resetDate = parsedResetDate else { return 0 }
        return max(0, resetDate.timeIntervalSince(now))
    }
    
    /// Formatted human-readable countdown string supporting multi-language.
    public func formattedTimeRemaining(from now: Date = Date(), language: AppLanguage = .en) -> String {
        if isFull {
            return LocalizedStringKey.quotaUnused.string(for: language)
        }
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
