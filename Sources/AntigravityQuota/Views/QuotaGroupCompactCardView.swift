import SwiftUI
import AntigravityQuotaCore

/// Compact mode card view displaying a minimal overview of quota buckets for a model group.
public struct QuotaGroupCompactCardView: View {
    public let group: QuotaGroup
    public let currentNow: Date
    public let language: AppLanguage
    
    public init(group: QuotaGroup, currentNow: Date = Date(), language: AppLanguage = .en) {
        self.group = group
        self.currentNow = currentNow
        self.language = language
    }
    
    private var isGemini: Bool {
        group.displayName.localizedCaseInsensitiveContains("gemini")
    }
    
    private var groupIconName: String {
        isGemini ? "sparkles" : "bolt.badge.automatic"
    }
    
    private var groupAccentColor: Color {
        isGemini ? Color.indigo : Color.purple
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Group title header
            HStack(spacing: 5) {
                Image(systemName: groupIconName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(groupAccentColor)
                
                Text(group.displayName)
                    .font(.system(size: 12, weight: .bold))
                
                Spacer()
            }
            
            // 5-Hour row
            if let fiveHourBucket = group.fiveHourBucket {
                QuotaBucketCompactRowView(
                    title: LocalizedStringKey.fiveHourShort.string(for: language),
                    bucket: fiveHourBucket,
                    currentNow: currentNow,
                    language: language
                )
            }
            
            // Weekly row
            if let weeklyBucket = group.weeklyBucket {
                QuotaBucketCompactRowView(
                    title: LocalizedStringKey.weeklyShort.string(for: language),
                    bucket: weeklyBucket,
                    currentNow: currentNow,
                    language: language
                )
            }
        }
        .padding(9)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(NSColor.separatorColor).opacity(0.4), lineWidth: 1)
                )
        )
    }
}
