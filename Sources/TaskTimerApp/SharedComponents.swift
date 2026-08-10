import SwiftUI

// MARK: - Priority Badge
struct PriorityBadge: View {
    let priority: Priority

    var body: some View {
        Circle()
            .fill(priorityColor)
            .frame(width: 8, height: 8)
    }

    private var priorityColor: Color {
        switch priority {
        case .high: return DesignSystem.Colors.priorityHigh
        case .medium: return DesignSystem.Colors.priorityMedium
        case .low: return DesignSystem.Colors.priorityLow
        }
    }
}

// MARK: - Task Row View
struct TaskRowView: View {
    let task: TaskItem
    let onTap: () -> Void
    let onComplete: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Completion button
            Button(action: onComplete) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.textTertiary)
                    .font(DesignSystem.Typography.callout)
            }
            .buttonStyle(PlainButtonStyle())

            // Task content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack {
                    Text(task.title)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(task.isCompleted ? DesignSystem.Colors.textTertiary : DesignSystem.Colors.textPrimary)
                        .strikethrough(task.isCompleted)

                    Spacer()

                    PriorityBadge(priority: task.priority)
                }

                if !task.category.isEmpty {
                    Text(task.category)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }

                if let dueDate = task.dueDate {
                    Text(formatDueDate(dueDate))
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(dueDateColor(for: dueDate))
                }
            }

            Spacer()

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .font(DesignSystem.Typography.footnote)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }

    private func formatDueDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func dueDateColor(for date: Date) -> Color {
        if task.isCompleted {
            return DesignSystem.Colors.textTertiary
        } else if date < Date() {
            return DesignSystem.Colors.error
        } else if Calendar.current.isDateInToday(date) {
            return DesignSystem.Colors.warning
        } else {
            return DesignSystem.Colors.textSecondary
        }
    }
}

// MARK: - Section Header
struct SectionHeaderView: View {
    let title: String
    let action: (() -> Void)?
    let actionTitle: String?

    init(_ title: String, action: (() -> Void)? = nil, actionTitle: String? = nil) {
        self.title = title
        self.action = action
        self.actionTitle = actionTitle
    }

    var body: some View {
        HStack {
            Text(title)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            Spacer()

            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(DesignSystem.Typography.footnote)
                        .foregroundColor(DesignSystem.Colors.accent)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(DesignSystem.Colors.textTertiary)

            Text(title)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textSecondary)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(DesignSystem.Spacing.xl)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.accent))

            Text("Loading...")
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
    }
}

// MARK: - Confirmation Dialog
struct ConfirmationDialog: View {
    let title: String
    let message: String
    let confirmAction: () -> Void
    let cancelAction: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text(title)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            Text(message)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: DesignSystem.Spacing.md) {
                Button("Cancel", action: cancelAction)
                    .minimalButtonStyle(.secondary)

                Button("Confirm", action: confirmAction)
                    .minimalButtonStyle(.destructive)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .shadow(color: DesignSystem.Shadows.medium, radius: 8, x: 0, y: 4)
    }
}
