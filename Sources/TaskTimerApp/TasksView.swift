import SwiftUI

struct TasksView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var timerManager: TimerManager
    @State private var selectedCategory: String = "All"
    @State private var showingAddTask = false
    @State private var showingAddCategory = false
    @State private var showingTaskDetail: TaskItem?
    @State private var newCategoryName = ""

    var filteredTasks: [TaskItem] {
        let tasks: [TaskItem]
        if selectedCategory == "All" {
            tasks = taskManager.tasks.filter { !$0.isCompleted }
        } else {
            tasks = taskManager.tasks.filter { $0.category == selectedCategory && !$0.isCompleted }
        }

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
    
    var categories: [String] {
        ["All"] + taskManager.getAllCategories()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Selector - Minimalistic
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(categories, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            withAnimation(DesignSystem.Animation.quick) {
                                selectedCategory = category
                            }
                        } onDelete: {
                            deleteCategory(category)
                        }
                    }

                    // Add category button - Enhanced
                    Button(action: { showingAddCategory = true }) {
                        Image(systemName: "plus")
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .frame(width: 32, height: 32) // Larger touch target
                            .background(DesignSystem.Colors.interactive)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
            }
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.background)

            Divider()
                .background(DesignSystem.Colors.surface)

            // Task List - Optimized
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.xs) {
                    if filteredTasks.isEmpty {
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 32))
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            Text("No tasks")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            Text("Add a task to get started")
                                .font(DesignSystem.Typography.footnote)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                        .padding(.top, DesignSystem.Spacing.xxxl)
                    } else {
                        ForEach(filteredTasks) { task in
                            TaskRow(task: task)
                                .onTapGesture {
                                    showingTaskDetail = task
                                }
                                .padding(.horizontal, DesignSystem.Spacing.md)
                        }
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
        .sheet(isPresented: $showingAddCategory) {
            VStack(spacing: 20) {
                Text("Add Category")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                TextField("Category name", text: $newCategoryName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                HStack(spacing: 16) {
                    Button("Cancel") {
                        showingAddCategory = false
                        newCategoryName = ""
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Add") {
                        if !newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty {
                            let newCategory = Category(name: newCategoryName.trimmingCharacters(in: .whitespaces))
                            taskManager.addCategory(newCategory)
                            showingAddCategory = false
                            newCategoryName = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .padding()
            .frame(width: 300, height: 200)
        }
        .sheet(item: $showingTaskDetail) { task in
            TaskDetailView(task: task)
        }
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.background)
                            .frame(width: 60, height: 60) // Larger touch target
                            .background(DesignSystem.Colors.accent)
                            .cornerRadius(30)
                            .shadow(color: DesignSystem.Shadows.medium, radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.lg)
                }
            }
        )
    }
    
    func deleteCategory(_ category: String) {
        taskManager.deleteCategory(named: category)
        
        // Reset to All category if we deleted the selected one
        if selectedCategory == category {
            selectedCategory = "All"
        }
    }
}

struct CategoryButton: View {
    let category: String
    let isSelected: Bool
    let action: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: action) {
            Text(category)
                .font(DesignSystem.Typography.caption1)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? DesignSystem.Colors.background : DesignSystem.Colors.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(
                    Capsule()
                        .fill(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.interactive)
                )
                .contentShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            if category != "All" {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete Category", systemImage: "trash")
                }
            }
        }
    }
}

struct TaskRow: View {
    let task: TaskItem
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var timerManager: TimerManager

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Priority Indicator - Enhanced
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.taskPriority(task.priority))
                .frame(width: 4) // Slightly thicker

            // Task Info
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(task.title)
                    .font(DesignSystem.Typography.callout) // Larger font
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .strikethrough(task.isCompleted)

                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text(task.category)
                        .font(DesignSystem.Typography.caption1) // Larger
                        .foregroundColor(DesignSystem.Colors.textSecondary) // Better contrast

                    if task.isOverdue {
                        Text("Overdue")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.error)
                    } else if task.isDueToday {
                        Text("Today")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.warning)
                    } else if task.dueDate != nil {
                        Text(task.formattedDueDateShort)
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }

                    if task.recurringPattern != .none {
                        Image(systemName: "repeat")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                }

                // Subtasks Progress - Minimalistic
                if !task.subtasks.isEmpty {
                    let completedSubtasks = task.subtasks.filter { $0.isCompleted }.count
                    let totalSubtasks = task.subtasks.count
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Text("\(completedSubtasks)/\(totalSubtasks)")
                            .font(DesignSystem.Typography.caption1) // Larger
                            .foregroundColor(DesignSystem.Colors.textTertiary)

                        ProgressView(value: Double(completedSubtasks), total: Double(totalSubtasks))
                            .progressViewStyle(LinearProgressViewStyle(tint: DesignSystem.Colors.accentSecondary))
                            .frame(height: 2)
                    }
                }
            }

            Spacer()

            // Quick Actions - Minimalistic
            HStack(spacing: DesignSystem.Spacing.xs) {
                if !task.isCompleted {
                    Button(action: {
                        timerManager.startTimer(for: task)
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(DesignSystem.Colors.timerActive)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Button(action: {
                    // Use task ID to ensure we're working with the correct task
                    if let currentTask = taskManager.tasks.first(where: { $0.id == task.id }) {
                        taskManager.toggleTaskCompletion(currentTask)
                    }
                }) {
                    // Get current state from taskManager to ensure reactivity
                    let currentTask = taskManager.tasks.first(where: { $0.id == task.id })
                    let isCompleted = currentTask?.isCompleted ?? task.isCompleted

                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundColor(isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.textTertiary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .cardPadding()
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium) // Larger radius
                .fill(task.isOverdue ? DesignSystem.Colors.error.opacity(0.1) : DesignSystem.Colors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(task.isOverdue ? DesignSystem.Colors.error.opacity(0.3) : DesignSystem.Colors.divider, lineWidth: 1)
        )
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView()
            .environmentObject(TaskManager())
            .environmentObject(TimerManager(taskManager: TaskManager()))
    }
}