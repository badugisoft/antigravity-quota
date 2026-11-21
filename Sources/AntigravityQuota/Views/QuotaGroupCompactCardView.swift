import SwiftUI
import AntigravityQuotaCore

/// Compact mode card view displaying a minimal overview of quota buckets for a model group.
public struct QuotaGroupCompactCardView: View {
    public let group: QuotaGroup
    public let groupIndex: Int
    public let currentNow: Date
    public let language: AppLanguage
    
    private static let stylePalette: [(icon: String, color: Color)] = [
        ("sparkles", .indigo),
        ("bolt.badge.automatic", .purple),
        ("cpu", .teal),
        ("cube", .blue)
    ]
    
    public init(group: QuotaGroup, groupIndex: Int = 0, currentNow: Date = Date(), language: AppLanguage = .en) {
        self.group = group
        self.groupIndex = groupIndex
        self.currentNow = currentNow
        self.language = language
    }
    
    private var groupStyle: (icon: String, color: Color) {
        Self.stylePalette[abs(groupIndex) % Self.stylePalette.count]
    }
    
    private var groupIconName: String {
        groupStyle.icon
    }
    
    private var groupAccentColor: Color {
        groupStyle.color
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
            
            ForEach(group.orderedBuckets) { bucket in
                QuotaBucketCompactRowView(
                    title: bucket.localizedWindowTitle(for: language, short: true),
                    bucket: bucket,
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
