import SwiftUI
import AppKit

struct FloatingTimerWindow: View {
    @ObservedObject var timerManager: TimerManager
    @State private var initialWindowOrigin: NSPoint?

    var body: some View {
        HStack(spacing: 14) {
            // Task info + timer
            VStack(alignment: .leading, spacing: 2) {
                if let task = timerManager.currentTask {
                    Text(task.title)
                        .font(DesignSystem.Typography.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                } else {
                    Text("No task")
                        .font(DesignSystem.Typography.footnote)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }

                HStack(spacing: 6) {
                    Text(timerManager.formattedRemainingTime)
                        .font(.system(size: 28, weight: .thin, design: .rounded))
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    // Status dot
                    if timerManager.state == .running {
                        Circle()
                            .fill(DesignSystem.Colors.success)
                            .frame(width: 6, height: 6)
                    } else if timerManager.state == .paused {
                        Circle()
                            .fill(DesignSystem.Colors.warning)
                            .frame(width: 6, height: 6)
                    }
                }
            }

            Spacer()

            // Controls
            HStack(spacing: 8) {
                // Pause/Play
                Button(action: {
                    if timerManager.state == .running {
                        timerManager.pauseTimer()
                    } else if timerManager.state == .paused {
                        timerManager.resumeTimer()
                    }
                }) {
                    Image(systemName: timerManager.state == .running ? "pause.fill" : "play.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.accent)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(DesignSystem.Colors.accentMuted)
                        )
                }
                .buttonStyle(.plain)

                // Stop
                Button(action: {
                    timerManager.stopTimer()
                    NotificationCenter.default.post(name: .timerDidStop, object: nil)
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(DesignSystem.Colors.surfaceHigh)
                                .overlay(Circle().stroke(DesignSystem.Colors.borderSubtle, lineWidth: 1))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(width: 340, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DesignSystem.Colors.floatingBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DesignSystem.Colors.floatingBorder, lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .shadow(color: DesignSystem.Shadows.strong, radius: 24, x: 0, y: 12)
        .gesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .global)
                .onChanged { value in
                    if let window = NSApp.windows.first(where: { $0.level == .floating }) {
                        if initialWindowOrigin == nil {
                            initialWindowOrigin = window.frame.origin
                        }
                        window.setFrameOrigin(NSPoint(
                            x: initialWindowOrigin!.x + value.translation.width,
                            y: initialWindowOrigin!.y - value.translation.height
                        ))
                    }
                }
                .onEnded { _ in
                    initialWindowOrigin = nil
                }
        )
        .contextMenu {
            Button("Close Timer") {
                FloatingTimerManager.shared.closeFloatingTimer()
            }
        }
    }
}

#Preview {
    let taskManager = TaskManager()
    let timerManager = TimerManager(taskManager: taskManager)
    return FloatingTimerWindow(timerManager: timerManager)
        .frame(width: 350, height: 100)
}