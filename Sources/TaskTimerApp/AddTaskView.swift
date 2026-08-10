import SwiftUI
import AppKit

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var taskManager: TaskManager
    
    @State private var title = ""
    @State private var category = "Other"
    @State private var priority: Priority = .medium
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var hasDueTime = false
    @State private var dueTime = Date()
    @State private var recurringPattern: RecurringPattern = .none
    @State private var subtasks: [String] = []
    @State private var newSubtask = ""
    
    @FocusState private var focusedField: FocusableField?
    
    enum FocusableField: Hashable {
        case title
        case category
        case subtask
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("New Task")
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
                        
                        TextField("Enter task title", text: $title)
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
                                ensureWindowFocus()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    focusedField = .title
                                }
                            }
                    }
                    
                    // Category
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Category")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                        
                        HStack(spacing: DesignSystem.Spacing.oneAndHalf) {
                            TextField("Enter category", text: $category)
                                .focused($focusedField, equals: .category)
                                .textFieldStyle(.plain)
                                .font(DesignSystem.Typography.subheadline)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .padding(.horizontal, DesignSystem.Spacing.md)
                                .padding(.vertical, DesignSystem.Spacing.oneAndHalf)
                                .background(DesignSystem.Colors.interactive)
                                .cornerRadius(DesignSystem.CornerRadius.medium)
                                .onTapGesture {
                                    ensureWindowFocus()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                        focusedField = .category
                                    }
                                }
                            
                            Picker("Existing", selection: $category) {
                                Text("Select...").tag("")
                                ForEach(taskManager.getAllCategories(), id: \.self) { cat in
                                    Text(cat).tag(cat)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 120)
                            .padding(.horizontal, DesignSystem.Spacing.sm)
                            .padding(.vertical, DesignSystem.Spacing.sm)
                            .background(DesignSystem.Colors.interactive)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                        }
                    }
                    
                    // Priority
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Priority")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                        
                        Picker("Priority", selection: $priority) {
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
                    
                    // Due Date
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Due Date")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                        
                        HStack {
                            Toggle("", isOn: $hasDueDate)
                                .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.timerActive))
                            
                            Spacer()
                            
                            if hasDueDate {
                                DatePicker("", selection: $dueDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .colorScheme(.dark)
                            } else {
                                Text("No due date")
                                    .font(DesignSystem.Typography.subheadline)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.oneAndHalf)
                        .background(DesignSystem.Colors.interactive)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                    }
                    
                    // Due Time
                    if hasDueDate {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("Due Time")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            
                            HStack {
                                Toggle("", isOn: $hasDueTime)
                                    .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.timerActive))
                                
                                Spacer()
                                
                                if hasDueTime {
                                    DatePicker("", selection: $dueTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .colorScheme(.dark)
                                } else {
                                    Text("No specific time")
                                        .font(DesignSystem.Typography.subheadline)
                                        .foregroundColor(DesignSystem.Colors.textTertiary)
                                }
                            }
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
                        
                        Picker("Recurring", selection: $recurringPattern) {
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
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.oneAndHalf) {
                        Text("Subtasks")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                        
                        // Add new subtask
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            TextField("Add subtask", text: $newSubtask)
                                .focused($focusedField, equals: .subtask)
                                .textFieldStyle(.plain)
                                .font(DesignSystem.Typography.subheadline)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .padding(.horizontal, DesignSystem.Spacing.md)
                                .padding(.vertical, DesignSystem.Spacing.sm + 2)
                                .background(DesignSystem.Colors.interactive)
                                .cornerRadius(DesignSystem.CornerRadius.subtle + 6)
                                .onSubmit {
                                    if !newSubtask.isEmpty {
                                        subtasks.append(newSubtask)
                                        newSubtask = ""
                                    }
                                }
                                .onTapGesture {
                                    ensureWindowFocus()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                        focusedField = .subtask
                                    }
                                }
                            
                            Button(action: {
                                if !newSubtask.isEmpty {
                                    subtasks.append(newSubtask)
                                    newSubtask = ""
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.vertical, DesignSystem.Spacing.sm + 2)
                            .background(DesignSystem.Colors.interactiveHover)
                            .cornerRadius(DesignSystem.CornerRadius.subtle + 6)
                        }
                        
                        // List of subtasks
                        ForEach(Array(subtasks.enumerated()), id: \.offset) { index, subtask in
                            HStack {
                                Text(subtask)
                                    .font(DesignSystem.Typography.subheadline)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Spacer()
                                
                                Button(action: {
                                    subtasks.remove(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(DesignSystem.Typography.body)
                                        .foregroundColor(DesignSystem.Colors.textTertiary)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.vertical, DesignSystem.Spacing.sm + 2)
                            .background(DesignSystem.Colors.surface)
                            .cornerRadius(DesignSystem.CornerRadius.subtle + 6)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.lg)
            }
            
            Divider()
                .background(DesignSystem.Colors.divider)
            
            // Footer
            HStack {
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.oneAndHalf)
                        .background(DesignSystem.Colors.interactive)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: createTaskItem) {
                    Text("Create Task")
                        .font(DesignSystem.Typography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.background)
                        .padding(.horizontal, DesignSystem.Spacing.xl - 4)
                        .padding(.vertical, DesignSystem.Spacing.oneAndHalf)
                        .background(DesignSystem.Colors.accent)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(title.isEmpty)
                .opacity(title.isEmpty ? 0.5 : 1.0)
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
    
    private func createTaskItem() {
        var task = TaskItem(
            title: title,
            category: category,
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil,
            dueTime: hasDueTime ? dueTime : nil,
            recurringPattern: recurringPattern
        )
        
        // Add subtasks
        task.subtasks = subtasks.map { Subtask(title: $0) }
        
        taskManager.addTask(task)
        dismiss()
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
            .environmentObject(TaskManager())
    }
}