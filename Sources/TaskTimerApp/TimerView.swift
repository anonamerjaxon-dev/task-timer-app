import SwiftUI

struct TimerView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var taskManager: TaskManager

    var body: some View {
        VStack(spacing: 0) {
            // Timer Display - Minimalistic
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Timer Circle - Cleaner design
                ZStack {
                    Circle()
                        .stroke(DesignSystem.Colors.surfaceLight, lineWidth: 8) // Thicker and lighter
                        .frame(width: 280, height: 280) // Much larger

                    Circle()
                        .trim(from: 0, to: CGFloat(timerManager.sessionProgress))
                        .stroke(
                            timerManager.state.isBreak ? DesignSystem.Colors.timerBreak : DesignSystem.Colors.timerActive,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round) // Much thicker
                        )
                        .frame(width: 280, height: 280) // Much larger
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Text(timerManager.formattedRemainingTime)
                            .font(DesignSystem.Typography.monospacedLarge)
                            .foregroundColor(DesignSystem.Colors.textPrimary)

                        if let task = timerManager.currentTask {
                            Text(task.title)
                                .font(DesignSystem.Typography.subheadline) // Larger
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .lineLimit(2) // Allow more lines
                                .multilineTextAlignment(.center)
                        } else {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                ClockIcon(size: 16, color: DesignSystem.Colors.textTertiary) // Larger icon
                                Text("No task selected")
                                    .font(DesignSystem.Typography.subheadline) // Larger
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                            }
                        }
                    }
                }

                // Timer Controls - Minimalistic
                HStack(spacing: DesignSystem.Spacing.lg) {
                    if timerManager.state != .idle {
                        // Pause/Resume
                        Button(action: {
                            if timerManager.state == .running {
                                timerManager.pauseTimer()
                            } else if timerManager.state == .paused {
                                timerManager.resumeTimer()
                            }
                        }) {
                            Image(systemName: timerManager.state == .running ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 36)) // Larger
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Stop
                        Button(action: {
                            timerManager.stopTimer()
                        }) {
                            Image(systemName: "stop.circle.fill")
                                .font(.system(size: 36)) // Larger
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                // Session Info - Minimalistic
                if timerManager.state != .idle {
                    HStack(spacing: DesignSystem.Spacing.xl) {
                        VStack(spacing: DesignSystem.Spacing.xs) {
                            Text("Session")
                                .font(DesignSystem.Typography.footnote) // Larger
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            Text(timerManager.formattedElapsedTime)
                                .font(DesignSystem.Typography.monospacedMedium)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                        }

                        VStack(spacing: DesignSystem.Spacing.xs) {
                            Text("Status")
                                .font(DesignSystem.Typography.footnote) // Larger
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            Text(stateText)
                                .font(DesignSystem.Typography.callout) // Larger
                                .fontWeight(.semibold)
                                .foregroundColor(stateColor)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.surface)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                }
            }
            .padding(.top, DesignSystem.Spacing.xxl)

            Spacer()
        }
    }
    
    var stateText: String {
        switch timerManager.state {
        case .idle:
            return "Ready"
        case .running:
            return "Focus"
        case .paused:
            return "Paused"
        case .breakTime:
            return "Break"
        }
    }

    var stateColor: Color {
        switch timerManager.state {
        case .idle:
            return DesignSystem.Colors.textTertiary
        case .running:
            return DesignSystem.Colors.textPrimary
        case .paused:
            return DesignSystem.Colors.warning
        case .breakTime:
            return DesignSystem.Colors.success
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
            .environmentObject(TaskManager())
            .environmentObject(TimerManager(taskManager: TaskManager()))
    }
}