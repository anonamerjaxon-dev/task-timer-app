import SwiftUI

struct PlansView: View {
    @EnvironmentObject var taskManager: TaskManager
    @State private var newPlanTitle = ""

    private var upcomingTasks: [TaskItem] {
        let calendar = Calendar.current
        let today = Date()
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today) ?? today

        return taskManager.tasks.filter { task in
            guard !task.isCompleted, let dueDate = task.dueDate else { return false }
            return dueDate >= today && dueDate <= nextWeek
        }.sorted { task1, task2 in
            guard let date1 = task1.dueDate, let date2 = task2.dueDate else { return false }
            if date1 != date2 { return date1 < date2 }
            return task1.priority.sortIndex < task2.priority.sortIndex
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Add plan input
            addPlanInput

            // Upcoming tasks
            if !upcomingTasks.isEmpty {
                upcomingSection
            }

            // Plans list
            plansListView
        }
        .background(DesignSystem.Colors.background)
    }

    // MARK: - Header

    var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Plans")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("\(taskManager.plans.count) total")
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }

    // MARK: - Add Plan

    var addPlanInput: some View {
        HStack(spacing: 10) {
            TextField("Add a new plan...", text: $newPlanTitle)
                .textFieldStyle(.plain)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(DesignSystem.Colors.surfaceHigh)
                )

            Button(action: {
                if !newPlanTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                    taskManager.addPlan(Plan(title: newPlanTitle))
                    newPlanTitle = ""
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(DesignSystem.Colors.accent)
                    )
            }
            .buttonStyle(.plain)
            .disabled(newPlanTitle.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }

    // MARK: - Upcoming

    var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Upcoming Tasks", count: upcomingTasks.count, color: DesignSystem.Colors.warning)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)

            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(upcomingTasks) { task in
                        UpcomingTaskRowV2(task: task)
                            .padding(.horizontal, 24)
                    }
                }
            }
            .frame(maxHeight: 180)

            Divider()
                .background(DesignSystem.Colors.divider)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
        }
    }

    // MARK: - Plans List

    var plansListView: some View {
        let activePlans = taskManager.plans.filter { !$0.isCompleted }
        let completedPlans = taskManager.plans.filter { $0.isCompleted }

        return ScrollView {
            if activePlans.isEmpty && completedPlans.isEmpty {
                EmptyState(
                    icon: "calendar.badge.plus",
                    title: "No Plans Yet",
                    message: "Type a plan above and press enter to add it"
                )
            } else {
                LazyVStack(spacing: 6) {
                    if !activePlans.isEmpty {
                        Section {
                            ForEach(activePlans) { plan in
                                PlanRowV2(plan: plan)
                            }
                        }
                    }

                    if !completedPlans.isEmpty {
                        Section {
                            ForEach(completedPlans) { plan in
                                PlanRowV2(plan: plan)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Plan Row V2

struct PlanRowV2: View {
    let plan: Plan
    @EnvironmentObject var taskManager: TaskManager

    var body: some View {
        let currentPlan = taskManager.plans.first { $0.id == plan.id } ?? plan

        HStack(spacing: 12) {
            Button(action: { taskManager.togglePlanCompletion(plan) }) {
                Image(systemName: currentPlan.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(currentPlan.isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.textTertiary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(currentPlan.title)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .strikethrough(currentPlan.isCompleted)

                if let completedAt = currentPlan.completedAt {
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
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(currentPlan.isCompleted ? DesignSystem.Colors.surface : DesignSystem.Colors.surfaceHigh)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(DesignSystem.Colors.borderSubtle, lineWidth: 1)
        )
    }

    private func formatDate(_ date: Date) -> String {
        DateFormatter.shortDate.string(from: date)
    }
}

// MARK: - Upcoming Task Row V2

struct UpcomingTaskRowV2: View {
    let task: TaskItem
    @EnvironmentObject var taskManager: TaskManager

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.taskPriority(task.priority))
                .frame(width: 6, height: 6)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(DesignSystem.Typography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(task.category)
                        .font(DesignSystem.Typography.tiny)
                        .foregroundColor(DesignSystem.Colors.textTertiary)

                    if let dueDate = task.dueDate {
                        Text("·")
                            .font(DesignSystem.Typography.tiny)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                        Text(formatDueDate(dueDate))
                            .font(DesignSystem.Typography.tiny)
                            .foregroundColor(dueDateColor(dueDate))
                    }
                }
            }

            Spacer()

            Button(action: { taskManager.toggleTaskCompletion(task) }) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 16))
                    .foregroundColor(DesignSystem.Colors.success)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(DesignSystem.Colors.surface)
        )
    }

    private func formatDueDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        return DateFormatter.shortDate.string(from: date)
    }

    private func dueDateColor(_ date: Date) -> Color {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return DesignSystem.Colors.warning }
        if date < Date() { return DesignSystem.Colors.error }
        return DesignSystem.Colors.textTertiary
    }
}

#Preview {
    PlansView()
        .environmentObject(TaskManager())
}