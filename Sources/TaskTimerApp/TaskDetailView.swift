import SwiftUI
import AppKit

struct TaskDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var timerManager: TimerManager

    let task: TaskItem
    @State private var editingTask: TaskItem

    @FocusState private var focusedField: FocusableField?

    enum FocusableField: Hashable {
        case title
    }

    init(task: TaskItem) {
        self.task = task
        self._editingTask = State(initialValue: task)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Task Details")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            Divider()
                .background(DesignSystem.Colors.divider)

            // Content
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    fieldGroup(label: "TITLE") {
                        TextField("Enter task title", text: $editingTask.title)
                            .focused($focusedField, equals: .title)
                            .textFieldStyle(.plain)
                            .font(DesignSystem.Typography.body)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(DesignSystem.Colors.surfaceHigh)
                            )
                    }

                    // Category & Priority
                    HStack(spacing: 12) {
                        fieldGroup(label: "CATEGORY") {
                            Picker("Category", selection: $editingTask.category) {
                                ForEach(taskManager.getAllCategories(), id: \.self) { cat in
                                    Text(cat).tag(cat)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(DesignSystem.Colors.surfaceHigh)
                            )
                        }

                        fieldGroup(label: "PRIORITY") {
                            Picker("Priority", selection: $editingTask.priority) {
                                ForEach(Priority.allCases, id: \.self) { prio in
                                    HStack {
                                        Circle()
                                            .fill(Color.taskPriority(prio))
                                            .frame(width: 8, height: 8)
                                        Text(prio.displayName)
                                    }
                                    .tag(prio)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(DesignSystem.Colors.surfaceHigh)
                            )
                        }
                    }

                    // Due Date
                    fieldGroup(label: "DUE DATE") {
                        if let _ = editingTask.dueDate {
                            HStack {
                                Text(editingTask.formattedDueDate)
                                    .font(DesignSystem.Typography.subheadline)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)

                                Spacer()

                                Button(action: {
                                    editingTask.dueDate = nil
                                    editingTask.dueTime = nil
                                }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 14))
                                        .foregroundColor(DesignSystem.Colors.error)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(DesignSystem.Colors.surfaceHigh)
                            )
                        } else {
                            Button(action: { editingTask.dueDate = Date() }) {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text("Set due date")
                                }
                                .font(DesignSystem.Typography.subheadline)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(DesignSystem.Colors.surfaceHigh)
                            )
                        }
                    }

                    // Recurring
                    fieldGroup(label: "RECURRING") {
                        Picker("Recurring", selection: $editingTask.recurringPattern) {
                            ForEach(RecurringPattern.allCases, id: \.self) { pattern in
                                Text(pattern.displayName).tag(pattern)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(DesignSystem.Colors.surfaceHigh)
                        )
                    }

                    // Subtasks
                    if !editingTask.subtasks.isEmpty {
                        fieldGroup(label: "SUBTASKS") {
                            VStack(spacing: 6) {
                                ForEach(editingTask.subtasks) { subtask in
                                    HStack {
                                        Button(action: { toggleSubtask(subtask) }) {
                                            Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 18))
                                                .foregroundColor(subtask.isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.textTertiary)
                                        }
                                        .buttonStyle(.plain)

                                        Text(subtask.title)
                                            .font(DesignSystem.Typography.subheadline)
                                            .foregroundColor(subtask.isCompleted ? DesignSystem.Colors.textTertiary : DesignSystem.Colors.textPrimary)
                                            .strikethrough(subtask.isCompleted)

                                        Spacer()
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(DesignSystem.Colors.surface)
                                    )
                                }
                            }
                        }
                    }

                    // Status Actions
                    fieldGroup(label: "STATUS") {
                        HStack(spacing: 10) {
                            Button(action: {
                                taskManager.toggleTaskCompletion(task)
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: editingTask.isCompleted ? "checkmark.circle.fill" : "circle")
                                    Text(editingTask.isCompleted ? "Completed" : "Mark Complete")
                                }
                                .font(DesignSystem.Typography.subheadline)
                                .foregroundColor(editingTask.isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.textPrimary)
                            }
                            .secondaryButtonStyle()

                            if !editingTask.isCompleted {
                                Button(action: {
                                    timerManager.markTaskAsComplete(task)
                                    dismiss()
                                }) {
                                    HStack {
                                        Image(systemName: "checkmark.shield.fill")
                                        Text("Quick Complete")
                                    }
                                    .font(DesignSystem.Typography.subheadline)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                }
                                .secondaryButtonStyle()
                            }
                        }
                    }

                    // Delete
                    Button(action: {
                        taskManager.deleteTask(task)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Task")
                        }
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.error)
                    }
                    .destructiveButtonStyle()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }

            Divider()
                .background(DesignSystem.Colors.divider)

            // Footer
            HStack {
                Spacer()
                Button("Save Changes") { saveChanges() }
                    .primaryButtonStyle()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .frame(width: 520, height: 640)
        .background(DesignSystem.Colors.background)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                ensureWindowFocus()
                focusedField = .title
            }
        }
    }

    // MARK: - Helpers

    private func fieldGroup<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textTertiary)
            content()
        }
    }

    private func toggleSubtask(_ subtask: Subtask) {
        if let index = editingTask.subtasks.firstIndex(where: { $0.id == subtask.id }) {
            editingTask.subtasks[index].isCompleted.toggle()
        }
    }

    private func saveChanges() {
        taskManager.updateTask(editingTask)
        dismiss()
    }
}

#Preview {
    TaskDetailView(task: TaskItem(title: "Sample Task", category: "Work"))
        .environmentObject(TaskManager())
        .environmentObject(TimerManager(taskManager: TaskManager()))
}