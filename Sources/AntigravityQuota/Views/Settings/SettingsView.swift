import SwiftUI
import UserNotifications
import AntigravityQuotaCore

/// Native macOS settings view organizing general preferences and notification rules.
@MainActor
public struct SettingsView: View {
    @ObservedObject public var settings: AppSettings
    @ObservedObject public var localization: LocalizationManager
    
    @State private var selectedTab: SettingsTab = .general
    @State private var testNotificationSent: Bool = false
    @State private var permissionStatus: UNAuthorizationStatus = .notDetermined
    
    private var isSystemAuthorized: Bool {
        permissionStatus == .authorized || permissionStatus == .provisional
    }
    
    public enum SettingsTab: String, CaseIterable, Identifiable {
        case general
        case notifications
        
        public var id: String { rawValue }
    }
    
    public init(settings: AppSettings = .shared, localization: LocalizationManager? = nil) {
        self.settings = settings
        self.localization = localization ?? LocalizationManager.shared
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            generalTabContent
                .tabItem {
                    Label(localization.string(.generalTab), systemImage: "gearshape")
                }
                .tag(SettingsTab.general)
            
            notificationsTabContent
                .tabItem {
                    Label(localization.string(.notificationsTab), systemImage: "bell.badge")
                }
                .tag(SettingsTab.notifications)
        }
        .padding(20)
        .frame(width: 490, height: 410)
        .environment(\.locale, localization.currentLanguage.locale)
        .onAppear {
            refreshPermissionStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            refreshPermissionStatus()
        }
    }
    
    private func refreshPermissionStatus() {
        NotificationManager.shared.getAuthorizationStatus { status in
            self.permissionStatus = status
        }
    }
    
    // MARK: - General Tab Content
    
    private var generalTabContent: some View {
        Form {
            Section {
                // Launch at Login
                Toggle(isOn: $settings.launchAtLogin) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(localization.string(.launchAtLogin))
                            .fontWeight(.medium)
                        Text(localization.string(.launchAtLoginDescription))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(.checkbox)
                .padding(.vertical, 4)
                
                Divider()
                    .padding(.vertical, 4)
                
                // Menu Bar Display Mode
                Picker(localization.string(.menuBarStyle), selection: $settings.showMenuBarText) {
                    Text(localization.string(.menuBarIconAndText)).tag(true)
                    Text(localization.string(.menuBarIconOnly)).tag(false)
                }
                .pickerStyle(.radioGroup)
                .padding(.vertical, 4)
                
                // Menu Bar Gauge Target Selection
                Picker(localization.string(.menuBarGaugeSource), selection: $settings.menuBarGaugeSource) {
                    Text(localization.string(.gaugeGemini5h)).tag(MenuBarGaugeSource.gemini5h)
                    Text(localization.string(.gaugeGeminiWeekly)).tag(MenuBarGaugeSource.geminiWeekly)
                    Text(localization.string(.gaugeClaude5h)).tag(MenuBarGaugeSource.claude5h)
                    Text(localization.string(.gaugeClaudeWeekly)).tag(MenuBarGaugeSource.claudeWeekly)
                }
                .pickerStyle(.menu)
                .padding(.vertical, 4)
                
                Divider()
                    .padding(.vertical, 4)
                
                // Popover Default Layout
                Picker(localization.string(.popoverStyle), selection: $settings.isCompactMode) {
                    Text(localization.string(.standardMode)).tag(false)
                    Text(localization.string(.compactMode)).tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 4)
                
                // Language Selection
                Picker(localization.string(.language), selection: $localization.currentLanguage) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .pickerStyle(.menu)
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Notifications Tab Content
    
    private var notificationsTabContent: some View {
        Form {
            Section {
                if !isSystemAuthorized {
                    // System Permission Required Banner Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 14))
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(localization.string(.notificationPermissionRequired))
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text(localization.string(.notificationPermissionDescription))
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        HStack(spacing: 8) {
                            if permissionStatus == .notDetermined {
                                Button(action: {
                                    NotificationManager.shared.requestAuthorization { _ in
                                        refreshPermissionStatus()
                                    }
                                }) {
                                    Text(localization.string(.requestPermission))
                                }
                                .controlSize(.small)
                            }
                            
                            Button(action: {
                                NotificationManager.shared.openSystemNotificationSettings()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.forward.app")
                                    Text(localization.string(.openSystemSettings))
                                }
                            }
                            .controlSize(.small)
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.12))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                    )
                    .padding(.bottom, 6)
                }
                
                // Master Toggle
                Toggle(isOn: $settings.notifyQuotaRefilled) {
                    Text(localization.string(.enableNotifications))
                        .fontWeight(.semibold)
                }
                .toggleStyle(.checkbox)
                .disabled(!isSystemAuthorized)
                .padding(.bottom, 6)
                
                Group {
                    // 5-Hour Alert Toggle
                    Toggle(isOn: $settings.notifyFiveHourReset) {
                        Text(localization.string(.notifyFiveHour))
                    }
                    .toggleStyle(.checkbox)
                    .padding(.leading, 18)
                    
                    // Weekly Alert Toggle
                    Toggle(isOn: $settings.notifyWeeklyReset) {
                        Text(localization.string(.notifyWeekly))
                    }
                    .toggleStyle(.checkbox)
                    .padding(.leading, 18)
                    
                    Divider()
                        .padding(.vertical, 6)
                    
                    // Test Notification Button
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Button(action: {
                                NotificationManager.shared.sendTestNotification(
                                    settings: settings,
                                    language: localization.currentLanguage
                                ) { success in
                                    DispatchQueue.main.async {
                                        refreshPermissionStatus()
                                        if success {
                                            testNotificationSent = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                testNotificationSent = false
                                            }
                                        }
                                    }
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 11))
                                    Text(localization.string(.sendTestNotification))
                                }
                            }
                            
                            if testNotificationSent {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .transition(.opacity)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                .disabled(!isSystemAuthorized || !settings.notifyQuotaRefilled)
            }
        }
    }
}
