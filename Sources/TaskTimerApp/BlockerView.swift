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
                    // Refresh running apps when tab is selected
                    appBlockerManager.refreshRunningApps()
                }
            }
            .background(Color.black)

            Divider()
                .background(Color.gray.opacity(0.3))

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
            // Initial refresh when view appears
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
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Rectangle()
                        .fill(isSelected ? Color.blue : Color.clear)
                        .frame(height: 3)
                        .offset(y: 15)
                )
                .contentShape(Rectangle()) // 确保整个按钮区域都可点击
        }
        .buttonStyle(PlainButtonStyle())
    }
}