import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var taskManager = TaskManager()
    @StateObject private var timerManager: TimerManager
    @EnvironmentObject var appBlockerManager: AppBlockerManager
    @State private var selectedTab: Tab = .categories

    enum Tab: Int, CaseIterable {
        case categories = 0
        case plans = 1
        case timer = 2
        case allTasks = 3
        case block = 4

        var title: String {
            switch self {
            case .categories: return "Tasks"
            case .plans: return "Plans"
            case .timer: return "Timer"
            case .allTasks: return "All"
            case .block: return "Block"
            }
        }

        var icon: String {
            switch self {
            case .categories: return "list.bullet"
            case .plans: return "calendar"
            case .timer: return "timer"
            case .allTasks: return "tray.full"
            case .block: return "hand.raised"
            }
        }

        var shortcut: KeyEquivalent {
            KeyEquivalent(Character("\(rawValue + 1)"))
        }
    }
    
    init() {
        let taskManager = TaskManager()
        _taskManager = StateObject(wrappedValue: taskManager)
        _timerManager = StateObject(wrappedValue: TimerManager(taskManager: taskManager))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Minimal Tab Bar
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    TabButton(
                        title: tab.title,
                        icon: tab.icon,
                        isSelected: selectedTab == tab
                    ) {
                        withAnimation(DesignSystem.Animation.quick) {
                            selectedTab = tab
                        }
                    }
                    .keyboardShortcut(tab.shortcut, modifiers: .command)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Colors.background)

            // Subtle divider
            Rectangle()
                .fill(DesignSystem.Colors.divider)
                .frame(height: 0.5)

            // Main Content
            Group {
                switch selectedTab {
                case .categories:
                    TasksView()
                case .plans:
                    PlansView()
                case .timer:
                    TimerView()
                case .allTasks:
                    AllTasksView()
                case .block:
                    BlockerView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(DesignSystem.Colors.background)
        .environmentObject(taskManager)
        .environmentObject(timerManager)
        .environmentObject(appBlockerManager)
        .onReceive(NotificationCenter.default.publisher(for: .timerDidStop)) { _ in
            withAnimation(DesignSystem.Animation.standard) {
                FloatingTimerManager.shared.hideFloatingTimer()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .timerDidStart)) { _ in
            withAnimation(DesignSystem.Animation.standard) {
                selectedTab = .timer
                FloatingTimerManager.shared.showFloatingTimer()
            }
        }
        .onAppear {
            FloatingTimerManager.shared.setTimerManager(timerManager)
        }
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(DesignSystem.Typography.caption1)

                Text(title)
                    .font(DesignSystem.Typography.subheadline)
                    .fontWeight(.regular)
            }
            .foregroundColor(isSelected ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textTertiary)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .frame(minWidth: 80, minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(isSelected ? DesignSystem.Colors.surfaceLight : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .stroke(isSelected ? DesignSystem.Colors.accentSecondary : Color.clear, lineWidth: 0.5)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(title) tab")
        .accessibilityHint("Switch to \(title) view")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TaskManager())
            .environmentObject(TimerManager(taskManager: TaskManager()))
            .environmentObject(AppBlockerManager())
    }
}
