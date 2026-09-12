import SwiftUI
import AntigravityQuotaCore

/// Compact mode row view displaying a minimal progress bar, percentage, and brief countdown.
public struct QuotaBucketCompactRowView: View {
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
        HStack(spacing: 8) {
            // Window label (5h / Weekly)
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(width: 44, alignment: .leading)
            
            // Mini progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(NSColor.separatorColor).opacity(0.3))
                        .frame(height: 5)
                    
                    Capsule()
                        .fill(progressColor)
                        .frame(
                            width: max(0, min(geometry.size.width, geometry.size.width * CGFloat(bucket.remainingFraction))),
                            height: 5
                        )
                }
            }
            .frame(height: 5)
            
            // Remaining percentage
            Text("\(bucket.remainingPercentage)%")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(progressColor)
                .frame(width: 36, alignment: .trailing)
            
            // Time remaining
            Text(bucket.formattedTimeRemaining(from: currentNow, language: language))
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(minWidth: 80, alignment: .trailing)
        }
        .padding(.vertical, 3)
    }
}
