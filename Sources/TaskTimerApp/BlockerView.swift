import SwiftUI

struct BlockerView: View {
    @EnvironmentObject var appBlockerManager: AppBlockerManager
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Tab Bar
            HStack(spacing: 0) {
                BlockerTabButton(title: "Block", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                BlockerTabButton(title: "Running Apps", isSelected: selectedTab == 1) {
                    selectedTab = 1
                    appBlockerManager.refreshRunningApps()
                }
            }
            .background(DesignSystem.Colors.background)

            Divider()
                .background(DesignSystem.Colors.divider)

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
        .onAppear {
            appBlockerManager.refreshRunningApps()
        }
    }
}

struct BlockerTabButton: View {
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
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(
                    Rectangle()
                        .fill(isSelected ? DesignSystem.Colors.timerActive : Color.clear)
                        .frame(height: 3)
                        .offset(y: 15)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}