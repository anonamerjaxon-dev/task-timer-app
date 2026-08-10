import SwiftUI

struct AllTasksView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var timerManager: TimerManager
    @State private var showingTaskDetail: TaskItem?

    var allTasks: [TaskItem] { taskManager.tasks }
    var allPlans: [Plan] { taskManager.plans }
    var activePlans: [Plan] { taskManager.plans.filter { !$0.isCompleted } }
    var overdueTasks: [TaskItem] { taskManager.overdueTasks }
    var todayTasks: [TaskItem] { taskManager.tasksDueToday }

    var upcomingTasks: [TaskItem] {
        taskManager.tasks.filter { !$0.isCompleted && !$0.isOverdue && !$0.isDueToday }
            .sorted { task1, task2 in
                if task1.priority.sortIndex != task2.priority.sortIndex {
                    return task1.priority.sortIndex < task2.priority.sortIndex
                }
                switch (task1.dueDate, task2.dueDate) {
                case (nil, nil): return task1.createdAt < task2.createdAt
                case (nil, _): return false
                case (_, nil): return true
                case let (date1?, date2?): return date1 < date2
                }
            }
    }

    var completedTasks: [TaskItem] {
        taskManager.tasks.filter { $0.isCompleted }
            .sorted { ($0.completedAt ?? Date.distantPast) > ($1.completedAt ?? Date.distantPast) }
    }

    var completedPlans: [Plan] {
        taskManager.plans.filter { $0.isCompleted }
            .sorted { ($0.completedAt ?? Date.distantPast) > ($1.completedAt ?? Date.distantPast) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Content
            ScrollView {
                VStack(spacing: 20) {
                    if !overdueTasks.isEmpty {
                        TaskSectionV2(title: "Overdue", tasks: overdueTasks, color: DesignSystem.Colors.error)
                    }
                    if !todayTasks.isEmpty {
                        TaskSectionV2(title: "Today", tasks: todayTasks, color: DesignSystem.Colors.warning)
                    }
                    if !upcomingTasks.isEmpty {
                        TaskSectionV2(title: "Upcoming", tasks: upcomingTasks, color: DesignSystem.Colors.timerFocus)
                    }
                    if !activePlans.isEmpty {
                        PlanSectionV2(title: "Active Plans", plans: activePlans, color: DesignSystem.Colors.timerBreak)
                    }
                    if !completedPlans.isEmpty {
                        PlanSectionV2(title: "Completed Plans", plans: completedPlans, color: DesignSystem.Colors.textTertiary)
                    }
                    if !completedTasks.isEmpty {
                        TaskSectionV2(title: "Completed", tasks: completedTasks, color: DesignSystem.Colors.success)
                    }
                    if allTasks.isEmpty && allPlans.isEmpty {
                        EmptyState(
                            icon: "tray",
                            title: "No Tasks or Plans",
                            message: "Add tasks and plans to see them here"
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
        }
        .background(DesignSystem.Colors.background)
        .sheet(item: $showingTaskDetail) { task in
            TaskDetailView(task: task)
        }
    }

    var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("All Tasks")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Text("\(allTasks.count + allPlans.count) total")
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
}

// MARK: - Task Section V2

struct TaskSectionV2: View {
    let title: String
    let tasks: [TaskItem]
    let color: Color
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var timerManager: TimerManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: title, count: tasks.count, color: color)

            VStack(spacing: 6) {
                ForEach(tasks) { task in
                    TaskCardV2(task: task)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignSystem.Colors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DesignSystem.Colors.borderSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Task Card V2

struct TaskCardV2: View {
    let task: TaskItem
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var timerManager: TimerManager

    var body: some View {
        HStack(spacing: 12) {
            // Priority bar
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.taskPriority(task.priority))
                .frame(width: 3)

            // Completion
            Button(action: {
                taskManager.toggleTaskCompletion(task)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(task.isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.textTertiary)
            }
            .buttonStyle(.plain)

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .strikethrough(task.isCompleted)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(task.category)
                        .font(DesignSystem.Typography.tiny)
                        .foregroundColor(DesignSystem.Colors.accent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Capsule().fill(DesignSystem.Colors.accentMuted))

                    if let _ = task.dueDate {
                        Text(task.formattedDueDate)
                            .font(DesignSystem.Typography.tiny)
                            .foregroundColor(task.isOverdue ? DesignSystem.Colors.error : DesignSystem.Colors.textTertiary)
                    }

                    if task.recurringPattern != .none {
                        Image(systemName: "repeat")
                            .font(.system(size: 10))
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                }
            }

            Spacer()

            // Actions
            HStack(spacing: 8) {
                if !task.isCompleted {
                    Button(action: { timerManager.startTimer(for: task) }) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.accent)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(DesignSystem.Colors.accentMuted))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(task.isOverdue ? DesignSystem.Colors.errorMuted : DesignSystem.Colors.surfaceHigh)
        )
    }
}

// MARK: - Plan Section V2

struct PlanSectionV2: View {
    let title: String
    let plans: [Plan]
    let color: Color
    @EnvironmentObject var taskManager: TaskManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: title, count: plans.count, color: color)

            VStack(spacing: 6) {
                ForEach(plans) { plan in
                    PlanCardV2(plan: plan)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignSystem.Colors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DesignSystem.Colors.borderSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Plan Card V2

struct PlanCardV2: View {
    let plan: Plan
    @EnvironmentObject var taskManager: TaskManager

    var body: some View {
        HStack(spacing: 12) {
            Button(action: { taskManager.togglePlanCompletion(plan) }) {
                Image(systemName: plan.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(plan.isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.textTertiary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(plan.title)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .strikethrough(plan.isCompleted)

                if let completedAt = plan.completedAt {
                    Text("Completed \(formatDate(completedAt))")
                        .font(DesignSystem.Typography.tiny)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }

            Spacer()

            Button(action: { taskManager.deletePlan(plan) }) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.error)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(DesignSystem.Colors.errorMuted))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(plan.isCompleted ? DesignSystem.Colors.surface : DesignSystem.Colors.surfaceHigh)
        )
    }

    private func formatDate(_ date: Date) -> String {
        DateFormatter.shortDate.string(from: date)
    }
}

#Preview {
    AllTasksView()
        .environmentObject(TaskManager())
        .environmentObject(TimerManager(taskManager: TaskManager()))
}