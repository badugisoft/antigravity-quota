import Foundation
import UserNotifications
#if canImport(AppKit)
import AppKit
#endif

/// Handles local notifications for quota resets and refills.
public final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    private var notifiedKeys = Set<String>()
    
    public override init() {
        super.init()
        center.delegate = self
    }
    
    /// Requests notification permissions if not already determined.
    public func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        center.requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("[NotificationManager] Authorization error: \(error.localizedDescription)")
            }
            completion?(granted)
        }
    }
    
    /// Queries the current system notification authorization status.
    public func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    /// Opens macOS System Settings directly to Notifications.
    public func openSystemNotificationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
    }

    
    /// Sends a local notification when a quota bucket is refilled.
    public func notifyQuotaRefilled(
        modelName: String,
        window: String,
        resetKey: String,
        settings: AppSettings = .shared,
        language: AppLanguage = AppLanguage.currentPreference
    ) {
        guard settings.notifyQuotaRefilled else { return }
        
        // Filter by window type
        let isWeekly = window.lowercased().contains("week") || resetKey.lowercased().contains("week")
        if isWeekly && !settings.notifyWeeklyReset { return }
        if !isWeekly && !settings.notifyFiveHourReset { return }
        
        // Prevent duplicate notification for the exact same reset window
        guard !notifiedKeys.contains(resetKey) else { return }
        notifiedKeys.insert(resetKey)
        
        center.getNotificationSettings { [weak self] currentSettings in
            guard let self = self else { return }
            
            if currentSettings.authorizationStatus == .authorized || currentSettings.authorizationStatus == .provisional {
                self.dispatchRefillNotification(
                    modelName: modelName,
                    window: window,
                    resetKey: resetKey,
                    settings: settings,
                    language: language
                )
            } else if currentSettings.authorizationStatus == .notDetermined {
                self.requestAuthorization { granted in
                    if granted {
                        self.dispatchRefillNotification(
                            modelName: modelName,
                            window: window,
                            resetKey: resetKey,
                            settings: settings,
                            language: language
                        )
                    }
                }
            }
        }
    }
    
    private func dispatchRefillNotification(
        modelName: String,
        window: String,
        resetKey: String,
        settings: AppSettings,
        language: AppLanguage
    ) {
        let content = UNMutableNotificationContent()
        content.title = LocalizedStringKey.notificationTitleRefilled.string(for: language)
        content.body = LocalizedStringKey.notificationBodyRefilled(model: modelName, window: window).string(for: language)
        content.sound = .default
        
        // Use a short 0.2s trigger so macOS usernoted daemon schedules it cleanly
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.2, repeats: false)
        let request = UNNotificationRequest(
            identifier: "quota-refill-\(resetKey)-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("[NotificationManager] Error delivering refill notification: \(error.localizedDescription)")
            }
        }
    }
    
    /// Sends an immediate test notification to verify delivery and sound.
    public func sendTestNotification(
        settings: AppSettings = .shared,
        language: AppLanguage = AppLanguage.currentPreference,
        completion: ((Bool) -> Void)? = nil
    ) {
        center.getNotificationSettings { [weak self] currentSettings in
            guard let self = self else { return }
            
            switch currentSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization { granted in
                    if granted {
                        self.dispatchTestNotification(settings: settings, language: language, completion: completion)
                    } else {
                        completion?(false)
                    }
                }
            case .denied:
                print("[NotificationManager] Notification permission denied in macOS System Settings.")
                completion?(false)
            default:
                self.dispatchTestNotification(settings: settings, language: language, completion: completion)
            }
        }
    }
    
    private func dispatchTestNotification(
        settings: AppSettings,
        language: AppLanguage,
        completion: ((Bool) -> Void)?
    ) {
        let content = UNMutableNotificationContent()
        content.title = LocalizedStringKey.notificationTitleRefilled.string(for: language)
        content.body = LocalizedStringKey.notificationTestBody.string(for: language)
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.2, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test-notification-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("[NotificationManager] Error delivering test notification: \(error.localizedDescription)")
                completion?(false)
            } else {
                completion?(true)
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner and play sound even when app is active/foreground
        if #available(macOS 14.0, *) {
            completionHandler([.banner, .sound, .badge, .list])
        } else if #available(macOS 11.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
}
