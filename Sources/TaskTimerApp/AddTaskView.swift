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
                        
                        TextField("Enter task title", text: $title)
                            .focused($focusedField, equals: .title)
                            .textFieldStyle(.plain)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                            .onTapGesture {
                                ensureWindowFocus()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    focusedField = .title
                                }
                            }
                    }
                    
                    // Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 12) {
                            TextField("Enter category", text: $category)
                                .focused($focusedField, equals: .category)
                                .textFieldStyle(.plain)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
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
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Priority
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Priority")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Picker("Priority", selection: $priority) {
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
                    
                    // Due Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Due Date")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        HStack {
                            Toggle("", isOn: $hasDueDate)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                            
                            Spacer()
                            
                            if hasDueDate {
                                DatePicker("", selection: $dueDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .colorScheme(.dark)
                            } else {
                                Text("No due date")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }
                    
                    // Due Time
                    if hasDueDate {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Due Time")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            HStack {
                                Toggle("", isOn: $hasDueTime)
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                                
                                Spacer()
                                
                                if hasDueTime {
                                    DatePicker("", selection: $dueTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .colorScheme(.dark)
                                } else {
                                    Text("No specific time")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
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
                        
                        Picker("Recurring", selection: $recurringPattern) {
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
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Subtasks")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        // Add new subtask
                        HStack(spacing: 8) {
                            TextField("Add subtask", text: $newSubtask)
                                .focused($focusedField, equals: .subtask)
                                .textFieldStyle(.plain)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
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
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                        }
                        
                        // List of subtasks
                        ForEach(Array(subtasks.enumerated()), id: \.offset) { index, subtask in
                            HStack {
                                Text(subtask)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: {
                                    subtasks.remove(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Footer
            HStack {
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: createTaskItem) {
                    Text("Create Task")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(title.isEmpty)
                .opacity(title.isEmpty ? 0.5 : 1.0)
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