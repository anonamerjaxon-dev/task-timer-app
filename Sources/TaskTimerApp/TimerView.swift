import SwiftUI

struct TimerView: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var taskManager: TaskManager

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Spacer()

            // Timer Circle
            timerCircleView

            // Controls
            if timerManager.state != .idle {
                controlsView
            }

            // Session Info
            if timerManager.state != .idle {
                sessionInfoView
            }

            Spacer()
        }
        .background(DesignSystem.Colors.background)
    }

    // MARK: - Header

    var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Timer")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text(timerManager.state == .idle ? "Ready to focus" : "Session in progress")
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }

    // MARK: - Timer Circle

    var timerCircleView: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(DesignSystem.Colors.surfaceHigh, lineWidth: 10)
                .frame(width: 260, height: 260)

            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(timerManager.sessionProgress))
                .stroke(
                    timerManager.state.isBreak ? DesignSystem.Colors.timerBreak : DesignSystem.Colors.timerFocus,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .frame(width: 260, height: 260)
                .rotationEffect(.degrees(-90))
                .animation(DesignSystem.Animation.quick, value: timerManager.sessionProgress)

            // Glow effect when active
            if timerManager.state == .running {
                Circle()
                    .trim(from: 0, to: CGFloat(timerManager.sessionProgress))
                    .stroke(
                        DesignSystem.Colors.timerFocus.opacity(0.3),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 260, height: 260)
                    .rotationEffect(.degrees(-90))
                    .blur(radius: 8)
                    .animation(DesignSystem.Animation.quick, value: timerManager.sessionProgress)
            }

            // Center content
            VStack(spacing: 8) {
                Text(timerManager.formattedRemainingTime)
                    .font(DesignSystem.Typography.monoLarge)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                if let task = timerManager.currentTask {
                    Text(task.title)
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                } else {
                    HStack(spacing: 6) {
                        ClockIcon(size: 14, color: DesignSystem.Colors.textTertiary)
                        Text("No task selected")
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                }
            }
        }
        .padding(.vertical, 20)
    }

    // MARK: - Controls

    var controlsView: some View {
        HStack(spacing: 16) {
            // Pause / Resume
            Button(action: {
                if timerManager.state == .running {
                    timerManager.pauseTimer()
                } else if timerManager.state == .paused {
                    timerManager.resumeTimer()
                }
            }) {
                Image(systemName: timerManager.state == .running ? "pause.fill" : "play.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(DesignSystem.Colors.accent)
                    )
            }
            .buttonStyle(.plain)

            // Stop
            Button(action: {
                timerManager.stopTimer()
            }) {
                Image(systemName: "stop.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(DesignSystem.Colors.surface)
                            .overlay(Circle().stroke(DesignSystem.Colors.border, lineWidth: 1))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 28)
    }

    // MARK: - Session Info

    var sessionInfoView: some View {
        HStack(spacing: 32) {
            // Elapsed
            VStack(spacing: 4) {
                Text("Elapsed")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                Text(timerManager.formattedElapsedTime)
                    .font(DesignSystem.Typography.monoMedium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }

            // Status
            VStack(spacing: 4) {
                Text("Status")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                Text(stateText)
                    .font(DesignSystem.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(stateColor)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignSystem.Colors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DesignSystem.Colors.borderSubtle, lineWidth: 1)
        )
        .padding(.top, 24)
    }

    // MARK: - Helpers

    var stateText: String {
        switch timerManager.state {
        case .idle: return "Ready"
        case .running: return "Focus"
        case .paused: return "Paused"
        case .breakTime: return "Break"
        }
    }

    var stateColor: Color {
        switch timerManager.state {
        case .idle: return DesignSystem.Colors.textTertiary
        case .running: return DesignSystem.Colors.timerFocus
        case .paused: return DesignSystem.Colors.timerPaused
        case .breakTime: return DesignSystem.Colors.timerBreak
        }
    }
}

#Preview {
    TimerView()
        .environmentObject(TaskManager())
        .environmentObject(TimerManager(taskManager: TaskManager()))
}