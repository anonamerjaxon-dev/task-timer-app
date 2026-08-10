import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Date Extensions
extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
}

// MARK: - String Extensions
extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isNotEmpty: Bool {
        !isEmpty
    }

    func truncated(to length: Int, trailing: String = "...") -> String {
        if count <= length {
            return self
        }
        return String(prefix(length)) + trailing
    }
}

// MARK: - Array Extensions
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }

    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Array where Element: Identifiable {
    mutating func removeFirst(where predicate: (Element) -> Bool) {
        if let index = firstIndex(where: predicate) {
            remove(at: index)
        }
    }

    func first(where predicate: (Element) -> Bool) -> Element? {
        return firstIndex(where: predicate).map { self[$0] }
    }
}

// MARK: - Color Extensions
extension Color {
    static func taskPriority(_ priority: Priority) -> Color {
        switch priority {
        case .high: return DesignSystem.Colors.priorityHigh
        case .medium: return DesignSystem.Colors.priorityMedium
        case .low: return DesignSystem.Colors.priorityLow
        }
    }

    static func taskStatus(_ status: TaskStatus) -> Color {
        switch status {
        case .active: return DesignSystem.Colors.textPrimary
        case .completed: return DesignSystem.Colors.success
        case .overdue: return DesignSystem.Colors.error
        case .dueToday: return DesignSystem.Colors.warning
        }
    }
}

// MARK: - View Extensions
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    #if canImport(UIKit)
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        onTapGesture {
            let impactFeedback = UIImpactFeedbackGenerator(style: style)
            impactFeedback.impactOccurred()
        }
    }
    #endif
}

// MARK: - Timer State
enum TimerState: Equatable {
    case idle
    case running
    case paused
    case breakTime

    var isRunning: Bool {
        self == .running
    }

    var isPaused: Bool {
        self == .paused
    }

    var isBreak: Bool {
        self == .breakTime
    }

    var displayName: String {
        switch self {
        case .idle: return "Ready"
        case .running: return "Focus"
        case .paused: return "Paused"
        case .breakTime: return "Break"
        }
    }
}

// MARK: - Task Status
enum TaskStatus {
    case active
    case completed
    case overdue
    case dueToday
}

// MARK: - Sort Options
enum SortOption: String, CaseIterable {
    case priority = "priority"
    case dueDate = "dueDate"
    case title = "title"
    case category = "category"
    case created = "created"

    var displayName: String {
        switch self {
        case .priority: return "Priority"
        case .dueDate: return "Due Date"
        case .title: return "Title"
        case .category: return "Category"
        case .created: return "Created"
        }
    }
}

// MARK: - Filter Options
enum FilterOption: String, CaseIterable {
    case all = "all"
    case active = "active"
    case completed = "completed"
    case overdue = "overdue"
    case dueToday = "dueToday"

    var displayName: String {
        switch self {
        case .all: return "All"
        case .active: return "Active"
        case .completed: return "Completed"
        case .overdue: return "Overdue"
        case .dueToday: return "Due Today"
        }
    }
}
