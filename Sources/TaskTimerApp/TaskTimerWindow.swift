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
        cover.layer?.backgroundColor = NSColor.clear.cgColor
        return cover
    }

    private func updateButtonCovers() {
        guard isUnclosableMode else {
            closeButtonCover?.removeFromSuperview()
            miniaturizeButtonCover?.removeFromSuperview()
            zoomButtonCover?.removeFromSuperview()
            closeButtonCover = nil
            miniaturizeButtonCover = nil
            zoomButtonCover = nil
            return
        }

        if closeButtonCover == nil {
            setupButtonCovers()
        }

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
        if isUnclosableMode { return }
        super.close()
    }

    // MARK: - Prevent Hiding
    override func orderOut(_ sender: Any?) {
        if isUnclosableMode { return }
        super.orderOut(sender)
    }

    override func orderBack(_ sender: Any?) {
        if isUnclosableMode { return }
        super.orderBack(sender)
    }

    // MARK: - Prevent Minimizing
    override func miniaturize(_ sender: Any?) {
        if isUnclosableMode { return }
        super.miniaturize(sender)
    }

    override var isMiniaturized: Bool {
        if isUnclosableMode { return false }
        return super.isMiniaturized
    }

    // MARK: - Prevent Moving
    override func setFrameOrigin(_ point: NSPoint) {
        if isUnclosableMode { return }
        super.setFrameOrigin(point)
    }

    // MARK: - Prevent Resizing
    override func setFrame(_ frameRect: NSRect, display: Bool, animate: Bool) {
        if isUnclosableMode { return }
        super.setFrame(frameRect, display: display, animate: animate)
    }

    override var isResizable: Bool {
        if isUnclosableMode { return false }
        return super.isResizable
    }

    // MARK: - Prevent Zooming
    override func zoom(_ sender: Any?) {
        if isUnclosableMode { return }
        super.zoom(sender)
    }

    // MARK: - Prevent Hiding on Deactivate
    override var hidesOnDeactivate: Bool {
        get {
            if isUnclosableMode { return false }
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

        updateButtonCovers()

        if !isVisible {
            orderFrontRegardless()
        }

        if isMiniaturized {
            deminiaturize(nil)
        }

        orderFrontRegardless()
        makeFirstResponder(contentView)
    }

    // MARK: - Override Key Events
    override func keyDown(with event: NSEvent) {
        if isUnclosableMode {
            let modifierFlags = event.modifierFlags
            let commandKey = modifierFlags.contains(.command)

            if commandKey {
                let keyCode = event.keyCode
                // Cmd+W = close (keyCode 13), Cmd+M = minimize (keyCode 46)
                if keyCode == 13 || keyCode == 46 {
                    return
                }
            }
        }
        super.keyDown(with: event)
    }
}