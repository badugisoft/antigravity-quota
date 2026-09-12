import WidgetKit
import SwiftUI
import AntigravityQuotaCore

struct AntigravityQuotaWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: QuotaTimelineEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallQuotaWidgetView(snapshot: entry.snapshot, date: entry.date, language: entry.language)
        case .systemMedium:
            MediumQuotaWidgetView(snapshot: entry.snapshot, date: entry.date, language: entry.language)
        default:
            SmallQuotaWidgetView(snapshot: entry.snapshot, date: entry.date, language: entry.language)
        }
    }
}

@main
struct AntigravityQuotaWidget: Widget {
    let kind: String = "AntigravityQuotaWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuotaTimelineProvider()) { entry in
            AntigravityQuotaWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Antigravity Quota")
        .description("Monitor your Antigravity model quotas directly from your desktop or Notification Center.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}
