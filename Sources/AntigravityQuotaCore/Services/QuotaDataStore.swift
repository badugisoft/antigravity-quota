import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Shared storage coordinator responsible for persisting quota data between the main app and widgets.
public final class QuotaDataStore {
    public static let shared = QuotaDataStore()
    
    private var realUserHomeDirectory: URL {
        if let pw = getpwuid(getuid()), let dir = pw.pointee.pw_dir {
            return URL(fileURLWithPath: String(cString: dir))
        }
        return FileManager.default.homeDirectoryForCurrentUser
    }
    
    private var appSupportFileURL: URL {
        let dir = realUserHomeDirectory.appendingPathComponent("Library/Application Support/AntigravityQuota", isDirectory: true)
        return dir.appendingPathComponent("shared_quota.json")
    }
    
    private init() {
        ensureDirectories()
    }
    
    private func ensureDirectories() {
        let fm = FileManager.default
        let appSupportDir = appSupportFileURL.deletingLastPathComponent()
        try? fm.createDirectory(at: appSupportDir, withIntermediateDirectories: true)
    }
    
    /// Persists the latest quota snapshot and notifies WidgetKit to refresh timelines.
    public func save(snapshot: QuotaSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        
        // Save to App Support file (accessible by both main app and sandboxed widget)
        try? data.write(to: appSupportFileURL, options: [.atomic])
        
        // Trigger WidgetCenter reload
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
    
    /// Loads the latest cached snapshot. Falls back to offline snapshot if not found.
    public func loadLatestSnapshot() -> QuotaSnapshot {
        // Try reading from App Support file (primary shared store)
        if FileManager.default.fileExists(atPath: appSupportFileURL.path),
           let data = try? Data(contentsOf: appSupportFileURL),
           let snapshot = try? JSONDecoder().decode(QuotaSnapshot.self, from: data) {
            return snapshot
        }
        
        return .offline
    }
}
