import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var appBlockerManager: AppBlockerManager?
    private var mainWindow: NSWindow?

    func isInUnclosableMode() -> Bool {
        return appBlockerManager?.isUnclosableMode ?? false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.appearance = NSAppearance(named: .darkAqua)
        NSApp.activate(ignoringOtherApps: true)

        // Listen for unclosable mode changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUnclosableModeChange),
            name: .unclosableModeDidChange,
            object: nil
        )

        // SwiftUI creates the window asynchronously, so find it after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.setupMainWindow()
        }
    }

    private func setupMainWindow() {
        mainWindow = NSApp.windows.first { $0.level != .floating }
        mainWindow?.delegate = self
        updateWindowButtons()
    }

    @objc private func handleUnclosableModeChange() {
        if mainWindow == nil {
            mainWindow = NSApp.windows.first { $0.level != .floating }
            mainWindow?.delegate = self
        }
        updateWindowButtons()
    }

    private func updateWindowButtons() {
        guard let window = mainWindow else { return }
        let isUnclosable = appBlockerManager?.isUnclosableMode ?? false

        window.standardWindowButton(.closeButton)?.isHidden = isUnclosable
        window.standardWindowButton(.miniaturizeButton)?.isHidden = isUnclosable
        window.standardWindowButton(.zoomButton)?.isHidden = isUnclosable
    }

    // MARK: - NSWindowDelegate

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if appBlockerManager?.isUnclosableMode == true {
            return false
        }
        return true
    }

    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              window == mainWindow else { return }

        if appBlockerManager?.isUnclosableMode == false {
            FloatingTimerManager.shared.hideFloatingTimer()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        appBlockerManager?.stopMonitoring()
        StorageManager.shared.flushPendingSaves()
    }

    func setAppBlockerManager(_ manager: AppBlockerManager) {
        self.appBlockerManager = manager
    }

    // MARK: - Prevent Termination in Unclosable Mode

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if appBlockerManager?.isUnclosableMode == true {
            showAllWindows()
            return .terminateCancel
        }
        return .terminateNow
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        if appBlockerManager?.isUnclosableMode == true {
            return false
        }
        return true
    }

    // MARK: - Dock Icon Click

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showAllWindows()
        return false
    }

    // MARK: - Helpers

    private func showAllWindows() {
        for window in NSApp.windows {
            window.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
        NSApp.unhide(nil)
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        if let window = NSApp.keyWindow {
            window.makeKey()
            window.orderFrontRegardless()
        }
    }
}