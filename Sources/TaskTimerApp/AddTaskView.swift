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
        case title, category, subtask
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
                    fieldGroup(label: "Title") {
                        TextField("Enter task title", text: $title)
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

                    // Category
                    fieldGroup(label: "Category") {
                        HStack(spacing: 10) {
                            TextField("Enter category", text: $category)
                                .focused($focusedField, equals: .category)
                                .textFieldStyle(.plain)
                                .font(DesignSystem.Typography.subheadline)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(DesignSystem.Colors.surfaceHigh)
                                )

                            Picker("", selection: $category) {
                                Text("Select...").tag("")
                                ForEach(taskManager.getAllCategories(), id: \.self) { cat in
                                    Text(cat).tag(cat)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 120)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(DesignSystem.Colors.surfaceHigh)
                            )
                        }
                    }

                    // Priority
                    fieldGroup(label: "Priority") {
                        Picker("Priority", selection: $priority) {
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

                    // Due Date
                    fieldGroup(label: "Due Date") {
                        HStack {
                            Toggle("", isOn: $hasDueDate)
                                .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.accent))

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
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(DesignSystem.Colors.surfaceHigh)
                        )
                    }

                    // Due Time
                    if hasDueDate {
                        fieldGroup(label: "Due Time") {
                            HStack {
                                Toggle("", isOn: $hasDueTime)
                                    .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.accent))

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
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(DesignSystem.Colors.surfaceHigh)
                            )
                        }
                    }

                    // Recurring
                    fieldGroup(label: "Recurring") {
                        Picker("Recurring", selection: $recurringPattern) {
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
                    fieldGroup(label: "Subtasks") {
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                TextField("Add subtask", text: $newSubtask)
                                    .focused($focusedField, equals: .subtask)
                                    .textFieldStyle(.plain)
                                    .font(DesignSystem.Typography.subheadline)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(DesignSystem.Colors.surfaceHigh)
                                    )
                                    .onSubmit {
                                        if !newSubtask.isEmpty {
                                            subtasks.append(newSubtask)
                                            newSubtask = ""
                                        }
                                    }

                                Button(action: {
                                    if !newSubtask.isEmpty {
                                        subtasks.append(newSubtask)
                                        newSubtask = ""
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
                            }

                            ForEach(Array(subtasks.enumerated()), id: \.offset) { index, subtask in
                                HStack {
                                    Text(subtask)
                                        .font(DesignSystem.Typography.subheadline)
                                        .foregroundColor(DesignSystem.Colors.textPrimary)

                                    Spacer()

                                    Button(action: { subtasks.remove(at: index) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(DesignSystem.Colors.textTertiary)
                                    }
                                    .buttonStyle(.plain)
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
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }

            Divider()
                .background(DesignSystem.Colors.divider)

            // Footer
            HStack {
                Button("Cancel") { dismiss() }
                    .secondaryButtonStyle()

                Spacer()

                Button("Create Task") { createTaskItem() }
                    .primaryButtonStyle()
                    .disabled(title.isEmpty)
                    .opacity(title.isEmpty ? 0.5 : 1.0)
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
            Text(label.uppercased())
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textTertiary)
            content()
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
        task.subtasks = subtasks.map { Subtask(title: $0) }
        taskManager.addTask(task)
        dismiss()
    }
}

#Preview {
    AddTaskView()
        .environmentObject(TaskManager())
}