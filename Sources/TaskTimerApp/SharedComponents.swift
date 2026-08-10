import SwiftUI

// MARK: - Task Row View
struct TaskRowView: View {
    let task: TaskItem
    let onTap: () -> Void
    let onComplete: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Button(action: onComplete) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.textTertiary)
                    .font(DesignSystem.Typography.callout)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack {
                    Text(task.title)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(task.isCompleted ? DesignSystem.Colors.textTertiary : DesignSystem.Colors.textPrimary)
                        .strikethrough(task.isCompleted)

                    Spacer()

                    Circle()
                        .fill(Color.taskPriority(task.priority))
                        .frame(width: 8, height: 8)
                }

                if !task.category.isEmpty {
                    Text(task.category)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }

                if let dueDate = task.dueDate {
                    Text(formatDueDate(dueDate))
                        .font(DesignSystem.Typography.tiny)
                        .foregroundColor(dueDateColor(for: dueDate))
                }
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .font(DesignSystem.Typography.footnote)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }

    private func formatDueDate(_ date: Date) -> String {
        DateFormatter.mediumDate.string(from: date)
    }

    private func dueDateColor(for date: Date) -> Color {
        if task.isCompleted { return DesignSystem.Colors.textTertiary }
        else if date < Date() { return DesignSystem.Colors.error }
        else if Calendar.current.isDateInToday(date) { return DesignSystem.Colors.warning }
        else { return DesignSystem.Colors.textSecondary }
    }
}

// MARK: - Section Header View
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
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
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
                    .secondaryButtonStyle()

                Button("Confirm", action: confirmAction)
                    .destructiveButtonStyle()
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .fill(DesignSystem.Colors.surface)
        )
        .shadow(color: DesignSystem.Shadows.medium, radius: 8, x: 0, y: 4)
    }
}