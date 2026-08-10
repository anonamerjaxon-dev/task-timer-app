import SwiftUI
import AppKit

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

        if floatingWindow == nil {
            let content = FloatingTimerWindow(timerManager: timerManager)
            let hostingView = NSHostingView(rootView: content)
            hostingView.frame = NSRect(x: 0, y: 0, width: 320, height: 70)
            hostingView.wantsLayer = true
            hostingView.layer?.backgroundColor = NSColor.clear.cgColor

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
            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = false
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.collectionBehavior = [.fullScreenAuxiliary, .canJoinAllSpaces, .stationary]
            window.hidesOnDeactivate = false
            window.acceptsMouseMovedEvents = true
            window.appearance = NSAppearance(named: .darkAqua)

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