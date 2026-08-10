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
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(Color.black)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        TextField("Enter task title", text: $editingTask.title)
                            .focused($focusedField, equals: .title)
                            .textFieldStyle(.plain)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                            .onTapGesture {
                                focusedField = .title
                                ensureWindowFocus()
                            }
                    }
                    
                    // Info Grid
                    HStack(spacing: 16) {
                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            Picker("Category", selection: $editingTask.category) {
                                ForEach(taskManager.getAllCategories(), id: \.self) { cat in
                                    Text(cat).tag(cat)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                        }
                        
                        // Priority
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            Picker("Priority", selection: $editingTask.priority) {
                                ForEach(Priority.allCases, id: \.self) { prio in
                                    Text(prio.displayName).tag(prio)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Due Date & Time
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Due Date")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        if let _ = editingTask.dueDate {
                            HStack {
                                Text(editingTask.formattedDueDate)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: {
                                    editingTask.dueDate = nil
                                    editingTask.dueTime = nil
                                }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 14))
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                        } else {
                            Button(action: {
                                editingTask.dueDate = Date()
                            }) {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text("Set due date")
                                }
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Recurring
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recurring")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Picker("Recurring", selection: $editingTask.recurringPattern) {
                            ForEach(RecurringPattern.allCases, id: \.self) { pattern in
                                Text(pattern.displayName).tag(pattern)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }
                    
                    // Subtasks
                    if !editingTask.subtasks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Subtasks")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(editingTask.subtasks) { subtask in
                                    HStack {
                                        Button(action: {
                                            toggleSubtask(subtask)
                                        }) {
                                            Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 20))
                                                .foregroundColor(subtask.isCompleted ? .green : .gray)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        Text(subtask.title)
                                            .font(.system(size: 14))
                                            .foregroundColor(subtask.isCompleted ? .gray : .white)
                                            .strikethrough(subtask.isCompleted)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(Color.gray.opacity(0.15))
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    // Status
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                taskManager.toggleTaskCompletion(task)
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: editingTask.isCompleted ? "checkmark.circle.fill" : "circle")
                                    Text(editingTask.isCompleted ? "Completed" : "Mark as Complete")
                                }
                                .font(.system(size: 14))
                                .foregroundColor(editingTask.isCompleted ? .green : .white)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                            
                            if !editingTask.isCompleted {
                                Button(action: {
                                    timerManager.markTaskAsComplete(task)
                                    dismiss()
                                }) {
                                    HStack {
                                        Image(systemName: "checkmark.shield.fill")
                                        Text("Quick Complete")
                                    }
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
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
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Footer
            HStack {
                Spacer()
                
                Button(action: saveChanges) {
                    Text("Save Changes")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color.black)
        }
        .frame(width: 500, height: 600)
        .background(Color.black)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                ensureWindowFocus()
                focusedField = .title
            }
        }
    }
    
    private func ensureWindowFocus() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.keyWindow {
            window.makeKey()
            window.orderFrontRegardless()
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