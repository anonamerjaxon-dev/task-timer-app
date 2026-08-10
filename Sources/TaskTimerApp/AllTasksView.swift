import SwiftUI

struct AllTasksView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var timerManager: TimerManager
    @State private var showingTaskDetail: TaskItem?
    
    var allTasks: [TaskItem] {
        return taskManager.tasks
    }
    
    var allPlans: [Plan] {
        return taskManager.plans
    }
    
    var activePlans: [Plan] {
        taskManager.plans.filter { !$0.isCompleted }
    }
    
    var overdueTasks: [TaskItem] {
        taskManager.overdueTasks
    }
    
    var todayTasks: [TaskItem] {
        taskManager.tasksDueToday
    }
    
    var upcomingTasks: [TaskItem] {
        let tasks = taskManager.tasks.filter { !$0.isCompleted && !$0.isOverdue && !$0.isDueToday }
        
        return tasks.sorted { task1, task2 in
            if task1.priority.sortIndex != task2.priority.sortIndex {
                return task1.priority.sortIndex < task2.priority.sortIndex
            }

            switch (task1.dueDate, task2.dueDate) {
            case (nil, nil):
                return task1.createdAt < task2.createdAt
            case (nil, _):
                return false
            case (_, nil):
                return true
            case let (date1?, date2?):
                return date1 < date2
            }
        }
    }
    
    var completedTasks: [TaskItem] {
        return taskManager.tasks.filter { $0.isCompleted }
            .sorted { ($0.completedAt ?? Date.distantPast) > ($1.completedAt ?? Date.distantPast) }
    }
    
    var completedPlans: [Plan] {
        taskManager.plans.filter { $0.isCompleted }
            .sorted { ($0.completedAt ?? Date.distantPast) > ($1.completedAt ?? Date.distantPast) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("All Tasks & Plans")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                Text("\(allTasks.count + allPlans.count) total")
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.twoAndHalf)
            .background(DesignSystem.Colors.background)
            
            Divider()
                .background(DesignSystem.Colors.divider)
            
            // Content Sections
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Overdue Tasks
                    if !overdueTasks.isEmpty {
                        TaskSection(title: "Overdue", tasks: overdueTasks, color: DesignSystem.Colors.error)
                    }

                    // Today's Tasks
                    if !todayTasks.isEmpty {
                        TaskSection(title: "Today", tasks: todayTasks, color: DesignSystem.Colors.warning)
                    }

                    // Upcoming Tasks
                    if !upcomingTasks.isEmpty {
                        TaskSection(title: "Upcoming", tasks: upcomingTasks, color: DesignSystem.Colors.timerActive)
                    }

                    // Active Plans
                    if !activePlans.isEmpty {
                        PlanSection(title: "Active Plans", plans: activePlans, color: DesignSystem.Colors.timerBreak)
                    }
                    
                    // Completed Plans
                    if !completedPlans.isEmpty {
                        PlanSection(title: "Completed Plans", plans: completedPlans, color: DesignSystem.Colors.textTertiary)
                    }
                    
                    // Completed Tasks
                    if !completedTasks.isEmpty {
                        TaskSection(title: "Completed", tasks: completedTasks, color: DesignSystem.Colors.success)
                    }
                    
                    if allTasks.isEmpty && allPlans.isEmpty {
                        Text("No tasks or plans yet")
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .padding(.top, DesignSystem.Spacing.xl)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.twoAndHalf)
                .padding(.vertical, DesignSystem.Spacing.twoAndHalf)
            }
        }
        .sheet(item: $showingTaskDetail) { task in
            TaskDetailView(task: task)
        }
    }
}

struct PlanSection: View {
    let title: String
    let plans: [Plan]
    let color: Color
    @EnvironmentObject var taskManager: TaskManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.oneAndHalf) {
            // Section Header
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("(\(plans.count))")
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            
            // Plan Cards
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(plans) { plan in
                    PlanCard(plan: plan)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }
}

struct PlanCard: View {
    let plan: Plan
    @EnvironmentObject var taskManager: TaskManager
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.oneAndHalf) {
            // Completion Button
            Button(action: {
                taskManager.togglePlanCompletion(plan)
            }) {
                Image(systemName: plan.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(plan.isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.textTertiary)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Plan Info
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(plan.title)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .strikethrough(plan.isCompleted)
                
                if let completedAt = plan.completedAt {
                    Text("Completed \(formatDate(completedAt))")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }
            
            Spacer()
            
            // Delete Button
            Button(action: {
                taskManager.deletePlan(plan)
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 18))
                    .foregroundColor(DesignSystem.Colors.error)
                    .frame(width: 32, height: 32)
                    .background(DesignSystem.Colors.error.opacity(0.1))
                    .cornerRadius(DesignSystem.CornerRadius.small)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(plan.isCompleted ? DesignSystem.Colors.surface : DesignSystem.Colors.interactive)
        .cornerRadius(DesignSystem.CornerRadius.subtle + 6)
    }
    
    private func formatDate(_ date: Date) -> String {
        DateFormatter.shortDate.string(from: date)
    }
}

struct TaskSection: View {
    let title: String
    let tasks: [TaskItem]
    let color: Color
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.oneAndHalf) {
            // Section Header
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("(\(tasks.count))")
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            
            // Task Cards
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(tasks) { task in
                    TaskCard(task: task)
                        .onTapGesture {
                            // Could show detail view here
                        }
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }
}

struct TaskCard: View {
    let task: TaskItem
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.oneAndHalf) {
            // Priority Indicator
            Rectangle()
                .fill(Color.taskPriority(task.priority))
                .frame(width: 4)
                .cornerRadius(2)
            
            // Task Info
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(task.title)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .strikethrough(task.isCompleted)
                
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text(task.category)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    
                    if task.dueDate != nil {
                        Text(task.formattedDueDate)
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(task.isOverdue ? DesignSystem.Colors.error : DesignSystem.Colors.textTertiary)
                    }
                    
                    if task.recurringPattern != .none {
                        Image(systemName: "repeat")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                }
                
                // Subtasks Progress
                if !task.subtasks.isEmpty {
                    let completedSubtasks = task.subtasks.filter { $0.isCompleted }.count
                    let totalSubtasks = task.subtasks.count
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Text("\(completedSubtasks)/\(totalSubtasks) subtasks")
                            .font(DesignSystem.Typography.tiny)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                        
                        ProgressView(value: Double(completedSubtasks), total: Double(totalSubtasks))
                            .progressViewStyle(LinearProgressViewStyle(tint: DesignSystem.Colors.accentSecondary))
                            .frame(height: 4)
                    }
                }
            }
            
            Spacer()
            
            // Quick Actions
            HStack(spacing: DesignSystem.Spacing.sm) {
                if !task.isCompleted {
                    Button(action: {
                        timerManager.startTimer(for: task)
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Button(action: {
                    taskManager.toggleTaskCompletion(task)
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundColor(task.isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.textTertiary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(task.isOverdue ? DesignSystem.Colors.error.opacity(0.15) : DesignSystem.Colors.interactive)
        .cornerRadius(DesignSystem.CornerRadius.subtle + 6)
    }
}

struct AllTasksView_Previews: PreviewProvider {
    static var previews: some View {
        AllTasksView()
            .environmentObject(TaskManager())
            .environmentObject(TimerManager(taskManager: TaskManager()))
    }
}