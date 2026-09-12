import SwiftUI
import WidgetKit

public struct MediumQuotaWidgetView: View {
    public let snapshot: QuotaSnapshot
    public let date: Date
    public let language: AppLanguage
    
    public init(snapshot: QuotaSnapshot, date: Date = Date(), language: AppLanguage = .en) {
        self.snapshot = snapshot
        self.date = date
        self.language = language
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                
                Text("Antigravity Quota")
                    .font(.system(size: 13, weight: .bold))
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(snapshot.isOnline ? Color.green : Color.gray.opacity(0.6))
                        .frame(width: 6.5, height: 6.5)
                    
                    Text(snapshot.isOnline ? "Online" : LocalizedStringKey.statusOffline.string(for: language))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("·")
                        .foregroundColor(.secondary)
                        .font(.system(size: 11))
                    
                    Text(timeFormatter.string(from: snapshot.timestamp))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            Divider().opacity(0.5)
            
            if !snapshot.isOnline && snapshot.groups.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.secondary)
                        Text(LocalizedStringKey.waitingForConnection.string(for: language))
                            .font(.system(size: 12.5, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                Spacer()
            } else {
                HStack(alignment: .top, spacing: 16) {
                    // Left Column: Gemini
                    if let geminiGroup = snapshot.geminiGroup {
                        groupColumn(group: geminiGroup, title: "Gemini Models")
                    } else {
                        placeholderColumn(title: "Gemini Models")
                    }
                    
                    Divider().opacity(0.5)
                    
                    // Right Column: Claude & GPT
                    if let claudeGroup = snapshot.claudeGptGroup {
                        groupColumn(group: claudeGroup, title: "Claude & GPT")
                    } else {
                        placeholderColumn(title: "Claude & GPT")
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .applyWidgetBackground()
    }
    
    @ViewBuilder
    private func groupColumn(group: QuotaGroup, title: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            if let fiveH = group.fiveHourBucket {
                bucketRow(
                    label: LocalizedStringKey.fiveHourShort.string(for: language),
                    bucket: fiveH
                )
            }
            
            if let weekly = group.weeklyBucket {
                bucketRow(
                    label: LocalizedStringKey.weeklyShort.string(for: language),
                    bucket: weekly
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func placeholderColumn(title: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
            Text("-")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func bucketRow(label: String, bucket: QuotaBucket) -> some View {
        VStack(alignment: .leading, spacing: 2.5) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(bucket.remainingPercentage)%")
                    .font(.system(size: 11.5, weight: .bold, design: .rounded))
                    .foregroundColor(colorForPercentage(bucket.remainingPercentage))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.12))
                        .frame(height: 5.5)
                    
                    Capsule()
                        .fill(colorForPercentage(bucket.remainingPercentage))
                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(bucket.remainingFraction))), height: 5.5)
                }
            }
            .frame(height: 5.5)
            
            HStack {
                Spacer()
                Text(bucket.formattedTimeRemaining(from: date, language: language))
                    .font(.system(size: 9.5))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func colorForPercentage(_ percentage: Int) -> Color {
        if percentage >= 50 {
            return .green
        } else if percentage >= 20 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.locale = language.locale
        f.timeStyle = .short
        f.dateStyle = .none
        return f
    }
}
