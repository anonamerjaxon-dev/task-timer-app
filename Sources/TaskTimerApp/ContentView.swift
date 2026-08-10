import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var taskManager = TaskManager()
    @StateObject private var timerManager: TimerManager
    @EnvironmentObject var appBlockerManager: AppBlockerManager
    @State private var selectedNav: NavItem = .tasks

    enum NavItem: String, CaseIterable, Identifiable {
        case tasks = "Tasks"
        case plans = "Plans"
        case timer = "Timer"
        case allTasks = "All Tasks"
        case block = "Block"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .tasks: return "list.bullet.circle.fill"
            case .plans: return "calendar.circle.fill"
            case .timer: return "timer.circle.fill"
            case .allTasks: return "tray.circle.fill"
            case .block: return "hand.raised.circle.fill"
            }
        }

        var shortcut: KeyEquivalent {
            switch self {
            case .tasks: return "1"
            case .plans: return "2"
            case .timer: return "3"
            case .allTasks: return "4"
            case .block: return "5"
            }
        }
    }

    init() {
        let taskManager = TaskManager()
        _taskManager = StateObject(wrappedValue: taskManager)
        _timerManager = StateObject(wrappedValue: TimerManager(taskManager: taskManager))
    }

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            sidebarView

            // Divider
            Rectangle()
                .fill(DesignSystem.Colors.border)
                .frame(width: 1)

            // Main Content
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(DesignSystem.Colors.background)
        }
        .background(DesignSystem.Colors.sidebar)
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
                selectedNav = .timer
                FloatingTimerManager.shared.showFloatingTimer()
            }
        }
        .onAppear {
            FloatingTimerManager.shared.setTimerManager(timerManager)
        }
    }

    // MARK: - Sidebar

    var sidebarView: some View {
        VStack(spacing: 0) {
            // App title
            HStack(spacing: 8) {
                Image(systemName: "hourglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.accent)

                Text("TaskTimer")
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Navigation items
            VStack(spacing: 2) {
                ForEach(NavItem.allCases) { item in
                    SidebarItem(
                        icon: item.icon,
                        title: item.rawValue,
                        isSelected: selectedNav == item,
                        shortcut: item.shortcut
                    ) {
                        withAnimation(DesignSystem.Animation.quick) {
                            selectedNav = item
                        }
                    }
                }
            }
            .padding(.horizontal, 8)

            Spacer()

            // Bottom: unclosable mode toggle
            VStack(spacing: 0) {
                Divider()
                    .background(DesignSystem.Colors.divider)

                Toggle(isOn: Binding(
                    get: { appBlockerManager.isUnclosableMode },
                    set: { appBlockerManager.isUnclosableMode = $0 }
                )) {
                    HStack(spacing: 6) {
                        Image(systemName: appBlockerManager.isUnclosableMode ? "lock.fill" : "lock.open")
                            .font(.system(size: 11))
                        Text("Unclosable")
                            .font(DesignSystem.Typography.caption)
                    }
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .toggleStyle(.switch)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .frame(width: DesignSystem.Layout.sidebarWidth)
        .background(DesignSystem.Colors.sidebar)
    }

    // MARK: - Content Area

    var contentView: some View {
        Group {
            switch selectedNav {
            case .tasks:
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
    }
}

// MARK: - Sidebar Item

struct SidebarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let shortcut: KeyEquivalent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.textSecondary)
                    .frame(width: 20)

                Text(title)
                    .font(DesignSystem.Typography.sidebarItem)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textSecondary)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(height: 32)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? DesignSystem.Colors.accentMuted : Color.clear)
            )
            .contentShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .keyboardShortcut(shortcut, modifiers: .command)
    }
}

#Preview {
    ContentView()
        .environmentObject(TaskManager())
        .environmentObject(TimerManager(taskManager: TaskManager()))
        .environmentObject(AppBlockerManager())
}