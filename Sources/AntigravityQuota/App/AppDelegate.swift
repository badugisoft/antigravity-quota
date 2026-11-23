import Cocoa
import SwiftUI
import Combine
import UserNotifications
import AntigravityQuotaCore

/// NSApplicationDelegate configuring the NSStatusItem, popover lifecycle, and event monitoring.
@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var hostingController: NSHostingController<MenuBarPopoverView>!
    private var viewModel: QuotaViewModel!
    private var cancellables = Set<AnyCancellable>()
    private var globalEventMonitor: Any?
    private var localEventMonitor: Any?
    private var isPopoverOpening = false
    private var hasPendingClose = false
    private var pendingCloseSender: AnyObject?
    
    private let popoverWidth: CGFloat = 340
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        viewModel = QuotaViewModel()
        
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
        NotificationManager.shared.requestAuthorization()
        
        setupPopover()
        setupStatusItem()
        bindViewModel()
    }
    
    private func setupPopover() {
        hostingController = NSHostingController(
            rootView: MenuBarPopoverView(viewModel: viewModel)
        )
        hostingController.sizingOptions = [.intrinsicContentSize]
        
        popover = NSPopover()
        popover.behavior = .applicationDefined
        popover.delegate = self
        popover.contentViewController = hostingController
        updatePopoverSize()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = MenuBarIconRenderer.shared.renderIcon(remainingFraction: 1.0, isOnline: false)
            button.imagePosition = .imageLeft
            button.title = ""
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
            button.target = self
            button.action = #selector(togglePopover(_:))
        }
    }
    
    private func bindViewModel() {
        Publishers.CombineLatest3(
            viewModel.$lowestRemainingFraction,
            viewModel.$isServerOnline,
            viewModel.$menuBarSummary
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] fraction, isOnline, summary in
            guard let button = self?.statusItem.button else { return }
            
            // Dynamic gauge icon
            button.image = MenuBarIconRenderer.shared.renderIcon(
                remainingFraction: fraction,
                isOnline: isOnline
            )
            
            // Text visibility
            if summary.isEmpty {
                button.imagePosition = .imageOnly
                button.title = ""
            } else {
                button.imagePosition = .imageLeft
                button.title = " " + summary
            }
        }
        .store(in: &cancellables)
            
        Publishers.Merge4(
            viewModel.$isCompactMode.map { _ in () }.eraseToAnyPublisher(),
            viewModel.$groups.map { _ in () }.eraseToAnyPublisher(),
            viewModel.$isServerOnline.map { _ in () }.eraseToAnyPublisher(),
            viewModel.localization.$currentLanguage.map { _ in () }.eraseToAnyPublisher()
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] _ in
            self?.updatePopoverSize()
        }
        .store(in: &cancellables)
    }
    
    @objc public func openSettings(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        }
        SettingsWindowController.shared.showSettings()
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
        
        updatePopoverSize()
        
        // Refresh quota immediately upon opening the popover
        Task {
            await viewModel.refresh()
        }
        
        isPopoverOpening = true
        hasPendingClose = false
        pendingCloseSender = nil
        
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        clampPopoverWindowToScreen()
        configurePopoverWindowVibrancy()
        
        // Monitor clicks outside the popover to dismiss
        removeEventMonitors()
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            Task { @MainActor in
                self?.closePopover(event)
            }
        }
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self else { return event }
            let popoverWindow = self.popover.contentViewController?.view.window
            let statusWindow = self.statusItem.button?.window
            if event.window !== popoverWindow && event.window !== statusWindow {
                self.closePopover(event)
            }
            return event
        }
    }
    
    /// Recomputes popover content size from SwiftUI fitting size and keeps the window below the menu bar.
    private func updatePopoverSize() {
        guard let hostingView = hostingController?.view else { return }
        let previousMaxY = popover.isShown ? hostingView.window?.frame.maxY : nil
        
        hostingView.invalidateIntrinsicContentSize()
        hostingView.layoutSubtreeIfNeeded()
        
        let targetScreen = statusItem?.button?.window?.screen ?? NSScreen.main
        let maxAllowedHeight = max(200, (targetScreen?.visibleFrame.height ?? 800) - 24)
        let fittingHeight = hostingView.fittingSize.height
        let fallbackHeight: CGFloat = viewModel.isCompactMode ? 275 : 470
        let resolvedHeight = min(maxAllowedHeight, max(160, fittingHeight > 1 ? fittingHeight : fallbackHeight))
        let targetSize = NSSize(width: popoverWidth, height: resolvedHeight)
        
        if popover.contentSize != targetSize {
            popover.contentSize = targetSize
        }
        
        if popover.isShown {
            clampPopoverWindowToScreen(preferredMaxY: previousMaxY)
            configurePopoverWindowVibrancy()
        }
    }
    
    /// Prevents the popover window from expanding upward past the visible screen top when resizing.
    private func clampPopoverWindowToScreen(preferredMaxY: CGFloat? = nil) {
        guard popover.isShown, let window = popover.contentViewController?.view.window else { return }
        let targetScreen = statusItem?.button?.window?.screen ?? window.screen ?? NSScreen.main
        guard let visibleFrame = targetScreen?.visibleFrame else { return }
        
        var frame = window.frame
        let topBoundary = min(preferredMaxY ?? visibleFrame.maxY, visibleFrame.maxY)
        
        if frame.maxY > topBoundary {
            frame.origin.y -= (frame.maxY - topBoundary)
        }
        if frame.minY < visibleFrame.minY {
            frame.origin.y = visibleFrame.minY
        }
        if frame != window.frame {
            window.setFrame(frame, display: true)
        }
    }
    
    /// Ensures visual effect views remain active to keep popover transparency consistent.
    private func configurePopoverWindowVibrancy() {
        guard popover.isShown, let window = popover.contentViewController?.view.window else { return }
        
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
        if isPopoverOpening {
            hasPendingClose = true
            pendingCloseSender = sender
            return
        }
        popover.performClose(sender)
        removeEventMonitors()
    }
    
    private func removeEventMonitors() {
        if let monitor = globalEventMonitor {
            NSEvent.removeMonitor(monitor)
            globalEventMonitor = nil
        }
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }
    }
    
    public func popoverWillShow(_ notification: Notification) {
        isPopoverOpening = true
    }
    
    public func popoverDidShow(_ notification: Notification) {
        isPopoverOpening = false
        if hasPendingClose {
            let sender = pendingCloseSender
            hasPendingClose = false
            pendingCloseSender = nil
            DispatchQueue.main.async { [weak self] in
                self?.closePopover(sender)
            }
        }
    }
    
    public func popoverDidClose(_ notification: Notification) {
        isPopoverOpening = false
        hasPendingClose = false
        pendingCloseSender = nil
        removeEventMonitors()
    }
}
