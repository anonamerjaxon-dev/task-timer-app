import SwiftUI
import AppKit

struct FloatingTimerWindow: View {
    @ObservedObject var timerManager: TimerManager
    @State private var isDragging = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Task info
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

                    HStack(spacing: 4) {
                        Text(timerManager.formattedRemainingTime)
                            .font(.system(size: 28, weight: .ultraLight, design: .monospaced))
                            .foregroundColor(DesignSystem.Colors.textPrimary)

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
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Button(action: {
                        if timerManager.state == .running {
                            timerManager.pauseTimer()
                        } else if timerManager.state == .paused {
                            timerManager.resumeTimer()
                        }
                    }) {
                        Image(systemName: timerManager.state == .running ? "pause.fill" : "play.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(DesignSystem.Colors.interactive)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        timerManager.stopTimer()
                        NotificationCenter.default.post(name: .timerDidStop, object: nil)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(DesignSystem.Colors.interactive)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .frame(width: 340, height: 80)
        }
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(Color.black.opacity(0.95))
                .shadow(color: DesignSystem.Shadows.medium, radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .gesture(
            DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                    }
                    if let window = NSApp.windows.first(where: { $0.level == .floating }) {
                        let newOrigin = NSPoint(
                            x: window.frame.origin.x + value.translation.width,
                            y: window.frame.origin.y - value.translation.height
                        )
                        window.setFrameOrigin(newOrigin)
                    }
                }
                .onEnded { _ in
                    isDragging = false
                }
        )
        .contextMenu {
            Button("Close Timer") {
                FloatingTimerManager.shared.closeFloatingTimer()
            }
        }
    }
}

struct FloatingTimerWindow_Previews: PreviewProvider {
    static var previews: some View {
        let taskManager = TaskManager()
        let timerManager = TimerManager(taskManager: taskManager)
        return FloatingTimerWindow(timerManager: timerManager)
            .frame(width: 350, height: 100)
    }
}