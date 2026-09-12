import SwiftUI
import AntigravityQuotaCore

/// Standard mode card view displaying a group of quota buckets with model icons.
public struct QuotaGroupCardView: View {
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
        VStack(alignment: .leading, spacing: 8) {
            // Header: Group Icon, Display Name, Supported Models
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(groupAccentColor.opacity(0.15))
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: groupIconName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(groupAccentColor)
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(group.displayName)
                        .font(.system(size: 12, weight: .bold))
                    
                    if let desc = group.description {
                        Text(desc.replacingOccurrences(of: "Models within this group: ", with: ""))
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
            }
            
            // 5-Hour reset bucket
            if let fiveHourBucket = group.fiveHourBucket {
                QuotaBucketRowView(
                    title: LocalizedStringKey.fiveHourResetTitle.string(for: language),
                    bucket: fiveHourBucket,
                    currentNow: currentNow,
                    language: language
                )
            }
            
            // Weekly reset bucket
            if let weeklyBucket = group.weeklyBucket {
                QuotaBucketRowView(
                    title: LocalizedStringKey.weeklyResetTitle.string(for: language),
                    bucket: weeklyBucket,
                    currentNow: currentNow,
                    language: language
                )
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(NSColor.separatorColor).opacity(0.4), lineWidth: 1)
                )
        )
    }
}
