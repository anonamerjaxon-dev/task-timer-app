import SwiftUI

struct BlockSection: View {
    @EnvironmentObject var appBlockerManager: AppBlockerManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Blocked Applications")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                if appBlockerManager.isAnyAppBlocked {
                    Text("\(appBlockerManager.currentlyBlockedApps.count) blocked")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.twoAndHalf)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.surface)
            
            // Blocked Apps List
            VStack(spacing: 0) {
                if appBlockerManager.currentlyBlockedApps.isEmpty {
                    VStack(spacing: DesignSystem.Spacing.oneAndHalf) {
                        Image(systemName: "lock.open")
                            .font(.system(size: 48))
                            .foregroundColor(DesignSystem.Colors.textTertiary)

                        Text("No apps blocked")
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(DesignSystem.Colors.textTertiary)

                        Text("Add apps to block from the Running Apps tab")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textQuaternary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(appBlockerManager.currentlyBlockedApps) { app in
                                BlockedAppRow(app: app)
                                    .padding(.horizontal, DesignSystem.Spacing.twoAndHalf)
                                    .padding(.vertical, DesignSystem.Spacing.sm)
                            }
                        }
                    }
                }

                // Unclosable Mode Toggle
                VStack(spacing: DesignSystem.Spacing.oneAndHalf) {
                    Divider()
                        .background(DesignSystem.Colors.divider)

                    HStack {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text("Unclosable Mode")
                                .font(DesignSystem.Typography.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(DesignSystem.Colors.textPrimary)

                            Text("App reappears instead of quitting")
                                .font(DesignSystem.Typography.tiny)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { appBlockerManager.isUnclosableMode },
                            set: { _ in appBlockerManager.toggleUnclosableMode() }
                        ))
                        .toggleStyle(SwitchToggleStyle())
                    }
                    .padding(.horizontal, DesignSystem.Spacing.twoAndHalf)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.surface)
                }
            }
        }
    }
}

struct BlockedAppRow: View {
    let app: BlockedApp
    @EnvironmentObject var appBlockerManager: AppBlockerManager
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Icon
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(DesignSystem.CornerRadius.small)
            } else {
                Rectangle()
                    .fill(DesignSystem.Colors.interactiveHover)
                    .frame(width: 40, height: 40)
                    .cornerRadius(DesignSystem.CornerRadius.small)
            }
            
            // App Info
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(app.name)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(app.bundleID)
                    .font(DesignSystem.Typography.tiny)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                
                if let blockedAt = app.blockedAt {
                    Text("Blocked \(timeAgoString(from: blockedAt))")
                        .font(DesignSystem.Typography.tiny)
                        .foregroundColor(DesignSystem.Colors.error)
                }
            }
            
            Spacer()
            
            // Unblock Button
            Button(action: {
                appBlockerManager.unblockApp(app.bundleID)
            }) {
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 20))
                    .foregroundColor(DesignSystem.Colors.success)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.oneAndHalf)
        .background(DesignSystem.Colors.error.opacity(0.1))
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h ago"
        } else {
            return "\(Int(interval / 86400))d ago"
        }
    }
}