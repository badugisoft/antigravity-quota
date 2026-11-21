import SwiftUI
import WidgetKit

public struct SmallQuotaWidgetView: View {
    public let snapshot: QuotaSnapshot
    public let date: Date
    public let language: AppLanguage
    
    public init(snapshot: QuotaSnapshot, date: Date = Date(), language: AppLanguage = .en) {
        self.snapshot = snapshot
        self.date = date
        self.language = language
    }
    
    private var isDense: Bool {
        snapshot.groups.count >= 3
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 5) {
                Image(systemName: "sparkles")
                    .font(.system(size: isDense ? 12 : 13, weight: .semibold))
                    .foregroundStyle(LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                
                Text("AGY Quota")
                    .font(.system(size: isDense ? 12 : 12.5, weight: .bold))
                    .lineLimit(1)
                
                Spacer()
                
                Circle()
                    .fill(snapshot.isOnline ? Color.green : Color.gray.opacity(0.6))
                    .frame(width: 7, height: 7)
            }
            
            if !snapshot.isOnline && snapshot.groups.isEmpty {
                Spacer()
                VStack(spacing: 6) {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.secondary)
                    Text(LocalizedStringKey.statusOffline.string(for: language))
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                Spacer(minLength: isDense ? 4 : 6)
                
                VStack(spacing: isDense ? 5 : 9) {
                    ForEach(snapshot.groups) { group in
                        if let bucket = group.primaryBucket {
                            quotaRow(
                                title: group.shortDisplayName,
                                percentage: bucket.remainingPercentage,
                                fraction: bucket.remainingFraction
                            )
                        }
                    }
                }
                
                Spacer(minLength: isDense ? 4 : 6)
                
                // Footer: Nearest reset timer
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: isDense ? 9.5 : 10, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(snapshot.formattedNearestReset(from: date, language: language))
                        .font(.system(size: isDense ? 10 : 10.5, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, isDense ? 10 : 12)
        .applyWidgetBackground()
    }
    
    @ViewBuilder
    private func quotaRow(title: String, percentage: Int, fraction: Double) -> some View {
        let barHeight: CGFloat = isDense ? 4.5 : 6
        VStack(alignment: .leading, spacing: isDense ? 2 : 3) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: isDense ? 11 : 12.5, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 2)
                Text("\(percentage)%")
                    .font(.system(size: isDense ? 12 : 13.5, weight: .bold, design: .rounded))
                    .foregroundColor(colorForPercentage(percentage))
                    .fixedSize(horizontal: true, vertical: false)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.12))
                        .frame(height: barHeight)
                    
                    Capsule()
                        .fill(colorForPercentage(percentage))
                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(fraction))), height: barHeight)
                }
            }
            .frame(height: barHeight)
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
}
