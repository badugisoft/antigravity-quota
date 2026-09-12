import Cocoa
import SwiftUI
import Combine

/// NSApplicationDelegate configuring the NSStatusItem, popover lifecycle, and event monitoring.
@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var viewModel: QuotaViewModel!
    private var cancellables = Set<AnyCancellable>()
    private var eventMonitor: Any?
    
    private var standardSize: NSSize {
        NSSize(width: 340, height: 470)
    }
    
    private var compactSize: NSSize {
        NSSize(width: 340, height: 275)
    }
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        viewModel = QuotaViewModel()
        
        setupPopover()
        setupStatusItem()
        bindViewModel()
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = viewModel.isCompactMode ? compactSize : standardSize
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: MenuBarPopoverView(viewModel: viewModel)
        )
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.title = "✦ AGY ..."
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
            button.target = self
            button.action = #selector(togglePopover(_:))
        }
    }
    
    private func bindViewModel() {
        viewModel.$menuBarSummary
            .receive(on: RunLoop.main)
            .sink { [weak self] summary in
                self?.statusItem.button?.title = summary
            }
            .store(in: &cancellables)
            
        viewModel.$isCompactMode
            .receive(on: RunLoop.main)
            .sink { [weak self] isCompact in
                guard let self = self else { return }
                let targetSize = isCompact ? self.compactSize : self.standardSize
                self.popover.contentSize = targetSize
                self.configurePopoverWindowVibrancy()
            }
            .store(in: &cancellables)
    }
    
    @objc private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    private func showPopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }
        
        // Ensure popover content size matches current mode
        popover.contentSize = viewModel.isCompactMode ? compactSize : standardSize
        
        // Refresh quota immediately upon opening the popover
        Task {
            await viewModel.refresh()
        }
        
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        configurePopoverWindowVibrancy()
        
        // Monitor global clicks outside the popover to dismiss
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            Task { @MainActor in
                self?.closePopover(event)
            }
        }
    }
    
    /// Ensures popover window is key and its visual effect views are active to keep transparency consistent.
    private func configurePopoverWindowVibrancy() {
        guard let window = popover.contentViewController?.view.window else { return }
        window.makeKeyAndOrderFront(nil)
        
        func activateVisualEffectViews(in view: NSView) {
            if let vev = view as? NSVisualEffectView {
                vev.state = .active
            }
            for subview in view.subviews {
                activateVisualEffectViews(in: subview)
            }
        }
        
        if let frameView = window.contentView?.superview {
            activateVisualEffectViews(in: frameView)
        }
    }
    
    private func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
