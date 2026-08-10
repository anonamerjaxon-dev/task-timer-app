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
        
        let priorityOrder: [Priority] = [.high, .medium, .low]
        return tasks.sorted { task1, task2 in
            let index1 = priorityOrder.firstIndex(of: task1.priority) ?? Int.max
            let index2 = priorityOrder.firstIndex(of: task2.priority) ?? Int.max
            
            if index1 != index2 {
                return index1 < index2
            }
            
            // Same priority, sort by due date
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
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(allTasks.count + allPlans.count) total")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(Color.black)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Content Sections
            ScrollView {
                VStack(spacing: 24) {
                    // Overdue Tasks
                    if !overdueTasks.isEmpty {
                        TaskSection(title: "Overdue", tasks: overdueTasks, color: .red)
                    }

                    // Today's Tasks
                    if !todayTasks.isEmpty {
                        TaskSection(title: "Today", tasks: todayTasks, color: .orange)
                    }

                    // Upcoming Tasks
                    if !upcomingTasks.isEmpty {
                        TaskSection(title: "Upcoming", tasks: upcomingTasks, color: .blue)
                    }

                    // Active Plans
                    if !activePlans.isEmpty {
                        PlanSection(title: "Active Plans", plans: activePlans, color: .purple)
                    }
                    
                    // Completed Plans
                    if !completedPlans.isEmpty {
                        PlanSection(title: "Completed Plans", plans: completedPlans, color: .gray)
                    }
                    
                    // Completed Tasks
                    if !completedTasks.isEmpty {
                        TaskSection(title: "Completed", tasks: completedTasks, color: .green)
                    }
                    
                    if allTasks.isEmpty && allPlans.isEmpty {
                        Text("No tasks or plans yet")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
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
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("(\(plans.count))")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            // Plan Cards
            VStack(spacing: 8) {
                ForEach(plans) { plan in
                    PlanCard(plan: plan)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct PlanCard: View {
    let plan: Plan
    @EnvironmentObject var taskManager: TaskManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion Button
            Button(action: {
                taskManager.togglePlanCompletion(plan)
            }) {
                Image(systemName: plan.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(plan.isCompleted ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Plan Info
            VStack(alignment: .leading, spacing: 4) {
                Text(plan.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .strikethrough(plan.isCompleted)
                
                if let completedAt = plan.completedAt {
                    Text("Completed \(formatDate(completedAt))")
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
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(plan.isCompleted ? Color.gray.opacity(0.1) : Color.gray.opacity(0.15))
        .cornerRadius(10)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct TaskSection: View {
    let title: String
    let tasks: [TaskItem]
    let color: Color
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("(\(tasks.count))")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            // Task Cards
            VStack(spacing: 8) {
                ForEach(tasks) { task in
                    TaskCard(task: task)
                        .onTapGesture {
                            // Could show detail view here
                        }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct TaskCard: View {
    let task: TaskItem
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Priority Indicator
            Rectangle()
                .fill(priorityColor)
                .frame(width: 4)
                .cornerRadius(2)
            
            // Task Info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .strikethrough(task.isCompleted)
                
                HStack(spacing: 8) {
                    Text(task.category)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    if task.dueDate != nil {
                        Text(task.formattedDueDate)
                            .font(.system(size: 12))
                            .foregroundColor(task.isOverdue ? .red : .gray)
                    }
                    
                    if task.recurringPattern != .none {
                        Image(systemName: "repeat")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                }
                
                // Subtasks Progress
                if !task.subtasks.isEmpty {
                    let completedSubtasks = task.subtasks.filter { $0.isCompleted }.count
                    let totalSubtasks = task.subtasks.count
                    HStack(spacing: 4) {
                        Text("\(completedSubtasks)/\(totalSubtasks) subtasks")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        
                        ProgressView(value: Double(completedSubtasks), total: Double(totalSubtasks))
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .frame(height: 4)
                    }
                }
            }
            
            Spacer()
            
            // Quick Actions
            HStack(spacing: 8) {
                if !task.isCompleted {
                    Button(action: {
                        timerManager.startTimer(for: task)
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Button(action: {
                    taskManager.toggleTaskCompletion(task)
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundColor(task.isCompleted ? .green : .gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(task.isOverdue ? Color.red.opacity(0.15) : Color.gray.opacity(0.15))
        .cornerRadius(10)
    }
    
    var priorityColor: Color {
        switch task.priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .green
        }
    }
}

struct AllTasksView_Previews: PreviewProvider {
    static var previews: some View {
        AllTasksView()
            .environmentObject(TaskManager())
            .environmentObject(TimerManager(taskManager: TaskManager()))
    }
}
