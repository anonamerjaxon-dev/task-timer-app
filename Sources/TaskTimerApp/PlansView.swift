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

            // Show tasks due in the next 7 days
            return dueDate >= today && dueDate <= nextWeek
        }.sorted { task1, task2 in
            // Sort by due date, then by priority
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
            HStack(spacing: 12) {
                TextField("Add a new plan...", text: $newPlanTitle)
                    .textFieldStyle(.plain)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                
                Button(action: {
                    if !newPlanTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                        taskManager.addPlan(Plan(title: newPlanTitle))
                        newPlanTitle = ""
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(newPlanTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .padding(.top, 30)
            
            Divider()
                .background(Color.gray.opacity(0.3))

            // Upcoming Tasks Section
            if !upcomingTasks.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Upcoming Tasks")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()

                        Text("\(upcomingTasks.count) upcoming")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(upcomingTasks) { task in
                                UpcomingTaskRow(task: task)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    .frame(maxHeight: 200)

                    Divider()
                        .background(Color.gray.opacity(0.3))
                }
            }

            // Plans List
            ScrollView {
                LazyVStack(spacing: 0) {
                    let activePlans = taskManager.plans.filter { !$0.isCompleted }
                    let completedPlans = taskManager.plans.filter { $0.isCompleted }

                    if activePlans.isEmpty && completedPlans.isEmpty {
                        Text("No plans yet")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                    } else {
                        if !activePlans.isEmpty {
                            Section {
                                ForEach(activePlans) { plan in
                                    PlanRow(plan: plan)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                }
                            }
                        }

                        if !completedPlans.isEmpty {
                            Section {
                                ForEach(completedPlans) { plan in
                                    PlanRow(plan: plan)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
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
        // Get the current plan state from taskManager to ensure reactivity
        let currentPlan = taskManager.plans.first { $0.id == plan.id } ?? plan

        return HStack(spacing: 14) {
            // Completion Button
            Button(action: {
                taskManager.togglePlanCompletion(plan)
            }) {
                Image(systemName: currentPlan.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(currentPlan.isCompleted ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())

            // Plan Title
            VStack(alignment: .leading, spacing: 4) {
                Text(currentPlan.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .strikethrough(currentPlan.isCompleted)

                if let completedAt = currentPlan.completedAt {
                    Text("Completed on \(formatDate(completedAt))")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            // Delete Button
            Button(action: {
                taskManager.deletePlan(plan)
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 18))
                    .foregroundColor(.red)
                    .frame(width: 32, height: 32)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(currentPlan.isCompleted ? Color.gray.opacity(0.1) : Color.gray.opacity(0.15))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct UpcomingTaskRow: View {
    let task: TaskItem
    @EnvironmentObject var taskManager: TaskManager

    var body: some View {
        HStack(spacing: 12) {
            // Priority indicator
            Circle()
                .fill(priorityColor)
                .frame(width: 8, height: 8)

            // Task info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(task.category)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)

                    if let dueDate = task.dueDate {
                        Text("•")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)

                        Text(formatDueDate(dueDate))
                            .font(.system(size: 11))
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
                    .foregroundColor(.green)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    private var priorityColor: Color {
        switch task.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }

    private func formatDueDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }

    private func dueDateColor(_ date: Date) -> Color {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return .orange
        } else if date < Date() {
            return .red
        } else {
            return .gray
        }
    }
}

struct PlansView_Previews: PreviewProvider {
    static var previews: some View {
        PlansView()
            .environmentObject(TaskManager())
    }
}