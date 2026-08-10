import SwiftUI

struct TasksView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var timerManager: TimerManager
    @State private var selectedCategory: String = "All"
    @State private var showingAddTask = false
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""

    var filteredTasks: [TaskItem] {
        let tasks: [TaskItem]
        if selectedCategory == "All" {
            tasks = taskManager.tasks.filter { !$0.isCompleted }
        } else {
            tasks = taskManager.tasks.filter { $0.category == selectedCategory && !$0.isCompleted }
        }

        return tasks.sorted { task1, task2 in
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

    var categories: [String] {
        ["All"] + taskManager.getAllCategories()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Category filter
            categoryFilterView

            // Task list
            taskListView
        }
        .background(DesignSystem.Colors.background)
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
        .sheet(isPresented: $showingAddCategory) {
            addCategorySheet
        }
    }

    // MARK: - Header

    var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Tasks")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("\(taskManager.tasks.filter { !$0.isCompleted }.count) active")
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }

            Spacer()

            Button(action: { showingAddTask = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("New Task")
                        .font(DesignSystem.Typography.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(DesignSystem.Colors.accent)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }

    // MARK: - Category Filter

    var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        withAnimation(DesignSystem.Animation.quick) {
                            selectedCategory = category
                        }
                    }) {
                        Text(category)
                            .font(DesignSystem.Typography.footnote)
                            .fontWeight(selectedCategory == category ? .semibold : .regular)
                            .foregroundColor(selectedCategory == category ? .white : DesignSystem.Colors.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(selectedCategory == category ? DesignSystem.Colors.accent : DesignSystem.Colors.surfaceHigh)
                            )
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        if category != "All" {
                            Button(role: .destructive) {
                                deleteCategory(category)
                            } label: {
                                Label("Delete Category", systemImage: "trash")
                            }
                        }
                    }
                }

                Button(action: { showingAddCategory = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(DesignSystem.Colors.surfaceHigh)
                                .overlay(Circle().stroke(DesignSystem.Colors.borderSubtle, lineWidth: 1))
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 12)
    }

    // MARK: - Task List

    var taskListView: some View {
        ScrollView {
            if filteredTasks.isEmpty {
                EmptyState(
                    icon: "checkmark.circle",
                    title: "No Tasks",
                    message: "Click \"New Task\" to add your first task"
                )
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 6) {
                    ForEach(filteredTasks) { task in
                        TaskRowV2(task: task)
                            .padding(.horizontal, 24)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }

    // MARK: - Add Category Sheet

    var addCategorySheet: some View {
        VStack(spacing: 20) {
            Text("New Category")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            TextField("Category name", text: $newCategoryName)
                .textFieldStyle(.plain)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(DesignSystem.Colors.surfaceHigh)
                .cornerRadius(8)

            HStack(spacing: 12) {
                Button("Cancel") {
                    showingAddCategory = false
                    newCategoryName = ""
                }
                .secondaryButtonStyle()

                Button("Add") {
                    if !newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty {
                        let newCategory = Category(name: newCategoryName.trimmingCharacters(in: .whitespaces))
                        taskManager.addCategory(newCategory)
                        showingAddCategory = false
                        newCategoryName = ""
                    }
                }
                .primaryButtonStyle()
                .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 320, height: 200)
        .background(DesignSystem.Colors.background)
    }

    // MARK: - Helpers

    func deleteCategory(_ category: String) {
        taskManager.deleteCategory(named: category)
        if selectedCategory == category {
            selectedCategory = "All"
        }
    }
}

// MARK: - Task Row V2

struct TaskRowV2: View {
    let task: TaskItem
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var timerManager: TimerManager
    @State private var showingDetail = false

    var body: some View {
        Button(action: { showingDetail = true }) {
            HStack(spacing: 12) {
                // Priority bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.taskPriority(task.priority))
                    .frame(width: 3)

                // Completion toggle
                Button(action: {
                    if let currentTask = taskManager.tasks.first(where: { $0.id == task.id }) {
                        taskManager.toggleTaskCompletion(currentTask)
                    }
                }) {
                    let currentTask = taskManager.tasks.first(where: { $0.id == task.id })
                    let isCompleted = currentTask?.isCompleted ?? task.isCompleted
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundColor(isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.textTertiary)
                }
                .buttonStyle(.plain)

                // Task info
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(DesignSystem.Typography.callout)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .strikethrough(task.isCompleted)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        // Category badge
                        Text(task.category)
                            .font(DesignSystem.Typography.tiny)
                            .foregroundColor(DesignSystem.Colors.accent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(DesignSystem.Colors.accentMuted)
                            )

                        // Due date
                        if task.isOverdue {
                            HStack(spacing: 3) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 10))
                                Text("Overdue")
                            }
                            .font(DesignSystem.Typography.tiny)
                            .foregroundColor(DesignSystem.Colors.error)
                        } else if task.isDueToday {
                            Text("Today")
                                .font(DesignSystem.Typography.tiny)
                                .foregroundColor(DesignSystem.Colors.warning)
                        } else if let _ = task.dueDate {
                            Text(task.formattedDueDateShort)
                                .font(DesignSystem.Typography.tiny)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }

                        if task.recurringPattern != .none {
                            Image(systemName: "repeat")
                                .font(.system(size: 10))
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    }

                    // Subtask progress
                    if !task.subtasks.isEmpty {
                        subtaskProgress
                    }
                }

                Spacer()

                // Timer button
                if !task.isCompleted {
                    Button(action: {
                        timerManager.startTimer(for: task)
                    }) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.accent)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(DesignSystem.Colors.accentMuted)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(task.isOverdue ? DesignSystem.Colors.errorMuted : DesignSystem.Colors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        task.isOverdue ? DesignSystem.Colors.error.opacity(0.2) : DesignSystem.Colors.borderSubtle,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDetail) {
            TaskDetailView(task: task)
        }
    }

    var subtaskProgress: some View {
        let completed = task.subtasks.filter { $0.isCompleted }.count
        let total = task.subtasks.count
        return HStack(spacing: 6) {
            ProgressView(value: Double(completed), total: Double(total))
                .progressViewStyle(LinearProgressViewStyle(tint: DesignSystem.Colors.accent))
                .frame(width: 60, height: 3)
            Text("\(completed)/\(total)")
                .font(DesignSystem.Typography.tiny)
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
    }
}

#Preview {
    TasksView()
        .environmentObject(TaskManager())
        .environmentObject(TimerManager(taskManager: TaskManager()))
}