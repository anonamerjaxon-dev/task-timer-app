import SwiftUI

struct BlockerView: View {
    @EnvironmentObject var appBlockerManager: AppBlockerManager
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Tab bar
            HStack(spacing: 0) {
                BlockerTabButtonV2(title: "Block List", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                BlockerTabButtonV2(title: "Running Apps", isSelected: selectedTab == 1) {
                    selectedTab = 1
                    appBlockerManager.refreshRunningApps()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 4)

            // Content
            Group {
                if selectedTab == 0 {
                    BlockSection()
                } else {
                    RunningAppsSection()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(DesignSystem.Colors.background)
        .onAppear {
            appBlockerManager.refreshRunningApps()
        }
    }

    var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Block")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Text("Manage blocked apps")
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
}

struct BlockerTabButtonV2: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Typography.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(isSelected ? DesignSystem.Colors.accent : Color.clear)
                            .frame(height: 2)
                            .cornerRadius(1)
                    }
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}