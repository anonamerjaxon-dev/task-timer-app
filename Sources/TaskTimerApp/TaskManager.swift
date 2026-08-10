import Foundation
import Combine

final class TaskManager: ObservableObject {
    // MARK: - Published Properties
    @Published var tasks: [TaskItem] = []
    @Published var categories: [Category] = []
    @Published var sessions: [PomodoroSession] = []
    @Published var plans: [Plan] = []
    
    // MARK: - Dependencies
    let storage = StorageManager.shared
    private let calendar = Calendar.current

    // Cache for computed properties to avoid repeated calculations
    private var cachedActiveTasks: [TaskItem] = []
    private var cachedCompletedTasks: [TaskItem] = []
    private var cacheValid = false
    private var tasksVersion = UUID() // Use UUID for reliable change detection

    // Recurring task management
    private var recurringTaskTimer: Timer?

    // MARK: - Computed Properties (Cached)
    var activeTasks: [TaskItem] {
        ensureCacheIsValid()
        return cachedActiveTasks
    }

    var completedTasks: [TaskItem] {
        ensureCacheIsValid()
        return cachedCompletedTasks
    }

    private func ensureCacheIsValid() {
        if !cacheValid {
            updateCache()
        }
    }
    
    var overdueTasks: [TaskItem] {
        tasks.filter { $0.isOverdue }
            .sorted { $0.priority.sortIndex < $1.priority.sortIndex }
    }
    
    var tasksDueToday: [TaskItem] {
        tasks.filter { $0.isDueToday && !$0.isCompleted }
            .sorted { $0.priority.sortIndex < $1.priority.sortIndex }
    }
    
    var activePlans: [Plan] {
        plans.filter { !$0.isCompleted }
    }
    
    var completedPlans: [Plan] {
        plans.filter { $0.isCompleted }
            .sorted { ($0.completedAt ?? Date.distantPast) > ($1.completedAt ?? Date.distantPast) }
    }
    
    var uniqueCategories: [String] {
        // Use categories array instead of scanning all tasks
        categories.map { $0.name }.sorted()
    }
    
    // MARK: - Initialization
    init() {
        loadData()
        cleanupStaleData()
        startRecurringTaskTimer()
    }
    
    // MARK: - Cache Management
    private func updateCache() {
        // Use more efficient filtering with pre-allocated capacity
        let activeCount = tasks.filter { !$0.isCompleted }.count
        let completedCount = tasks.count - activeCount

        cachedActiveTasks = tasks.filter { !$0.isCompleted }

        // Only sort completed tasks if there are any
        if completedCount > 0 {
            cachedCompletedTasks = tasks.filter { $0.isCompleted }
                .sorted { ($0.completedAt ?? Date.distantPast) > ($1.completedAt ?? Date.distantPast) }
        } else {
            cachedCompletedTasks = []
        }

        cacheValid = true
        tasksVersion = UUID() // Generate new version on cache update
    }

    func invalidateCache() {
        cacheValid = false
        tasksVersion = UUID() // Explicitly invalidate with new version
    }

    // Call this method periodically to check for new recurring task instances
    func checkForNewRecurringTasks() {
        checkAndCreateRecurringInstances()
    }

    private func startRecurringTaskTimer() {
        // Invalidate existing timer first
        stopRecurringTaskTimer()

        // Check for new recurring tasks every hour, but only if we have recurring tasks
        guard tasks.contains(where: { $0.recurringPattern != .none }) else {
            return
        }

        recurringTaskTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkForNewRecurringTasks()
            }
        }
    }

    private func stopRecurringTaskTimer() {
        recurringTaskTimer?.invalidate()
        recurringTaskTimer = nil
    }
    
    // MARK: - Data Loading
    private func loadData() {
        tasks = storage.loadTasks()
        categories = storage.loadCategories()
        sessions = storage.loadSessions()
        plans = storage.loadPlans()
        
        checkAndCreateRecurringInstances()
    }
    
    func saveAllData() {
        // Use debounced saves to minimize I/O
        storage.saveDebounced(tasks, to: .tasks)
        storage.saveDebounced(categories, to: .categories)
        storage.saveDebounced(sessions, to: .sessions)
        storage.saveDebounced(plans, to: .plans)
    }
    
    // MARK: - Data Cleanup
    private func cleanupStaleData() {
        let cutoffDate = calendar.date(byAdding: .day, value: -AppConstants.daysBeforeAutoDeleteCompletedTasks, to: Date()) ?? Date()
        
        let tasksToRemove = completedTasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            return completedAt < cutoffDate
        }
        
        if !tasksToRemove.isEmpty {
            tasks.removeAll { task in
                tasksToRemove.contains(where: { $0.id == task.id })
            }
            invalidateCache()
            saveAllData()
        }
    }
    
    // MARK: - Task Management
    func addTask(_ task: TaskItem) {
        tasks.append(task)

        // Ensure the task's category exists in the categories list
        if !categories.contains(where: { $0.name == task.category }) {
            let newCategory = Category(name: task.category)
            categories.append(newCategory)
        }

        // Restart recurring timer if this is a recurring task
        if task.recurringPattern != .none {
            startRecurringTaskTimer()
        }

        invalidateCache()
        saveAllData()
    }
    
    func updateTask(_ task: TaskItem) {
        if let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[taskIndex] = task
            invalidateCache()
            saveAllData()
        }
    }
    
    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }

        // Restart recurring timer to check if we still need it
        if task.recurringPattern != .none {
            startRecurringTaskTimer()
        }

        invalidateCache()
        saveAllData()
    }
    
    func toggleTaskCompletion(_ task: TaskItem) {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) else {
            print("TaskManager: Task not found for toggling completion: \(task.id)")
            return
        }

        // Safely toggle the completion state
        let currentState = tasks[taskIndex].isCompleted
        tasks[taskIndex].isCompleted = !currentState
        tasks[taskIndex].completedAt = tasks[taskIndex].isCompleted ? Date() : nil

        invalidateCache()

        // Restart recurring timer if this affects recurring tasks
        if task.recurringPattern != .none {
            startRecurringTaskTimer()
        }

        // Save immediately for critical operations like task completion
        do {
            try storage.saveTasks(tasks)
            print("TaskManager: Toggled task '\(tasks[taskIndex].title)' to \(tasks[taskIndex].isCompleted ? "completed" : "incomplete")")
        } catch {
            print("TaskManager: Failed to save task completion: \(error.localizedDescription)")
        }
    }

    func markTaskAsComplete(_ task: TaskItem) {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) else {
            print("TaskManager: Task not found for completion: \(task.id)")
            return
        }

        tasks[taskIndex].isCompleted = true
        tasks[taskIndex].completedAt = Date()

        invalidateCache()

        if task.recurringPattern != .none {
            startRecurringTaskTimer()
        }

        do {
            try storage.saveTasks(tasks)
            print("TaskManager: Marked task '\(tasks[taskIndex].title)' as complete")
        } catch {
            print("TaskManager: Failed to save task completion: \(error.localizedDescription)")
        }
    }
    
    func deleteTasks(withIds taskIds: [UUID]) {
        tasks.removeAll { taskIds.contains($0.id) }
        invalidateCache()
        saveAllData()
    }
    
    // MARK: - Category Management
    func addCategory(_ category: Category) {
        categories.append(category)
        saveAllData()
    }
    
    func updateCategory(_ category: Category) {
        if let categoryIndex = categories.firstIndex(where: { $0.id == category.id }) {
            categories[categoryIndex] = category
            saveAllData()
        }
    }
    
    func deleteCategory(_ category: Category) {
        categories.removeAll { $0.id == category.id }
        saveAllData()
    }
    
    func deleteCategory(named name: String) {
        categories.removeAll { $0.name == name }
        saveAllData()
    }
    
    func getCategory(named name: String) -> Category? {
        categories.first { $0.name == name }
    }
    
    func getAllCategories() -> [String] {
        return categories.map { $0.name }
    }
    
    // MARK: - Session Management
    func addSession(_ session: PomodoroSession) {
        sessions.append(session)
        saveAllData()
    }
    
    func updateSession(_ session: PomodoroSession) {
        if let sessionIndex = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[sessionIndex] = session
            saveAllData()
        }
    }
    
    func getSessions(forTaskId taskId: UUID) -> [PomodoroSession] {
        sessions.filter { $0.taskId == taskId }
    }
    
    // MARK: - Plan Management
    func addPlan(_ plan: Plan) {
        plans.append(plan)
        saveAllData()
    }
    
    func deletePlan(_ plan: Plan) {
        plans.removeAll { $0.id == plan.id }
        saveAllData()
    }
    
    func togglePlanCompletion(_ plan: Plan) {
        if let planIndex = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[planIndex].isCompleted.toggle()
            plans[planIndex].completedAt = plans[planIndex].isCompleted ? Date() : nil
            saveAllData()
        }
    }
    
    // MARK: - Filtering and Querying
    func getTasks(inCategory categoryName: String) -> [TaskItem] {
        activeTasks.filter { $0.category == categoryName }
            .sorted { $0.priority.sortIndex < $1.priority.sortIndex }
    }
    
    func getAllTasksSortedByPriority() -> [TaskItem] {
        activeTasks.sorted { $0.priority.sortIndex < $1.priority.sortIndex }
    }
    
    func searchTasks(containing searchTerm: String) -> [TaskItem] {
        let lowercasedTerm = searchTerm.lowercased()
        return tasks.filter { task in
            task.title.lowercased().contains(lowercasedTerm) ||
            task.category.lowercased().contains(lowercasedTerm)
        }
    }

    func lookupTasks(query: String? = nil, dueBefore: Date? = nil, status: String = "active") -> [TaskItem] {
        let tasks: [TaskItem]

        switch status.lowercased() {
        case "active":
            tasks = activeTasks
        case "completed":
            tasks = completedTasks
        case "all":
            tasks = self.tasks
        default:
            tasks = activeTasks
        }

        var filteredTasks = tasks

        // Filter by query if provided
        if let query = query, !query.isEmpty {
            filteredTasks = filteredTasks.filter { task in
                task.title.lowercased().contains(query.lowercased()) ||
                task.category.lowercased().contains(query.lowercased())
            }
        }

        // Filter by due date if provided
        if let dueBefore = dueBefore {
            filteredTasks = filteredTasks.filter { task in
                guard let taskDueDate = task.dueDate else { return false }
                return taskDueDate <= dueBefore
            }
        }

        return filteredTasks
    }
    
    // MARK: - Recurring Task Logic
    private func checkAndCreateRecurringInstances() {
        let currentDate = Date()
        var newTasks: [TaskItem] = []

        for existingTask in tasks where existingTask.recurringPattern != .none && !existingTask.isCompleted {
            guard shouldCreateRecurringInstance(for: existingTask, on: currentDate) else { continue }

            var newInstance = existingTask
            newInstance.id = UUID()
            newInstance.createdAt = currentDate
            newInstance.dueDate = currentDate

            if let originalDueTime = existingTask.dueTime {
                let timeComponents = calendar.dateComponents([.hour, .minute], from: originalDueTime)
                newInstance.dueTime = calendar.date(
                    bySettingHour: timeComponents.hour ?? 0,
                    minute: timeComponents.minute ?? 0,
                    second: 0,
                    of: currentDate
                )
            }

            newTasks.append(newInstance)
        }

        if !newTasks.isEmpty {
            tasks.append(contentsOf: newTasks)
            invalidateCache()
            saveAllData()
        }
    }

    private func shouldCreateRecurringInstance(for task: TaskItem, on date: Date) -> Bool {
        // Check if pattern matches for this date
        guard task.recurringPattern.shouldCreateNewInstance(for: date) else { return false }

        // Check if there's already a task for this date
        if task.shouldShowOnDate(date) {
            return false
        }

        // For daily: check if we've created an instance today
        if task.recurringPattern == .daily {
            return !hasTaskInstanceForDate(task, date: date)
        }

        // For weekly: check if we've created an instance this week
        if task.recurringPattern == .weekly {
            return !hasTaskInstanceForWeek(task, date: date)
        }

        // For specific days: check if we've created an instance on this specific day
        if [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday].contains(task.recurringPattern) {
            return !hasTaskInstanceForDate(task, date: date)
        }

        return true
    }

    private func hasTaskInstanceForDate(_ originalTask: TaskItem, date: Date) -> Bool {
        return tasks.contains { task in
            guard task.id != originalTask.id,
                  task.title == originalTask.title,
                  task.category == originalTask.category else { return false }

            return Calendar.current.isDate(task.dueDate ?? Date.distantPast, inSameDayAs: date)
        }
    }

    private func hasTaskInstanceForWeek(_ originalTask: TaskItem, date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? date

        return tasks.contains { task in
            guard task.id != originalTask.id,
                  task.title == originalTask.title,
                  task.category == originalTask.category,
                  let taskDueDate = task.dueDate else { return false }

            return taskDueDate >= startOfWeek && taskDueDate <= endOfWeek
        }
    }
    
    // MARK: - Statistics
    var totalTasksCount: Int {
        tasks.count
    }
    
    var activeTasksCount: Int {
        activeTasks.count
    }
    
    var completedTasksCount: Int {
        completedTasks.count
    }
    
    var activePlansCount: Int {
        activePlans.count
    }
    
    var completionRate: Double {
        guard totalTasksCount > 0 else { return 0.0 }
        return Double(completedTasksCount) / Double(totalTasksCount)
    }
    
    var totalSessionsCount: Int {
        sessions.filter { $0.isCompleted }.count
    }
    
    func getTask(byId taskId: UUID) -> TaskItem? {
        tasks.first { $0.id == taskId }
    }

    func getPlan(byId planId: UUID) -> Plan? {
        plans.first { $0.id == planId }
    }

    deinit {
        stopRecurringTaskTimer()
        cachedActiveTasks.removeAll()
        cachedCompletedTasks.removeAll()
    }
}