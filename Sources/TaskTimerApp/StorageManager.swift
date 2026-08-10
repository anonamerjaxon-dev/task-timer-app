import Foundation
import OSLog

// MARK: - Safe Collection Access
extension Collection {
    /// Safely access an element by index, returning nil if index is out of bounds
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Storage Configuration
enum StorageFileType: String, CaseIterable {
    case tasks = "tasks"
    case categories = "categories"
    case sessions = "sessions"
    case plans = "plans"
    
    var fileName: String {
        return "\(self.rawValue).json"
    }
}

// MARK: - Storage Errors
enum StorageError: Error, LocalizedError {
    case encodingFailed(Error)
    case writingFailed(Error)
    case readingFailed(Error)
    case decodingFailed(Error)
    case fileNotFound
    case directoryCreationFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Failed to encode data: \(error.localizedDescription)"
        case .writingFailed(let error):
            return "Failed to write to file: \(error.localizedDescription)"
        case .readingFailed(let error):
            return "Failed to read from file: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .fileNotFound:
            return "File not found"
        case .directoryCreationFailed(let error):
            return "Failed to create directory: \(error.localizedDescription)"
        }
    }
}

final class StorageManager {
    static let shared = StorageManager()
    
    // Shared background queue for all I/O operations - low priority to minimize resource usage
    private static let ioQueue = DispatchQueue.global(qos: .utility)
    
    private let fileManager: FileManager
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    private var fileCache: [StorageFileType: URL] = [:]
    private let logger = Logger(subsystem: "com.iflow.tasktimer", category: "StorageManager")
    
    // Debounce timers to prevent excessive writes
    private var pendingSaves: [StorageFileType: DispatchWorkItem] = [:]
    private let debounceDelay: TimeInterval = 0.5
    
    private var appSupportDirectory: URL {
        let bundleID = "com.iflow.tasktimer"
        let paths = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = paths.first!
        let appDirectory = appSupportURL.appendingPathComponent(bundleID, isDirectory: true)
        
        do {
            if !fileManager.fileExists(atPath: appDirectory.path) {
                try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
                logger.info("Created application support directory at \(appDirectory.path)")
            }
        } catch {
            logger.error("Failed to create directory: \(error.localizedDescription)")
        }
        
        return appDirectory
    }
    
    private init() {
        self.fileManager = FileManager.default
        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.dateEncodingStrategy = .iso8601
        // Remove prettyPrinted for better performance
        self.jsonEncoder.outputFormatting = []
        
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.dateDecodingStrategy = .iso8601
        
        preloadFileURLs()
    }
    
    // MARK: - File URL Management
    private func preloadFileURLs() {
        fileCache = [:]
        for fileType in StorageFileType.allCases {
            fileCache[fileType] = appSupportDirectory.appendingPathComponent(fileType.fileName)
        }
    }
    
    private func fileURL(for fileType: StorageFileType) -> URL {
        return fileCache[fileType] ?? appSupportDirectory.appendingPathComponent(fileType.fileName)
    }
    
    // MARK: - Generic Save Methods (Optimized)
    private func save<T: Encodable>(_ data: T, to fileType: StorageFileType) throws {
        let url = fileURL(for: fileType)

        let encodedData = try jsonEncoder.encode(data)

        do {
            try encodedData.write(to: url, options: .atomic)
            logger.debug("Successfully saved \(fileType.fileName)")
        } catch {
            logger.error("Failed to save \(fileType.fileName): \(error.localizedDescription)")

            // Attempt recovery by recreating directory
            do {
                try fileManager.createDirectory(at: url.deletingLastPathComponent(),
                                              withIntermediateDirectories: true)
                try encodedData.write(to: url, options: .atomic)
                logger.info("Recovered and saved \(fileType.fileName) after directory recreation")
            } catch {
                logger.error("Failed to recover and save \(fileType.fileName): \(error.localizedDescription)")
                throw StorageError.writingFailed(error)
            }
        }
    }
    
    // Debounced save to prevent excessive writes
    func saveDebounced<T: Encodable>(_ data: T, to fileType: StorageFileType) {
        // Cancel any pending save for this file type
        pendingSaves[fileType]?.cancel()

        // Encode the data immediately to avoid capture issues
        guard let encodedData = try? jsonEncoder.encode(data) else {
            logger.error("Failed to encode \(fileType.fileName)")
            return
        }

        // Create new debounced save
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            do {
                let url = self.fileURL(for: fileType)
                try encodedData.write(to: url, options: .atomic)
                self.logger.debug("Successfully saved \(fileType.fileName)")
            } catch {
                self.logger.error("Failed to save \(fileType.fileName): \(error.localizedDescription)")
            }

            // Remove from pending saves
            self.pendingSaves.removeValue(forKey: fileType)
        }

        pendingSaves[fileType] = workItem
        Self.ioQueue.asyncAfter(deadline: .now() + debounceDelay, execute: workItem)
    }
    
    private func load<T: Decodable>(_ type: T.Type, from fileType: StorageFileType, defaultValue: [T] = []) -> [T] {
        let url = fileURL(for: fileType)
        
        guard fileManager.fileExists(atPath: url.path) else {
            return defaultValue
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try jsonDecoder.decode([T].self, from: data)
            return decoded
        } catch {
            logger.error("Failed to load \(fileType.fileName): \(error.localizedDescription)")
            return defaultValue
        }
    }
    
    // MARK: - Tasks
    func saveTasks(_ tasks: [TaskItem]) throws {
        try save(tasks, to: .tasks)
    }
    
    func loadTasks() -> [TaskItem] {
        load(TaskItem.self, from: .tasks)
    }
    
    // MARK: - Categories
    func saveCategories(_ categories: [Category]) throws {
        try save(categories, to: .categories)
    }
    
    func loadCategories() -> [Category] {
        load(Category.self, from: .categories, defaultValue: Category.defaultCategories)
    }
    
    // MARK: - Sessions
    func saveSessions(_ sessions: [PomodoroSession]) throws {
        try save(sessions, to: .sessions)
    }
    
    func loadSessions() -> [PomodoroSession] {
        load(PomodoroSession.self, from: .sessions)
    }
    
    // MARK: - Plans
    func savePlans(_ plans: [Plan]) throws {
        try save(plans, to: .plans)
    }
    
    func loadPlans() -> [Plan] {
        load(Plan.self, from: .plans)
    }
    
    // MARK: - File Management
    func clearAllData() {
        for fileType in StorageFileType.allCases {
            let url = fileURL(for: fileType)
            do {
                try fileManager.removeItem(at: url)
                logger.info("Deleted \(fileType.fileName)")
            } catch {
                logger.error("Failed to delete \(fileType.fileName): \(error.localizedDescription)")
            }
        }
    }
    
    func exportData(tasks: [TaskItem], categories: [Category], sessions: [PomodoroSession], plans: [Plan]) -> URL? {
        let exportURL = appSupportDirectory.appendingPathComponent("export_\(Date().timeIntervalSince1970).json")
        
        let exportData: [String: Any] = [
            "tasks": (try? jsonEncoder.encode(tasks)) as Any,
            "categories": (try? jsonEncoder.encode(categories)) as Any,
            "sessions": (try? jsonEncoder.encode(sessions)) as Any,
            "plans": (try? jsonEncoder.encode(plans)) as Any
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: exportData, options: [])
            try data.write(to: exportURL, options: .atomic)
            return exportURL
        } catch {
            print("StorageManager: Failed to export data - \(error.localizedDescription)")
            return nil
        }
    }
    
    // Flush any pending saves (call before app termination)
    func flushPendingSaves() {
        // Cancel all pending saves and execute immediately
        for workItem in pendingSaves.values {
            workItem.cancel()
            workItem.perform()
        }
        pendingSaves.removeAll()
    }

    // Clean up any pending saves without executing (for memory cleanup)
    func cancelPendingSaves() {
        pendingSaves.values.forEach { $0.cancel() }
        pendingSaves.removeAll()
    }
}