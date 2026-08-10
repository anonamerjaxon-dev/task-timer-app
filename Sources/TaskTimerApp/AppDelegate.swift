import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var appBlockerManager: AppBlockerManager?

    func isInUnclosableMode() -> Bool {
        return appBlockerManager?.isUnclosableMode ?? false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.appearance = NSAppearance(named: .darkAqua)
        NSApp.activate(ignoringOtherApps: true)
        configureWindowsForAllDesktops()
    }

    private func configureWindowsForAllDesktops() {
        for window in NSApp.windows {
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
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
        if let blockerManager = appBlockerManager, blockerManager.isUnclosableMode {
            showAllWindows()
            NSApp.activate(ignoringOtherApps: true)
            return .terminateCancel
        }
        return .terminateNow
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        if let blockerManager = appBlockerManager, blockerManager.isUnclosableMode {
            return false
        }
        return true
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if let blockerManager = appBlockerManager, blockerManager.isUnclosableMode {
            showAllWindows()
            return false
        } else if !flag {
            return true
        } else {
            for window in NSApp.windows {
                window.makeKeyAndOrderFront(nil)
            }
            return false
        }
    }

    // MARK: - Prevent Hiding
    func applicationDidResignActive(_ notification: Notification) {
        if let blockerManager = appBlockerManager, blockerManager.isUnclosableMode {
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    func applicationDidHide(_ notification: Notification) {
        if let blockerManager = appBlockerManager, blockerManager.isUnclosableMode {
            DispatchQueue.main.async {
                NSApp.unhide(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

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