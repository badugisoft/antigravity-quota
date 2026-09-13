import Foundation
import UserNotifications
#if canImport(AppKit)
import AppKit
#endif

/// Handles local notifications for quota resets and refills.
public final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationManager()
    
    private var isSupported: Bool {
        guard NSClassFromString("XCTestCase") == nil else { return false }
        return Bundle.main.bundleURL.pathExtension == "app"
    }
    
    private var center: UNUserNotificationCenter? {
        guard isSupported else { return nil }
        return UNUserNotificationCenter.current()
    }
    private var notifiedKeys = Set<String>()
    
    public override init() {
        super.init()
        if isSupported {
            center?.delegate = self
        }
    }
    
    /// Requests notification permissions if not already determined.
    public func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        guard let center = center else {
            completion?(false)
            return
        }
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
        guard let center = center else {
            completion(.notDetermined)
            return
        }
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

    
    /// Returns the unique notification identifier for a specific bucket.
    private func identifierForBucket(bucketId: String) -> String {
        return "quota-refill-\(bucketId)"
    }
    
    /// Schedules a pre-registered system notification to fire at targetDate when a quota bucket refills to 100%.
    /// If targetDate changes, existing scheduled requests for this bucket are automatically replaced.
    public func scheduleQuotaRefillAlert(
        bucketId: String,
        modelName: String,
        window: String,
        targetDate: Date,
        settings: AppSettings = .shared,
        language: AppLanguage = AppLanguage.currentPreference
    ) {
        guard settings.notifyQuotaRefilled else {
            cancelScheduledRefillAlert(bucketId: bucketId)
            return
        }
        
        let isWeekly = window.lowercased().contains("week") || bucketId.lowercased().contains("week")
        if isWeekly && !settings.notifyWeeklyReset {
            cancelScheduledRefillAlert(bucketId: bucketId)
            return
        }
        if !isWeekly && !settings.notifyFiveHourReset {
            cancelScheduledRefillAlert(bucketId: bucketId)
            return
        }
        
        let timeInterval = targetDate.timeIntervalSinceNow
        // Only schedule if targetDate is in the future (at least 2 seconds)
        guard timeInterval > 2.0 else {
            cancelScheduledRefillAlert(bucketId: bucketId)
            return
        }
        
        let identifier = identifierForBucket(bucketId: bucketId)
        guard let center = center else { return }
        
        center.getNotificationSettings { [weak self] currentSettings in
            guard let self = self, let center = self.center else { return }
            guard currentSettings.authorizationStatus == .authorized || currentSettings.authorizationStatus == .provisional else { return }
            
            let content = UNMutableNotificationContent()
            content.title = LocalizedStringKey.notificationTitleRefilled.string(for: language)
            content.body = LocalizedStringKey.notificationBodyRefilled(model: modelName, window: window).string(for: language)
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            // Remove any existing pending request for this bucket before registering new schedule
            center.removePendingNotificationRequests(withIdentifiers: [identifier])
            center.add(request) { error in
                if let error = error {
                    print("[NotificationManager] Error scheduling notification for \(identifier): \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Cancels any pending refill alert for the specified bucket.
    public func cancelScheduledRefillAlert(bucketId: String) {
        guard let center = center else { return }
        let identifier = identifierForBucket(bucketId: bucketId)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /// Cancels all pending quota refill alerts (e.g. when user disables notifications in Settings).
    public func cancelAllScheduledRefillAlerts() {
        guard let center = center else { return }
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self = self, let center = self.center else { return }
            let refillIds = requests.map(\.identifier).filter { $0.hasPrefix("quota-refill-") }
            if !refillIds.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: refillIds)
            }
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
        guard let center = center else { return }
        
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
        guard let center = center else { return }
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
        guard let center = center else {
            completion?(false)
            return
        }
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
        guard let center = center else {
            completion?(false)
            return
        }
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
