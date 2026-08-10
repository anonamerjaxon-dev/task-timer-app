import Foundation
import Combine

// MARK: - Timer Notifications
extension Notification.Name {
    static let timerDidStart = Notification.Name("timerDidStart")
    static let timerDidStop = Notification.Name("timerDidStop")
    static let timerDidComplete = Notification.Name("timerDidComplete")
    static let timerDidPause = Notification.Name("timerDidPause")
    static let timerDidResume = Notification.Name("timerDidResume")
}

// MARK: - Timer Manager
final class TimerManager: ObservableObject {
    // MARK: - Published Properties
    @Published var state: TimerState = .idle
    @Published var currentTask: TaskItem?
    @Published var remainingTime: TimeInterval = AppConstants.pomodoroWorkDuration
    @Published var elapsedSessionTime: TimeInterval = 0
    
    // MARK: - Configuration
    private let workSessionDuration: TimeInterval
    private let breakSessionDuration: TimeInterval
    
    // MARK: - Internal State
    private var timerSource: DispatchSourceTimer?
    private var startTime: Date?
    private var taskManager: TaskManager
    
    // Use a shared queue for timer to minimize thread usage
    private static let timerQueue = DispatchQueue(label: "com.iflow.tasktimer.timer", qos: .userInitiated)
    
    // MARK: - Computed Properties
    var isTimerActive: Bool {
        state.isRunning || state.isPaused
    }
    
    var isWorkSession: Bool {
        state == .running
    }
    
    var isBreakSession: Bool {
        state == .breakTime
    }
    
    var formattedRemainingTime: String {
        formatTime(remainingTime)
    }
    
    var formattedElapsedTime: String {
        formatTime(elapsedSessionTime)
    }
    
    var sessionProgress: Double {
        switch state {
        case .running:
            return 1.0 - (remainingTime / workSessionDuration)
        case .breakTime:
            return 1.0 - (remainingTime / breakSessionDuration)
        default:
            return 0.0
        }
    }
    
    var currentSessionDuration: TimeInterval {
        switch state {
        case .running:
            return workSessionDuration
        case .breakTime:
            return breakSessionDuration
        default:
            return 0
        }
    }
    
    // MARK: - Initialization
    init(taskManager: TaskManager) {
        self.taskManager = taskManager
        self.workSessionDuration = AppConstants.pomodoroWorkDuration
        self.breakSessionDuration = AppConstants.pomodoroBreakDuration
        self.remainingTime = workSessionDuration
    }

    // MARK: - Timer Control Methods
    func startTimer(for task: TaskItem) {
        guard !isTimerActive else { return }
        
        currentTask = task
        state = .running
        remainingTime = workSessionDuration
        elapsedSessionTime = 0
        startTime = Date()
        
        startTimerSource()
        NotificationCenter.default.post(name: .timerDidStart, object: nil)
    }
    
    func pauseTimer() {
        guard state == .running else { return }
        
        state = .paused
        stopTimerSource()
        NotificationCenter.default.post(name: .timerDidPause, object: nil)
    }
    
    func resumeTimer() {
        guard state == .paused else { return }
        
        state = .running
        startTimerSource()
        NotificationCenter.default.post(name: .timerDidResume, object: nil)
    }
    
    func stopTimer() {
        guard isTimerActive else { return }
        
        stopTimerSource()
        
        if state == .running && elapsedSessionTime > 0 {
            if let task = currentTask {
                savePomodoroSession(for: task)
            }
        }
        
        resetTimerState()
        NotificationCenter.default.post(name: .timerDidStop, object: nil)
    }
    
    func skipToBreak() {
        guard state == .running else { return }
        
        if let task = currentTask {
            savePomodoroSession(for: task)
        }
        
        startBreakSession()
    }
    
    // MARK: - Session Management
    private func startBreakSession() {
        state = .breakTime
        remainingTime = breakSessionDuration
        startTimerSource()
    }
    
    private func savePomodoroSession(for task: TaskItem) {
        let session = PomodoroSession(
            taskId: task.id,
            duration: elapsedSessionTime
        )
        var completedSession = session
        completedSession.endTime = Date()
        completedSession.isCompleted = true
        taskManager.addSession(completedSession)
        
        NotificationCenter.default.post(name: .timerDidComplete, object: nil)
    }
    
    // MARK: - Timer Operations (Optimized with DispatchSource)
    private func startTimerSource() {
        stopTimerSource()

        timerSource = DispatchSource.makeTimerSource(queue: Self.timerQueue)
        // Use a more efficient repeating interval with leeway
        timerSource?.schedule(deadline: .now(), repeating: 1.0, leeway: .milliseconds(100))

        timerSource?.setEventHandler { [weak self] in
            guard let self = self else { return }

            // Batch UI updates to reduce main thread pressure
            DispatchQueue.main.async {
                self.processTimerTick()
            }
        }

        timerSource?.resume()
    }
    
    private func stopTimerSource() {
        timerSource?.cancel()
        timerSource = nil

        // Clear reference to prevent retain cycles
        startTime = nil
    }
    
    private func processTimerTick() {
        remainingTime -= 1
        elapsedSessionTime += 1
        
        if remainingTime <= 0 {
            handleTimerCompletion()
        }
    }
    
    private func handleTimerCompletion() {
        stopTimerSource()
        
        switch state {
        case .running:
            completeWorkSession()
        case .breakTime:
            completeBreakSession()
        default:
            break
        }
    }
    
    private func completeWorkSession() {
        if let task = currentTask {
            savePomodoroSession(for: task)
            startBreakSession()
        } else {
            resetTimerState()
        }
    }
    
    private func completeBreakSession() {
        resetTimerState()
    }
    
    private func resetTimerState() {
        state = .idle
        currentTask = nil
        remainingTime = workSessionDuration
        elapsedSessionTime = 0
        startTime = nil
    }
    
    // MARK: - Formatting Helpers
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Quick Actions
    func markTaskAsComplete(_ task: TaskItem) {
        guard let taskIndex = taskManager.tasks.firstIndex(where: { $0.id == task.id }) else {
            print("TimerManager: Task not found for completion: \(task.id)")
            return
        }

        taskManager.tasks[taskIndex].isCompleted = true
        taskManager.tasks[taskIndex].completedAt = Date()

        // Save immediately for critical operations
        taskManager.invalidateCache()
        do {
            try StorageManager.shared.saveTasks(taskManager.tasks)
            print("TimerManager: Marked task '\(taskManager.tasks[taskIndex].title)' as complete")
        } catch {
            print("TimerManager: Failed to save task completion: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Cleanup
    deinit {
        stopTimerSource()
    }
}