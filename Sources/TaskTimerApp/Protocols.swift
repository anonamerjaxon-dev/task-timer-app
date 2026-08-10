import Foundation

// MARK: - Storage Protocol
protocol StorageManagerProtocol {
    func loadTasks() -> [TaskItem]
    func loadCategories() -> [Category]
    func loadSessions() -> [PomodoroSession]
    func loadPlans() -> [Plan]
    
    func saveTasks(_ tasks: [TaskItem]) throws
    func saveCategories(_ categories: [Category]) throws
    func saveSessions(_ sessions: [PomodoroSession]) throws
    func savePlans(_ plans: [Plan]) throws
}

// MARK: - Timer Manager Protocol
protocol TimerManagerProtocol {
    var state: TimerState { get }
    var currentTask: TaskItem? { get }
    var remainingTime: TimeInterval { get }
    var isTimerActive: Bool { get }
    
    func startTimer(for task: TaskItem)
    func pauseTimer()
    func resumeTimer()
    func stopTimer()
}

// MARK: - Task Manager Protocol
protocol TaskManagerProtocol {
    var tasks: [TaskItem] { get }
    var categories: [Category] { get }
    var sessions: [PomodoroSession] { get }
    var plans: [Plan] { get }

    func addTask(_ task: TaskItem)
    func updateTask(_ task: TaskItem)
    func deleteTask(_ task: TaskItem)

    func addCategory(_ category: Category)
    func deleteCategory(_ category: Category)

    func addSession(_ session: PomodoroSession)

    func addPlan(_ plan: Plan)
    func deletePlan(_ plan: Plan)
}

// MARK: - App Blocker Protocol
protocol AppBlockerManagerProtocol {
    var blockedApps: [BlockedApp] { get }
    var runningApps: [RunningApp] { get }
    
    func blockApp(_ app: RunningApp)
    func unblockApp(_ app: BlockedApp)
    func refreshRunningApps()
}

// MARK: - Conformances
extension TimerManager: TimerManagerProtocol {}

extension TaskManager: TaskManagerProtocol {}
