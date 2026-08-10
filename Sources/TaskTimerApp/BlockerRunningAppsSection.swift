import SwiftUI

struct RunningAppsSection: View {
    @EnvironmentObject var appBlockerManager: AppBlockerManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField("Search running apps...", text: $appBlockerManager.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)

                if !appBlockerManager.searchText.isEmpty {
                    Button(action: {
                        appBlockerManager.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Button(action: {
                    appBlockerManager.refreshRunningApps()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Running Apps List
            if appBlockerManager.filteredRunningApps.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "app.dashed")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("No running apps found")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(appBlockerManager.filteredRunningApps) { app in
                            RunningAppRow(app: app)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
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
                
                Text("PID: \(app.pid)")
                    .font(.system(size: 10))
                    .foregroundColor(.gray.opacity(0.8))
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
                    .foregroundColor(isBlocked ? .green : .red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isBlocked ? Color.green.opacity(0.1) : Color.gray.opacity(0.15))
        .cornerRadius(12)
    }
}