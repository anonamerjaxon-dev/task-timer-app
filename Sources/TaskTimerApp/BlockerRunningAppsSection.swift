import SwiftUI

struct RunningAppsSection: View {
    @EnvironmentObject var appBlockerManager: AppBlockerManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack(spacing: DesignSystem.Spacing.oneAndHalf) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(DesignSystem.Colors.textTertiary)

                TextField("Search running apps...", text: $appBlockerManager.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                if !appBlockerManager.searchText.isEmpty {
                    Button(action: {
                        appBlockerManager.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Button(action: {
                    appBlockerManager.refreshRunningApps()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(DesignSystem.Colors.timerActive)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm + 2)
            .background(DesignSystem.Colors.interactive)
            .cornerRadius(DesignSystem.CornerRadius.subtle + 6)
            .padding(.horizontal, DesignSystem.Spacing.twoAndHalf)
            .padding(.top, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.oneAndHalf)
            
            // Running Apps List
            if appBlockerManager.filteredRunningApps.isEmpty {
                VStack(spacing: DesignSystem.Spacing.oneAndHalf) {
                    Image(systemName: "app.dashed")
                        .font(.system(size: 48))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    
                    Text("No running apps found")
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(appBlockerManager.filteredRunningApps) { app in
                            RunningAppRow(app: app)
                                .padding(.horizontal, DesignSystem.Spacing.twoAndHalf)
                                .padding(.vertical, DesignSystem.Spacing.sm)
                        }
                    }
                }
            }
        }
    }
}

struct RunningAppRow: View {
    let app: RunningApp
    @EnvironmentObject var appBlockerManager: AppBlockerManager
    
    var isBlocked: Bool {
        appBlockerManager.blockedApps.contains { $0.bundleID == app.bundleID && $0.isBlocked }
    }
    
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
                
                Text("PID: \(app.pid)")
                    .font(DesignSystem.Typography.tiny)
                    .foregroundColor(DesignSystem.Colors.textQuaternary)
            }
            
            Spacer()
            
            // Block/Unblock Button
            Button(action: {
                if isBlocked {
                    appBlockerManager.unblockApp(app.bundleID)
                } else {
                    appBlockerManager.blockApp(app.bundleID)
                }
            }) {
                Image(systemName: isBlocked ? "lock.open.fill" : "lock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isBlocked ? DesignSystem.Colors.success : DesignSystem.Colors.error)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.oneAndHalf)
        .background(isBlocked ? DesignSystem.Colors.success.opacity(0.1) : DesignSystem.Colors.interactive)
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }
}