import SwiftUI
import AppKit

struct TaskTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appBlockerManager = AppBlockerManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appBlockerManager)
                .frame(minWidth: DesignSystem.Layout.windowMinWidth, minHeight: DesignSystem.Layout.windowMinHeight)
                .preferredColorScheme(.dark)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        ensureAppActivation()
                        appDelegate.setAppBlockerManager(appBlockerManager)
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
        for window in NSApp.windows {
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        }
    }
}

TaskTimerApp.main()