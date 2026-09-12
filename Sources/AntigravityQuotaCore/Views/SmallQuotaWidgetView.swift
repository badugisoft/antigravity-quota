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
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 5) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                
                Text("AGY Quota")
                    .font(.system(size: 12.5, weight: .bold))
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
                Spacer(minLength: 6)
                
                VStack(spacing: 9) {
                    // Gemini Row
                    if let geminiGroup = snapshot.geminiGroup,
                       let bucket = geminiGroup.fiveHourBucket ?? geminiGroup.buckets.first {
                        quotaRow(
                            title: "Gemini",
                            percentage: bucket.remainingPercentage,
                            fraction: bucket.remainingFraction
                        )
                    }
                    
                    // Claude / GPT Row
                    if let claudeGroup = snapshot.claudeGptGroup,
                       let bucket = claudeGroup.fiveHourBucket ?? claudeGroup.buckets.first {
                        quotaRow(
                            title: "Claude",
                            percentage: bucket.remainingPercentage,
                            fraction: bucket.remainingFraction
                        )
                    }
                }
                
                Spacer(minLength: 6)
                
                // Footer: Nearest reset timer
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(snapshot.formattedNearestReset(from: date, language: language))
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .applyWidgetBackground()
    }
    
    @ViewBuilder
    private func quotaRow(title: String, percentage: Int, fraction: Double) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(title)
                    .font(.system(size: 12.5, weight: .semibold))
                Spacer()
                Text("\(percentage)%")
                    .font(.system(size: 13.5, weight: .bold, design: .rounded))
                    .foregroundColor(colorForPercentage(percentage))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.12))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(colorForPercentage(percentage))
                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(fraction))), height: 6)
                }
            }
            .frame(height: 6)
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
}
