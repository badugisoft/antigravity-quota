import Cocoa
import SwiftUI
import AntigravityQuotaCore

/// Manages the lifecycle of the Preferences / Settings window.
@MainActor
public final class SettingsWindowController: NSWindowController {
    public static let shared = SettingsWindowController()
    
    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 380),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = LocalizedStringKey.settings.string(for: LocalizationManager.shared.currentLanguage)
        window.isReleasedWhenClosed = false
        window.contentViewController = NSHostingController(rootView: SettingsView())
        
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Displays the settings window and brings it to front.
    public func showSettings() {
        guard let window = window else { return }
        window.title = LocalizedStringKey.settings.string(for: LocalizationManager.shared.currentLanguage)
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
