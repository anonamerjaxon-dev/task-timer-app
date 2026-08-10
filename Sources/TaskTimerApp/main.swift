import SwiftUI
import AppKit

// Custom NSWindow to ensure proper focus handling
class TaskTimerWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func makeKey() {
        super.makeKey()
        orderFrontRegardless()
    }

    override var acceptsFirstResponder: Bool { true }

    private var isUnclosableMode: Bool {
        if let appDelegate = NSApp.delegate as? AppDelegate {
            return appDelegate.isInUnclosableMode()
        }
        return false
    }

    // MARK: - Traffic Light Button Covers
    private var closeButtonCover: NSView?
    private var miniaturizeButtonCover: NSView?
    private var zoomButtonCover: NSView?

    private func setupButtonCovers() {
        // Remove existing covers
        closeButtonCover?.removeFromSuperview()
        miniaturizeButtonCover?.removeFromSuperview()
        zoomButtonCover?.removeFromSuperview()
        closeButtonCover = nil
        miniaturizeButtonCover = nil
        zoomButtonCover = nil

        guard isUnclosableMode else { return }

        // Get the traffic light buttons
        guard let closeButton = standardWindowButton(.closeButton),
              let miniaturizeButton = standardWindowButton(.miniaturizeButton),
              let zoomButton = standardWindowButton(.zoomButton) else {
            return
        }

        // Create covers that match button frames and intercept clicks
        closeButtonCover = createCoverView(for: closeButton)
        miniaturizeButtonCover = createCoverView(for: miniaturizeButton)
        zoomButtonCover = createCoverView(for: zoomButton)

        // Add covers above the buttons
        if let contentView = self.contentView {
            if let cover = closeButtonCover {
                contentView.addSubview(cover, positioned: .above, relativeTo: closeButton)
            }
            if let cover = miniaturizeButtonCover {
                contentView.addSubview(cover, positioned: .above, relativeTo: miniaturizeButton)
            }
            if let cover = zoomButtonCover {
                contentView.addSubview(cover, positioned: .above, relativeTo: zoomButton)
            }
        }
    }

    private func createCoverView(for button: NSButton) -> NSView {
        let cover = NSView(frame: button.frame)
        cover.wantsLayer = true
        // Make it transparent but receive mouse events
        cover.layer?.backgroundColor = NSColor.clear.cgColor
        return cover
    }

    private func updateButtonCovers() {
        guard isUnclosableMode else {
            // Remove covers if not in unclosable mode
            closeButtonCover?.removeFromSuperview()
            miniaturizeButtonCover?.removeFromSuperview()
            zoomButtonCover?.removeFromSuperview()
            closeButtonCover = nil
            miniaturizeButtonCover = nil
            zoomButtonCover = nil
            return
        }

        // Setup covers if needed
        if closeButtonCover == nil {
            setupButtonCovers()
        }

        // Update cover frames to match button frames (buttons may move)
        if let closeButton = standardWindowButton(.closeButton),
           let cover = closeButtonCover {
            cover.frame = closeButton.frame
        }
        if let miniaturizeButton = standardWindowButton(.miniaturizeButton),
           let cover = miniaturizeButtonCover {
            cover.frame = miniaturizeButton.frame
        }
        if let zoomButton = standardWindowButton(.zoomButton),
           let cover = zoomButtonCover {
            cover.frame = zoomButton.frame
        }
    }

    // MARK: - Prevent Closing
    override func close() {
        if isUnclosableMode {
            return // Don't close
        }
        super.close()
    }

    // MARK: - Prevent Hiding
    override func orderOut(_ sender: Any?) {
        if isUnclosableMode {
            return // Don't hide
        }
        super.orderOut(sender)
    }

    override func orderBack(_ sender: Any?) {
        if isUnclosableMode {
            return // Don't send to back
        }
        super.orderBack(sender)
    }

    // MARK: - Prevent Minimizing
    override func miniaturize(_ sender: Any?) {
        if isUnclosableMode {
            return // Don't minimize
        }
        super.miniaturize(sender)
    }

    override func deminiaturize(_ sender: Any?) {
        super.deminiaturize(sender)
    }

    override var isMiniaturized: Bool {
        if isUnclosableMode {
            return false // Never minimized
        }
        return super.isMiniaturized
    }

    // MARK: - Prevent Moving
    override func setFrameOrigin(_ point: NSPoint) {
        if isUnclosableMode {
            return // Don't move
        }
        super.setFrameOrigin(point)
    }

    // MARK: - Prevent Resizing
    override func setFrame(_ frameRect: NSRect, display: Bool, animate: Bool) {
        if isUnclosableMode {
            return // Don't resize
        }
        super.setFrame(frameRect, display: display, animate: animate)
    }

    override var isResizable: Bool {
        if isUnclosableMode {
            return false // Can't resize
        }
        return super.isResizable
    }

    // MARK: - Prevent Zooming
    override func zoom(_ sender: Any?) {
        if isUnclosableMode {
            return // Don't zoom
        }
        super.zoom(sender)
    }

    // MARK: - Prevent Hiding on Deactivate
    override var hidesOnDeactivate: Bool {
        get {
            if isUnclosableMode {
                return false // Never hide when app loses focus
            }
            return super.hidesOnDeactivate
        }
        set {
            super.hidesOnDeactivate = newValue
        }
    }

    // MARK: - Continuous Enforcement
    override func update() {
        super.update()

        guard isUnclosableMode else { return }

        // Update button covers
        updateButtonCovers()

        // Force window to stay visible
        if !isVisible {
            orderFrontRegardless()
        }

        // Force window to not be miniaturized
        if isMiniaturized {
            deminiaturize(nil)
        }

        // Force window to front
        orderFrontRegardless()
        makeFirstResponder(contentView)
    }

    // MARK: - Override Key Events
    override func keyDown(with event: NSEvent) {
        // In unclosable mode, intercept Cmd+W (close) and Cmd+M (minimize)
        if isUnclosableMode {
            let modifierFlags = event.modifierFlags
            let commandKey = modifierFlags.contains(.command)

            if commandKey {
                let keyCode = event.keyCode
                // Cmd+W = close (keyCode 13)
                // Cmd+M = minimize (keyCode 46)
                if keyCode == 13 || keyCode == 46 {
                    return // Block these shortcuts
                }
            }
        }
        super.keyDown(with: event)
    }
}

struct TaskTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appBlockerManager = AppBlockerManager()

    init() {
        // App initialization
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appBlockerManager)
                .frame(minWidth: 900, minHeight: 600)
                .preferredColorScheme(.dark) // Force dark mode
                .onAppear {
                    // Force window to become key on appear
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        ensureAppActivation()
                        // Pass AppBlockerManager to AppDelegate
                        appDelegate.setAppBlockerManager(appBlockerManager)
                        // Configure window to appear on all desktops
                        configureWindowForAllDesktops()
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }

    private func ensureAppActivation() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.keyWindow {
            window.makeKey()
            window.orderFrontRegardless()
            window.makeFirstResponder(window.contentView)
        }
    }

    private func configureWindowForAllDesktops() {
        // Configure all windows to appear on all desktops (spaces)
        for window in NSApp.windows {
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        }
    }
}

// Floating Timer Manager
final class FloatingTimerManager: ObservableObject {
    static let shared = FloatingTimerManager()

    private var floatingWindow: NSWindow?
    private var timerManager: TimerManager?

    private init() {}

    func setTimerManager(_ manager: TimerManager) {
        self.timerManager = manager
    }

    func showFloatingTimer() {
        guard let timerManager = timerManager else { return }

        // Create a new window if needed
        if floatingWindow == nil {
            let content = FloatingTimerWindow(timerManager: timerManager)
            let hostingView = NSHostingView(rootView: content)
            hostingView.frame = NSRect(x: 0, y: 0, width: 320, height: 70)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 320, height: 70),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )

            window.contentView = hostingView
            window.isReleasedWhenClosed = false
            window.level = .floating
            window.isMovableByWindowBackground = true
            window.backgroundColor = NSColor(white: 0.05, alpha: 0.95) // Dark background
            window.isOpaque = false
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.collectionBehavior = [.fullScreenAuxiliary, .canJoinAllSpaces, .stationary]
            window.hidesOnDeactivate = false
            window.acceptsMouseMovedEvents = true
            window.appearance = NSAppearance(named: .darkAqua) // Force dark appearance

            // Center the window on screen
            if let screen = NSScreen.main {
                let screenFrame = screen.visibleFrame
                window.setFrameOrigin(
                    NSPoint(
                        x: screenFrame.midX - window.frame.width / 2,
                        y: screenFrame.maxY - window.frame.height - 100
                    )
                )
            }

            self.floatingWindow = window
        }

        floatingWindow?.orderFrontRegardless()
    }

    func hideFloatingTimer() {
        floatingWindow?.orderOut(nil)
    }

    func closeFloatingTimer() {
        floatingWindow?.close()
        floatingWindow = nil
    }

    func updateFloatingTimer() {
        guard let timerManager = timerManager, let floatingWindow = floatingWindow else { return }
        let content = FloatingTimerWindow(timerManager: timerManager)
        if let hostingView = floatingWindow.contentView as? NSHostingView<FloatingTimerWindow> {
            hostingView.rootView = content
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var appBlockerManager: AppBlockerManager?

    func isInUnclosableMode() -> Bool {
        return appBlockerManager?.isUnclosableMode ?? false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set up app appearance
        NSApp.appearance = NSAppearance(named: .darkAqua)

        // Make app active
        NSApp.activate(ignoringOtherApps: true)

        // Configure windows to appear on all desktops
        configureWindowsForAllDesktops()
    }

    private func configureWindowsForAllDesktops() {
        // Configure all windows to appear on all desktops (spaces)
        for window in NSApp.windows {
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Clean up resources before termination
        appBlockerManager?.stopMonitoring()
        StorageManager.shared.flushPendingSaves()
    }

    func setAppBlockerManager(_ manager: AppBlockerManager) {
        self.appBlockerManager = manager
    }

    // MARK: - Prevent Termination in Unclosable Mode

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if let blockerManager = appBlockerManager, blockerManager.isUnclosableMode {
            // In unclosable mode, prevent termination at all costs
            showAllWindows()
            NSApp.activate(ignoringOtherApps: true)
            return .terminateCancel
        }
        return .terminateNow
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        if let blockerManager = appBlockerManager, blockerManager.isUnclosableMode {
            // In unclosable mode, NEVER terminate
            return false
        }
        return true
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if let blockerManager = appBlockerManager, blockerManager.isUnclosableMode {
            // In unclosable mode, always show windows when dock icon is clicked
            showAllWindows()
            return false
        } else if !flag {
            // If no visible windows, show the main window
            return true
        } else {
            // If there are visible windows, bring them to front
            for window in NSApp.windows {
                window.makeKeyAndOrderFront(nil)
            }
            return false
        }
    }

    // MARK: - Prevent Hiding
    func applicationDidResignActive(_ notification: Notification) {
        if let blockerManager = appBlockerManager, blockerManager.isUnclosableMode {
            // Force app to become active again
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    func applicationDidHide(_ notification: Notification) {
        if let blockerManager = appBlockerManager, blockerManager.isUnclosableMode {
            // Force app to unhide
            DispatchQueue.main.async {
                NSApp.unhide(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    private func showAllWindows() {
        // Show all windows
        for window in NSApp.windows {
            window.makeKeyAndOrderFront(nil)
        }
        // Activate the app
        NSApp.activate(ignoringOtherApps: true)
        NSApp.unhide(nil)
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        // Ensure window is key when app becomes active
        if let window = NSApp.keyWindow {
            window.makeKey()
            window.orderFrontRegardless()
        }
    }
}

TaskTimerApp.main()
