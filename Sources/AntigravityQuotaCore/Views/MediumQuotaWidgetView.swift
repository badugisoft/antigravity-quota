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
    
    private var topGroups: [QuotaGroup] {
        Array(snapshot.groups.prefix(2))
    }
    
    private var extraGroups: [QuotaGroup] {
        Array(snapshot.groups.dropFirst(2))
    }
    
    private var hasExtraGroups: Bool {
        !extraGroups.isEmpty
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: hasExtraGroups ? 0 : 9) {
            // Header
            VStack(alignment: .leading, spacing: hasExtraGroups ? 6 : 9) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: hasExtraGroups ? 13 : 14, weight: .semibold))
                        .foregroundStyle(LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    
                    Text("Antigravity Quota")
                        .font(.system(size: hasExtraGroups ? 12.5 : 13, weight: .bold))
                    
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
            }
            
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
                if hasExtraGroups {
                    Spacer(minLength: 4)
                }
                
                HStack(alignment: .top, spacing: 14) {
                    ForEach(Array(topGroups.enumerated()), id: \.element.id) { index, group in
                        if index > 0 {
                            Divider().opacity(0.5)
                        }
                        groupColumn(group: group, compact: hasExtraGroups)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                
                if hasExtraGroups {
                    Spacer(minLength: 4)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Divider().opacity(0.4)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            ForEach(extraGroups) { group in
                                ForEach(group.orderedBuckets) { bucket in
                                    extraBucketRow(group: group, bucket: bucket)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, hasExtraGroups ? 11 : 13)
        .applyWidgetBackground()
    }
    
    @ViewBuilder
    private func groupColumn(group: QuotaGroup, compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: compact ? 6 : 7) {
            Text(group.shortDisplayName)
                .font(.system(size: compact ? 11.5 : 12, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            
            ForEach(group.orderedBuckets) { bucket in
                bucketRow(
                    label: bucket.localizedWindowTitle(for: language, short: true),
                    bucket: bucket,
                    compact: compact
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func bucketRow(label: String, bucket: QuotaBucket, compact: Bool) -> some View {
        let barHeight: CGFloat = compact ? 5 : 5.5
        VStack(alignment: .leading, spacing: compact ? 3 : 2.5) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.system(size: compact ? 10.5 : 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                if compact {
                    Text("· \(bucket.formattedTimeRemaining(from: date, language: language))")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary.opacity(0.85))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                Spacer(minLength: 2)
                Text("\(bucket.remainingPercentage)%")
                    .font(.system(size: compact ? 11 : 11.5, weight: .bold, design: .rounded))
                    .foregroundColor(colorForPercentage(bucket.remainingPercentage))
                    .fixedSize(horizontal: true, vertical: false)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.12))
                        .frame(height: barHeight)
                    
                    Capsule()
                        .fill(colorForPercentage(bucket.remainingPercentage))
                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(bucket.remainingFraction))), height: barHeight)
                }
            }
            .frame(height: barHeight)
            
            if !compact {
                HStack {
                    Spacer()
                    Text(bucket.formattedTimeRemaining(from: date, language: language))
                        .font(.system(size: 9.5))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func extraBucketRow(group: QuotaGroup, bucket: QuotaBucket) -> some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                Text(group.shortDisplayName)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text("(\(bucket.localizedWindowTitle(for: language, short: true)))")
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .fixedSize(horizontal: true, vertical: false)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.12))
                        .frame(height: 4.5)
                    
                    Capsule()
                        .fill(colorForPercentage(bucket.remainingPercentage))
                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(bucket.remainingFraction))), height: 4.5)
                }
            }
            .frame(height: 4.5)
            
            HStack(spacing: 5) {
                Text("\(bucket.remainingPercentage)%")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(colorForPercentage(bucket.remainingPercentage))
                Text(bucket.formattedTimeRemaining(from: date, language: language))
                    .font(.system(size: 9.5))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
    }
    
    private func colorForPercentage(_ percentage: Int) -> Color {
        if percentage > 50 {
            return .blue
        } else if percentage > 20 {
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
