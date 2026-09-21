import SwiftUI
import AntigravityQuotaCore

/// Main popover view displayed when clicking the menu bar icon.
public struct MenuBarPopoverView: View {
    @ObservedObject public var viewModel: QuotaViewModel
    @ObservedObject private var localization: LocalizationManager
    
    public init(viewModel: QuotaViewModel) {
        self.viewModel = viewModel
        self.localization = viewModel.localization
    }
    
    private var statusBadgeText: String {
        if !viewModel.isServerOnline {
            return localization.string(.statusOffline)
        }
        if viewModel.isRemoteConnection {
            return "\(localization.string(.remoteTab)) (\(viewModel.settings.remoteSSHInterval)s)"
        }
        return viewModel.isAntigravityActive
            ? localization.string(.statusActive(seconds: 15))
            : localization.string(.statusIdle(minutes: 1))
    }
    
    private var statusBadgeColor: Color {
        if !viewModel.isServerOnline {
            return Color.orange
        }
        if viewModel.isRemoteConnection {
            return Color.purple
        }
        return viewModel.isAntigravityActive ? Color.green : Color.blue
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: viewModel.isCompactMode ? 8 : 12) {
            // Header: Status indicator, Title, Status badge, Language toggle, Compact toggle
            HStack(alignment: .center, spacing: 6) {
                Circle()
                    .fill(viewModel.isServerOnline ? (viewModel.isRemoteConnection ? Color.purple : Color.green) : Color.orange)
                    .frame(width: 8, height: 8)
                
                Text("Antigravity Quota")
                    .font(.system(size: viewModel.isCompactMode ? 13 : 14, weight: .bold))
                
                Spacer()
                
                // Status badge (15s active vs 1m idle vs offline)
                Text(statusBadgeText)
                    .font(.system(size: 9, weight: .medium))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(statusBadgeColor.opacity(0.15))
                    .foregroundColor(statusBadgeColor)
                    .cornerRadius(4)
                
                // Language switch dropdown menu
                Menu {
                    ForEach(AppLanguage.allCases) { lang in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                localization.currentLanguage = lang
                            }
                        }) {
                            if localization.currentLanguage == lang {
                                Text("✓ \(lang.displayName)")
                            } else {
                                Text("   \(lang.displayName)")
                            }
                        }
                    }
                } label: {
                    Text(localization.currentLanguage.shortName)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color(NSColor.separatorColor).opacity(0.15))
                        .cornerRadius(4)
                        .contentShape(Rectangle())
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                .focusable(false)
                .help(localization.string(.tooltipSwitchLanguage))
                
                // Compact / Standard mode toggle button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.isCompactMode.toggle()
                    }
                }) {
                    Image(systemName: viewModel.isCompactMode ? "rectangle.expand.vertical" : "rectangle.compress.vertical")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(3)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .focusable(false)
                .help(localization.string(viewModel.isCompactMode ? .tooltipSwitchToStandard : .tooltipSwitchToCompact))
                
                // Settings button
                Button(action: {
                    SettingsWindowController.shared.showSettings()
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(3)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .focusable(false)
                .help(localization.string(.settings))
            }
            .padding(.horizontal, 2)
            
            // Quota groups list or empty/connecting state
            if viewModel.groups.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                    
                    Text(viewModel.isServerOnline
                         ? localization.string(.loadingQuota)
                         : localization.string(.waitingForConnection))
                        .font(.system(size: 12, weight: .semibold))
                    
                    Text(localization.string(.connectionDescription))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.4))
                .cornerRadius(8)
            } else {
                VStack(spacing: viewModel.isCompactMode ? 6 : 10) {
                    // 1. Gemini Group
                    if let gemini = viewModel.geminiGroup {
                        if viewModel.isCompactMode {
                            QuotaGroupCompactCardView(group: gemini, currentNow: viewModel.currentNow, language: localization.currentLanguage)
                        } else {
                            QuotaGroupCardView(group: gemini, currentNow: viewModel.currentNow, language: localization.currentLanguage)
                        }
                    }
                    
                    // 2. Claude & GPT Group
                    if let claudeGpt = viewModel.claudeGptGroup {
                        if viewModel.isCompactMode {
                            QuotaGroupCompactCardView(group: claudeGpt, currentNow: viewModel.currentNow, language: localization.currentLanguage)
                        } else {
                            QuotaGroupCardView(group: claudeGpt, currentNow: viewModel.currentNow, language: localization.currentLanguage)
                        }
                    }
                    
                    // Any additional groups
                    ForEach(viewModel.groups.filter {
                        $0.id != viewModel.geminiGroup?.id &&
                        $0.id != viewModel.claudeGptGroup?.id
                    }) { otherGroup in
                        if viewModel.isCompactMode {
                            QuotaGroupCompactCardView(group: otherGroup, currentNow: viewModel.currentNow, language: localization.currentLanguage)
                        } else {
                            QuotaGroupCardView(group: otherGroup, currentNow: viewModel.currentNow, language: localization.currentLanguage)
                        }
                    }
                }
            }
            
            Divider()
            
            // Bottom bar: Refresh button, Last updated time, Quit button
            HStack {
                Button(action: {
                    Task {
                        await viewModel.refresh()
                    }
                }) {
                    HStack(spacing: 4) {
                        if viewModel.isLoading {
                            ProgressView()
                                .scaleEffect(0.55)
                                .frame(width: 10, height: 10)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 10))
                        }
                        Text(localization.string(.refresh))
                            .font(.system(size: 10))
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .focusable(false)
                .disabled(viewModel.isLoading)
                .foregroundColor(.accentColor)
                
                Spacer()
                
                if let lastUpdated = viewModel.lastUpdated {
                    let formatted = lastUpdated.formattedTime(for: localization.currentLanguage)
                    Text(formatted)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                        .help(localization.string(.lastUpdated(time: formatted)))
                }
                
                Spacer()
                
                Button(localization.string(.quit)) {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .focusable(false)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .contentShape(Rectangle())
            }
            .padding(.horizontal, 2)
        }
        .padding(12)
        .frame(width: 340)
        .environment(\.locale, localization.currentLanguage.locale)
    }
}
