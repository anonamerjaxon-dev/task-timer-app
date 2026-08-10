import SwiftUI

struct RunningAppsSection: View {
    @EnvironmentObject var appBlockerManager: AppBlockerManager

    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(DesignSystem.Colors.textTertiary)

                TextField("Search running apps...", text: $appBlockerManager.searchText)
                    .textFieldStyle(.plain)
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                if !appBlockerManager.searchText.isEmpty {
                    Button(action: { appBlockerManager.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                    .buttonStyle(.plain)
                }

                Button(action: { appBlockerManager.refreshRunningApps() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.accent)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(DesignSystem.Colors.surfaceHigh)
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 12)

            // Running Apps List
            if appBlockerManager.filteredRunningApps.isEmpty {
                EmptyState(
                    icon: "app.dashed",
                    title: "No Running Apps",
                    message: "No running applications found"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(appBlockerManager.filteredRunningApps) { app in
                            RunningAppRowV2(app: app)
                                .padding(.horizontal, 24)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}

struct RunningAppRowV2: View {
    let app: RunningApp
    @EnvironmentObject var appBlockerManager: AppBlockerManager

    var isBlocked: Bool {
        appBlockerManager.blockedApps.contains { $0.bundleID == app.bundleID && $0.isBlocked }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 36, height: 36)
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(DesignSystem.Colors.surfaceHighest)
                    .frame(width: 36, height: 36)
            }

            // App Info
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                HStack(spacing: 6) {
                    Text(app.bundleID)
                        .font(DesignSystem.Typography.tiny)
                        .foregroundColor(DesignSystem.Colors.textTertiary)

                    Text("·")
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    Text("PID: \(app.pid)")
                        .font(DesignSystem.Typography.tiny)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
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
                    .font(.system(size: 14))
                    .foregroundColor(isBlocked ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(isBlocked ? DesignSystem.Colors.successMuted : DesignSystem.Colors.errorMuted)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isBlocked ? DesignSystem.Colors.successMuted.opacity(0.5) : DesignSystem.Colors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(DesignSystem.Colors.borderSubtle, lineWidth: 1)
        )
    }
}