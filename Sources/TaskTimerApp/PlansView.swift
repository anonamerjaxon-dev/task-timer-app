import SwiftUI

struct PlansView: View {
    @EnvironmentObject var taskManager: TaskManager
    @State private var showingAddPlan = false
    @State private var newPlanTitle = ""

    private var upcomingTasks: [TaskItem] {
        let calendar = Calendar.current
        let today = Date()
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today) ?? today

        return taskManager.tasks.filter { task in
            guard !task.isCompleted,
                  let dueDate = task.dueDate else { return false }

            return dueDate >= today && dueDate <= nextWeek
        }.sorted { task1, task2 in
            guard let date1 = task1.dueDate, let date2 = task2.dueDate else { return false }
            if date1 != date2 {
                return date1 < date2
            }
            return task1.priority.sortIndex < task2.priority.sortIndex
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Add Plan Section
            HStack(spacing: DesignSystem.Spacing.oneAndHalf) {
                TextField("Add a new plan...", text: $newPlanTitle)
                    .textFieldStyle(.plain)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.oneAndHalf)
                    .background(DesignSystem.Colors.interactive)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                
                Button(action: {
                    if !newPlanTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                        taskManager.addPlan(Plan(title: newPlanTitle))
                        newPlanTitle = ""
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(DesignSystem.Colors.accent)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(newPlanTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, DesignSystem.Spacing.twoAndHalf)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.xl)
            
            Divider()
                .background(DesignSystem.Colors.divider)

            // Upcoming Tasks Section
            if !upcomingTasks.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.oneAndHalf) {
                    HStack {
                        Text("Upcoming Tasks")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.textPrimary)

                        Spacer()

                        Text("\(upcomingTasks.count) upcoming")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.twoAndHalf)
                    .padding(.top, DesignSystem.Spacing.md)

                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(upcomingTasks) { task in
                                UpcomingTaskRow(task: task)
                                    .padding(.horizontal, DesignSystem.Spacing.twoAndHalf)
                            }
                        }
                    }
                    .frame(maxHeight: 200)

                    Divider()
                        .background(DesignSystem.Colors.divider)
                }
            }

            // Plans List
            ScrollView {
                LazyVStack(spacing: 0) {
                    let activePlans = taskManager.plans.filter { !$0.isCompleted }
                    let completedPlans = taskManager.plans.filter { $0.isCompleted }

                    if activePlans.isEmpty && completedPlans.isEmpty {
                        Text("No plans yet")
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .padding(.top, DesignSystem.Spacing.xl)
                    } else {
                        if !activePlans.isEmpty {
                            Section {
                                ForEach(activePlans) { plan in
                                    PlanRow(plan: plan)
                                        .padding(.horizontal, DesignSystem.Spacing.md)
                                        .padding(.vertical, DesignSystem.Spacing.sm)
                                }
                            }
                        }

                        if !completedPlans.isEmpty {
                            Section {
                                ForEach(completedPlans) { plan in
                                    PlanRow(plan: plan)
                                        .padding(.horizontal, DesignSystem.Spacing.md)
                                        .padding(.vertical, DesignSystem.Spacing.sm)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct PlanRow: View {
    let plan: Plan
    @EnvironmentObject var taskManager: TaskManager

    var body: some View {
        let currentPlan = taskManager.plans.first { $0.id == plan.id } ?? plan

        return HStack(spacing: DesignSystem.Spacing.md) {
            // Completion Button
            Button(action: {
                taskManager.togglePlanCompletion(plan)
            }) {
                Image(systemName: currentPlan.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(currentPlan.isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.textTertiary)
            }
            .buttonStyle(PlainButtonStyle())

            // Plan Title
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(currentPlan.title)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .strikethrough(currentPlan.isCompleted)

                if let completedAt = currentPlan.completedAt {
                    Text("Completed on \(formatDate(completedAt))")
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
        .padding(.horizontal, DesignSystem.Spacing.md + 2)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(currentPlan.isCompleted ? DesignSystem.Colors.surface : DesignSystem.Colors.interactive)
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }
    
    private func formatDate(_ date: Date) -> String {
        DateFormatter.shortDate.string(from: date)
    }
}

struct UpcomingTaskRow: View {
    let task: TaskItem
    @EnvironmentObject var taskManager: TaskManager

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.oneAndHalf) {
            // Priority indicator
            Circle()
                .fill(Color.taskPriority(task.priority))
                .frame(width: 8, height: 8)

            // Task info
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(task.title)
                    .font(DesignSystem.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text(task.category)
                        .font(DesignSystem.Typography.tiny)
                        .foregroundColor(DesignSystem.Colors.textTertiary)

                    if let dueDate = task.dueDate {
                        Text("•")
                            .font(DesignSystem.Typography.tiny)
                            .foregroundColor(DesignSystem.Colors.textTertiary)

                        Text(formatDueDate(dueDate))
                            .font(DesignSystem.Typography.tiny)
                            .foregroundColor(dueDateColor(dueDate))
                    }
                }
            }

            Spacer()

            // Quick complete button
            Button(action: {
                taskManager.toggleTaskCompletion(task)
            }) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 18))
                    .foregroundColor(DesignSystem.Colors.success)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm + 2)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.subtle + 6)
    }

    private func formatDueDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            return DateFormatter.shortDate.string(from: date)
        }
    }

    private func dueDateColor(_ date: Date) -> Color {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return DesignSystem.Colors.warning
        } else if date < Date() {
            return DesignSystem.Colors.error
        } else {
            return DesignSystem.Colors.textTertiary
        }
    }
}

struct PlansView_Previews: PreviewProvider {
    static var previews: some View {
        PlansView()
            .environmentObject(TaskManager())
    }
}