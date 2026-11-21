import SwiftUI
import AntigravityQuotaCore

/// Standard mode card view displaying a group of quota buckets with model icons.
public struct QuotaGroupCardView: View {
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
            
            ForEach(group.orderedBuckets) { bucket in
                QuotaBucketRowView(
                    title: bucket.localizedWindowTitle(for: language, short: false),
                    bucket: bucket,
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
