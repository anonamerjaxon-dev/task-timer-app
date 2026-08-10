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
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(DesignSystem.Colors.surfaceHigh))
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            // Blocked Apps List
            if appBlockerManager.currentlyBlockedApps.isEmpty {
                EmptyState(
                    icon: "lock.open",
                    title: "No Apps Blocked",
                    message: "Add apps to block from the Running Apps tab"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(appBlockerManager.currentlyBlockedApps) { app in
                            BlockedAppRowV2(app: app)
                                .padding(.horizontal, 24)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}

struct BlockedAppRowV2: View {
    let app: BlockedApp
    @EnvironmentObject var appBlockerManager: AppBlockerManager

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

                    if let blockedAt = app.blockedAt {
                        Text("·")
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                        Text(timeAgoString(from: blockedAt))
                            .font(DesignSystem.Typography.tiny)
                            .foregroundColor(DesignSystem.Colors.error)
                    }
                }
            }

            Spacer()

            // Unblock Button
            Button(action: {
                appBlockerManager.unblockApp(app.bundleID)
            }) {
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.success)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(DesignSystem.Colors.successMuted))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(DesignSystem.Colors.errorMuted)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(DesignSystem.Colors.error.opacity(0.15), lineWidth: 1)
        )
    }

    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "just now" }
        else if interval < 3600 { return "\(Int(interval / 60))m ago" }
        else if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        else { return "\(Int(interval / 86400))d ago" }
    }
}