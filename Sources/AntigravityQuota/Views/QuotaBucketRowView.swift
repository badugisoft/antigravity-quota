import SwiftUI
import AntigravityQuotaCore

/// Standard mode row view displaying a quota bucket with progress bar, percentage, and countdown.
public struct QuotaBucketRowView: View {
    public let title: String
    public let bucket: QuotaBucket
    public let currentNow: Date
    public let language: AppLanguage
    
    public init(title: String, bucket: QuotaBucket, currentNow: Date = Date(), language: AppLanguage = .en) {
        self.title = title
        self.bucket = bucket
        self.currentNow = currentNow
        self.language = language
    }
    
    private var progressColor: Color {
        let remaining = bucket.remainingFraction
        if remaining > 0.5 {
            return Color.blue
        } else if remaining > 0.2 {
            return Color.orange
        } else {
            return Color.red
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Label & Percentages
            HStack {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Remaining and used percentages
                HStack(spacing: 4) {
                    Text(LocalizedStringKey.remaining(percent: bucket.remainingPercentage).string(for: language))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(progressColor)
                    
                    Text(LocalizedStringKey.used(percent: bucket.usedPercentage).string(for: language))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(NSColor.separatorColor).opacity(0.3))
                        .frame(height: 7)
                    
                    // Remaining amount bar
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [progressColor.opacity(0.8), progressColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max(0, min(geometry.size.width, geometry.size.width * CGFloat(bucket.remainingFraction))),
                            height: 7
                        )
                        .animation(.easeInOut(duration: 0.3), value: bucket.remainingFraction)
                }
            }
            .frame(height: 7)
            
            // Reset countdown & scheduled time
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                
                Text(bucket.formattedTimeRemaining(from: currentNow, language: language))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let resetDate = bucket.parsedResetDate, !bucket.isFull {
                    Text(resetDate.formattedShortTime(for: language))
                        .font(.system(size: 9))
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }
        }
        .padding(7)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(7)
    }
}
