import Foundation

// MARK: - Constants
struct AppConstants {
    static let pomodoroWorkDuration: TimeInterval = 25 * 60
    static let pomodoroBreakDuration: TimeInterval = 5 * 60
    static let daysBeforeAutoDeleteCompletedTasks: Int = 2
}

// MARK: - Priority
enum Priority: String, Codable, CaseIterable {
    case high = "high"
    case medium = "medium"
    case low = "low"
    
    var displayName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
    
    var sortIndex: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
    
    var colorName: String {
        switch self {
        case .high: return "red"
        case .medium: return "orange"
        case .low: return "green"
        }
    }
}

// MARK: - RecurringPattern
enum RecurringPattern: String, Codable, CaseIterable {
    case none = "none"
    case daily = "daily"
    case weekly = "weekly"
    case monday = "monday"
    case tuesday = "tuesday"
    case wednesday = "wednesday"
    case thursday = "thursday"
    case friday = "friday"
    case saturday = "saturday"
    case sunday = "sunday"
    
    var displayName: String {
        switch self {
        case .none: return "Never"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monday: return "Every Monday"
        case .tuesday: return "Every Tuesday"
        case .wednesday: return "Every Wednesday"
        case .thursday: return "Every Thursday"
        case .friday: return "Every Friday"
        case .saturday: return "Every Saturday"
        case .sunday: return "Every Sunday"
        }
    }
    
    func shouldCreateNewInstance(for date: Date) -> Bool {
        switch self {
        case .none:
            return false
        case .daily:
            return true
        case .weekly:
            return true
        case .monday:
            return Calendar.current.component(.weekday, from: date) == 2
        case .tuesday:
            return Calendar.current.component(.weekday, from: date) == 3
        case .wednesday:
            return Calendar.current.component(.weekday, from: date) == 4
        case .thursday:
            return Calendar.current.component(.weekday, from: date) == 5
        case .friday:
            return Calendar.current.component(.weekday, from: date) == 6
        case .saturday:
            return Calendar.current.component(.weekday, from: date) == 7
        case .sunday:
            return Calendar.current.component(.weekday, from: date) == 1
        }
    }
}

// MARK: - Subtask
struct Subtask: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    
    init(title: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
    }
}

// MARK: - TaskItem
struct TaskItem: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var category: String
    var priority: Priority
    var subtasks: [Subtask]
    var dueDate: Date?
    var dueTime: Date?
    var recurringPattern: RecurringPattern
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?
    
    init(title: String, category: String, priority: Priority = .medium, dueDate: Date? = nil, dueTime: Date? = nil, recurringPattern: RecurringPattern = .none) {
        self.id = UUID()
        self.title = title
        self.category = category
        self.priority = priority
        self.subtasks = []
        self.dueDate = dueDate
        self.dueTime = dueTime
        self.recurringPattern = recurringPattern
        self.isCompleted = false
        self.createdAt = Date()
        self.completedAt = nil
    }
    
    // MARK: - Computed Properties
    var isOverdue: Bool {
        guard !isCompleted else { return false }
        guard let dueDate else { return false }
        return dueDate < Calendar.current.startOfDay(for: Date())
    }
    
    var isDueToday: Bool {
        guard let dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }
    
    var isPastDue: Bool {
        guard !isCompleted else { return false }
        return isOverdue
    }
    
    var hasDeadline: Bool {
        return dueDate != nil
    }
    
    var completedSubtasksCount: Int {
        return subtasks.filter { $0.isCompleted }.count
    }
    
    var totalSubtasksCount: Int {
        return subtasks.count
    }
    
    var formattedDueDate: String {
        guard let dueDate = dueDate else { return "No due date" }
        
        if let dueTime = dueTime {
            return "\(DateFormatter.mediumDate.string(from: dueDate)) at \(DateFormatter.shortTime.string(from: dueTime))"
        }
        
        return DateFormatter.mediumDate.string(from: dueDate)
    }
    
    var formattedDueDateShort: String {
        guard let dueDate = dueDate else { return "" }
        return DateFormatter.shortDate.string(from: dueDate)
    }
    
    // MARK: - Helper Methods
    func shouldShowOnDate(_ date: Date) -> Bool {
        guard !isCompleted else { return false }
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDate(dueDate, inSameDayAs: date)
    }
}

// MARK: - Category
struct Category: Identifiable, Codable {
    let id: UUID
    var name: String
    var color: String
    
    init(name: String, color: String = "#FFFFFF") {
        self.id = UUID()
        self.name = name
        self.color = color
    }
    
    static let defaultCategories: [Category] = [
        Category(name: "Work"),
        Category(name: "Personal"),
        Category(name: "Study"),
        Category(name: "Health"),
        Category(name: "Other")
    ]
}


// MARK: - PomodoroSession
struct PomodoroSession: Identifiable, Codable {
    let id: UUID
    var taskId: UUID
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    var isCompleted: Bool
    
    init(taskId: UUID, duration: TimeInterval = AppConstants.pomodoroWorkDuration) {
        self.id = UUID()
        self.taskId = taskId
        self.startTime = Date()
        self.endTime = nil
        self.duration = duration
        self.isCompleted = false
    }
    
    var actualDuration: TimeInterval {
        guard let endTime = endTime else { return 0 }
        return endTime.timeIntervalSince(startTime)
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

// MARK: - Plan
struct Plan: Identifiable, Codable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?
    
    init(title: String) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.createdAt = Date()
        self.completedAt = nil
    }
    
    var formattedCreationDate: String {
        DateFormatter.shortDate.string(from: createdAt)
    }
    
    var formattedCompletionDate: String? {
        guard let completedAt = completedAt else { return nil }
        return DateFormatter.shortDate.string(from: completedAt)
    }
}


// MARK: - Dictionary Conversion Extensions
extension TaskItem {
    func toDictionary() -> [String: Any] {
        // Compact representation for token efficiency
        var dict: [String: Any] = [
            "id": id.uuidString,
            "title": title,
            "cat": category,
            "pri": priority.rawValue
        ]

        if isOverdue { dict["overdue"] = true }
        if isDueToday { dict["today"] = true }
        if let dueDate = dueDate {
            dict["due"] = ISO8601DateFormatter().string(from: dueDate)
        }

        return dict
    }
}


extension TimerState {
    var description: String {
        switch self {
        case .idle: return "idle"
        case .running: return "running"
        case .paused: return "paused"
        case .breakTime: return "break_time"
        }
    }
}