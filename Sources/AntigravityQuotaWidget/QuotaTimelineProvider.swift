import WidgetKit
import SwiftUI
import AntigravityQuotaCore

public struct QuotaTimelineEntry: TimelineEntry {
    public let date: Date
    public let snapshot: QuotaSnapshot
    public let language: AppLanguage
    
    public init(date: Date, snapshot: QuotaSnapshot, language: AppLanguage) {
        self.date = date
        self.snapshot = snapshot
        self.language = language
    }
}

public struct QuotaTimelineProvider: TimelineProvider {
    public init() {}
    
    public func placeholder(in context: Context) -> QuotaTimelineEntry {
        let snapshot = QuotaSnapshot.placeholder
        return QuotaTimelineEntry(
            date: Date(),
            snapshot: snapshot,
            language: snapshot.preferredLanguage
        )
    }
    
    public func getSnapshot(in context: Context, completion: @escaping (QuotaTimelineEntry) -> Void) {
        let snapshot = context.isPreview ? .placeholder : QuotaDataStore.shared.loadLatestSnapshot()
        let entry = QuotaTimelineEntry(
            date: Date(),
            snapshot: snapshot,
            language: snapshot.preferredLanguage
        )
        completion(entry)
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<QuotaTimelineEntry>) -> Void) {
        let snapshot = QuotaDataStore.shared.loadLatestSnapshot()
        let language = snapshot.preferredLanguage
        let currentDate = Date()
        let entry = QuotaTimelineEntry(date: currentDate, snapshot: snapshot, language: language)
        
        // Refresh every 15 minutes or earlier if a reset happens soon
        let nextUpdate: Date
        if let nearest = snapshot.nearestResetDate, nearest > currentDate, nearest.timeIntervalSince(currentDate) < 900 {
            nextUpdate = nearest.addingTimeInterval(5)
        } else {
            nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate) ?? currentDate.addingTimeInterval(900)
        }
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}
