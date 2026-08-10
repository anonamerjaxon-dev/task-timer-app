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
                    Image(systemName: "xmark")
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.twoAndHalf)
            .background(DesignSystem.Colors.background)
            
            Divider()
                .background(DesignSystem.Colors.divider)
            
            // Content
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Title
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Title")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                        
                        TextField("Enter task title", text: $editingTask.title)
                            .focused($focusedField, equals: .title)
                            .textFieldStyle(.plain)
                            .font(DesignSystem.Typography.body)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.vertical, DesignSystem.Spacing.oneAndHalf)
                            .background(DesignSystem.Colors.interactive)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                            .onTapGesture {
                                focusedField = .title
                                ensureWindowFocus()
                            }
                    }
                    
                    // Info Grid
                    HStack(spacing: DesignSystem.Spacing.md) {
                        // Category
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("Category")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            
                            Picker("Category", selection: $editingTask.category) {
                                ForEach(taskManager.getAllCategories(), id: \.self) { cat in
                                    Text(cat).tag(cat)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.vertical, DesignSystem.Spacing.oneAndHalf)
                            .background(DesignSystem.Colors.interactive)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                        }
                        
                        // Priority
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("Priority")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            
                            Picker("Priority", selection: $editingTask.priority) {
                                ForEach(Priority.allCases, id: \.self) { prio in
                                    Text(prio.displayName).tag(prio)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.vertical, DesignSystem.Spacing.oneAndHalf)
                            .background(DesignSystem.Colors.interactive)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                        }
                    }
                    
                    // Due Date & Time
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Due Date")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                        
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
                                        .font(DesignSystem.Typography.subheadline)
                                        .foregroundColor(DesignSystem.Colors.error)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.vertical, DesignSystem.Spacing.oneAndHalf)
                            .background(DesignSystem.Colors.interactive)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                        } else {
                            Button(action: {
                                editingTask.dueDate = Date()
                            }) {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text("Set due date")
                                }
                                .font(DesignSystem.Typography.subheadline)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.vertical, DesignSystem.Spacing.oneAndHalf)
                            .background(DesignSystem.Colors.interactive)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                        }
                    }
                    
                    // Recurring
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Recurring")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                        
                        Picker("Recurring", selection: $editingTask.recurringPattern) {
                            ForEach(RecurringPattern.allCases, id: \.self) { pattern in
                                Text(pattern.displayName).tag(pattern)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.oneAndHalf)
                        .background(DesignSystem.Colors.interactive)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                    }
                    
                    // Subtasks
                    if !editingTask.subtasks.isEmpty {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.oneAndHalf) {
                            Text("Subtasks")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                ForEach(editingTask.subtasks) { subtask in
                                    HStack {
                                        Button(action: {
                                            toggleSubtask(subtask)
                                        }) {
                                            Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 20))
                                                .foregroundColor(subtask.isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.textTertiary)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        Text(subtask.title)
                                            .font(DesignSystem.Typography.subheadline)
                                            .foregroundColor(subtask.isCompleted ? DesignSystem.Colors.textTertiary : DesignSystem.Colors.textPrimary)
                                            .strikethrough(subtask.isCompleted)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, DesignSystem.Spacing.md)
                                    .padding(.vertical, DesignSystem.Spacing.sm + 2)
                                    .background(DesignSystem.Colors.surface)
                                    .cornerRadius(DesignSystem.CornerRadius.medium)
                                }
                            }
                        }
                    }
                    
                    // Status
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Status")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                        
                        HStack(spacing: DesignSystem.Spacing.oneAndHalf) {
                            Button(action: {
                                taskManager.toggleTaskCompletion(task)
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: editingTask.isCompleted ? "checkmark.circle.fill" : "circle")
                                    Text(editingTask.isCompleted ? "Completed" : "Mark as Complete")
                                }
                                .font(DesignSystem.Typography.subheadline)
                                .foregroundColor(editingTask.isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.textPrimary)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, DesignSystem.Spacing.md + 2)
                            .padding(.vertical, DesignSystem.Spacing.oneAndHalf)
                            .background(DesignSystem.Colors.interactive)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                            
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
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, DesignSystem.Spacing.md + 2)
                                .padding(.vertical, DesignSystem.Spacing.oneAndHalf)
                                .background(DesignSystem.Colors.interactive)
                                .cornerRadius(DesignSystem.CornerRadius.medium)
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
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.lg)
            }
            
            Divider()
                .background(DesignSystem.Colors.divider)
            
            // Footer
            HStack {
                Spacer()
                
                Button(action: saveChanges) {
                    Text("Save Changes")
                        .font(DesignSystem.Typography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.background)
                        .padding(.horizontal, DesignSystem.Spacing.xl - 4)
                        .padding(.vertical, DesignSystem.Spacing.oneAndHalf)
                        .background(DesignSystem.Colors.accent)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.background)
        }
        .frame(width: 500, height: 600)
        .background(DesignSystem.Colors.background)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                ensureWindowFocus()
                focusedField = .title
            }
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

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailView(task: TaskItem(title: "Sample Task", category: "Work"))
            .environmentObject(TaskManager())
            .environmentObject(TimerManager(taskManager: TaskManager()))
    }
}