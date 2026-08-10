import SwiftUI

struct BlockSection: View {
    @EnvironmentObject var appBlockerManager: AppBlockerManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Blocked Applications")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if appBlockerManager.isAnyAppBlocked {
                    Text("\(appBlockerManager.currentlyBlockedApps.count) blocked")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.gray.opacity(0.1))
            
            // Blocked Apps List
            VStack(spacing: 0) {
                if appBlockerManager.currentlyBlockedApps.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "lock.open")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)

                        Text("No apps blocked")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)

                        Text("Add apps to block from the Running Apps tab")
                            .font(.system(size: 12))
                            .foregroundColor(.gray.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(appBlockerManager.currentlyBlockedApps) { app in
                                BlockedAppRow(app: app)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                }

                // Unclosable Mode Toggle
                VStack(spacing: 12) {
                    Divider()
                        .background(Color.gray.opacity(0.3))

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Unclosable Mode")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)

                            Text("App reappears instead of quitting")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { appBlockerManager.isUnclosableMode },
                            set: { _ in appBlockerManager.toggleUnclosableMode() }
                        ))
                        .toggleStyle(SwitchToggleStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.gray.opacity(0.1))
                }
            }
        }
    }
}

struct BlockedAppRow: View {
    let app: BlockedApp
    @EnvironmentObject var appBlockerManager: AppBlockerManager
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .cornerRadius(8)
            }
            
            // App Info
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                
                Text(app.bundleID)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                
                if let blockedAt = app.blockedAt {
                    Text("Blocked \(timeAgoString(from: blockedAt))")
                        .font(.system(size: 10))
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            // Unblock Button
            Button(action: {
                appBlockerManager.unblockApp(app.bundleID)
            }) {
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
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