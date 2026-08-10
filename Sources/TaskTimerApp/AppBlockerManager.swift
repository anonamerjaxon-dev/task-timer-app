import Foundation
import AppKit
import Combine

class AppBlockerManager: ObservableObject {
    @Published var blockedApps: [BlockedApp] = []
    @Published var runningApps: [RunningApp] = []
    @Published var isMonitoring: Bool = false
    @Published var searchText: String = ""
    @Published var isUnclosableMode: Bool = false

    private var monitoringTimer: Timer?
    private let workspace = NSWorkspace.shared
    private var cachedBlockedApps: [String: BlockedApp] = [:] // Cache for faster lookups

    init() {
        loadBlockedApps()
        addDefaultBlockedApps()
        loadUnclosableMode()
        // Don't auto-start monitoring - let user control it
    }
    
    // MARK: - Load/Save
    private func loadBlockedApps() {
        if let data = UserDefaults.standard.data(forKey: AppBlockerConstants.blockedAppsKey),
           let decoded = try? JSONDecoder().decode([BlockedApp].self, from: data) {
            self.blockedApps = decoded
        }
    }
    
    private func saveBlockedApps() {
        if let encoded = try? JSONEncoder().encode(blockedApps) {
            UserDefaults.standard.set(encoded, forKey: AppBlockerConstants.blockedAppsKey)
        }
    }

    private func loadUnclosableMode() {
        isUnclosableMode = UserDefaults.standard.bool(forKey: "unclosableMode")
    }

    private func saveUnclosableMode() {
        UserDefaults.standard.set(isUnclosableMode, forKey: "unclosableMode")
    }

    func toggleUnclosableMode() {
        isUnclosableMode.toggle()
        saveUnclosableMode()
        NotificationCenter.default.post(name: .unclosableModeDidChange, object: nil)
    }
    
    private func addDefaultBlockedApps() {
        let defaultApps = [
            (AppBlockerConstants.bilibiliBundleID, "Bilibili"),
            (AppBlockerConstants.bilibiliCNBundleID, "哔哩哔哩")
        ]
        
        for (bundleID, name) in defaultApps {
            if !blockedApps.contains(where: { $0.bundleID == bundleID }) {
                let icon = getAppIcon(forBundleID: bundleID)
                let blockedApp = BlockedApp(bundleID: bundleID, name: name, icon: icon, isBlocked: true)
                blockedApps.append(blockedApp)
            }
        }
        saveBlockedApps()
    }
    
    // MARK: - Running Apps
    func refreshRunningApps() {
        let runningApps = workspace.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap { app -> RunningApp? in
                guard let bundleID = app.bundleIdentifier,
                      let name = app.localizedName else {
                    return nil
                }

                // Filter out self app
                if bundleID == AppBlockerConstants.selfBundleID {
                    return nil
                }

                return RunningApp(
                    bundleID: bundleID,
                    name: name,
                    pid: Int(app.processIdentifier),
                    icon: app.icon
                )
            }

        DispatchQueue.main.async {
            self.runningApps = runningApps.sorted { $0.name < $1.name }
        }
    }
    
    // MARK: - Block/Unblock
    func blockApp(_ bundleID: String) {
        // Prevent blocking self
        guard bundleID != AppBlockerConstants.selfBundleID else { return }

        if let index = blockedApps.firstIndex(where: { $0.bundleID == bundleID }) {
            blockedApps[index].isBlocked = true
            blockedApps[index].blockedAt = Date()
            cachedBlockedApps[bundleID] = blockedApps[index]
        } else {
            let icon = getAppIcon(forBundleID: bundleID)
            let name = getAppName(forBundleID: bundleID) ?? bundleID
            let blockedApp = BlockedApp(bundleID: bundleID, name: name, icon: icon, isBlocked: true)
            blockedApps.append(blockedApp)
            cachedBlockedApps[bundleID] = blockedApp
        }
        saveBlockedApps()

        // Kill the app immediately
        killApp(bundleID)

        // Start monitoring if not already running
        if !isMonitoring {
            startMonitoring()
        } else {
            // If already monitoring, refresh running apps immediately to catch any new instances
            refreshRunningApps()
        }
    }
    
    func unblockApp(_ bundleID: String) {
        if let index = blockedApps.firstIndex(where: { $0.bundleID == bundleID }) {
            blockedApps[index].isBlocked = false
            blockedApps[index].blockedAt = nil
            cachedBlockedApps.removeValue(forKey: bundleID)
            saveBlockedApps()
        }

        // Stop monitoring if no apps are blocked
        if !isAnyAppBlocked && isMonitoring {
            stopMonitoring()
        } else if isMonitoring {
            // If still monitoring, refresh to update the UI
            refreshRunningApps()
        }
    }

    func stopBlocking(apps appNames: [String]) {
        var hasChanges = false

        if appNames.isEmpty {
            // Stop blocking all apps
            for index in blockedApps.indices {
                if blockedApps[index].isBlocked {
                    blockedApps[index].isBlocked = false
                    blockedApps[index].blockedAt = nil
                    cachedBlockedApps.removeValue(forKey: blockedApps[index].bundleID)
                    hasChanges = true
                }
            }
        } else {
            // Stop blocking specific apps
            for appName in appNames {
                if let index = blockedApps.firstIndex(where: {
                    $0.name.lowercased().contains(appName.lowercased()) && $0.isBlocked
                }) {
                    blockedApps[index].isBlocked = false
                    blockedApps[index].blockedAt = nil
                    cachedBlockedApps.removeValue(forKey: blockedApps[index].bundleID)
                    hasChanges = true
                }
            }
        }

        if hasChanges {
            saveBlockedApps()

            // Stop monitoring if no apps are blocked
            if !isAnyAppBlocked && isMonitoring {
                stopMonitoring()
            }
        }
    }
    
    func killApp(_ bundleID: String) {
        // Prevent killing self
        guard bundleID != AppBlockerConstants.selfBundleID else { return }
        
        let runningApps = workspace.runningApplications.filter { $0.bundleIdentifier == bundleID }
        for app in runningApps {
            app.terminate()
        }
    }
    
    // MARK: - Monitoring
    func startMonitoring() {
        guard !isMonitoring else { return }

        isMonitoring = true

        // Use main queue timer for better memory management and automatic run loop integration
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.isMonitoring else { return }

            // Invalidate existing timer if any
            self.monitoringTimer?.invalidate()

            // Refresh running apps immediately
            self.refreshRunningApps()

            // Create timer with shorter interval for more responsive blocking
            self.monitoringTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
                self?.checkAndBlockApps()
            }
        }
    }

    func stopMonitoring() {
        isMonitoring = false

        // Invalidate timer on main queue
        DispatchQueue.main.async { [weak self] in
            self?.monitoringTimer?.invalidate()
            self?.monitoringTimer = nil
        }
    }
    
    private func checkAndBlockApps() {
        // Only check if we have blocked apps
        guard isAnyAppBlocked else {
            if isMonitoring {
                stopMonitoring()
            }
            return
        }

        // Use cached blocked apps for faster iteration
        let currentlyBlocked = blockedApps.filter { $0.isBlocked }
        guard !currentlyBlocked.isEmpty else {
            if isMonitoring {
                stopMonitoring()
            }
            return
        }

        // Refresh running apps to get current state
        refreshRunningApps()

        // Kill blocked apps efficiently
        for blockedApp in currentlyBlocked {
            killApp(blockedApp.bundleID)
        }
    }
    
    // MARK: - Helpers
    private func getAppIcon(forBundleID bundleID: String) -> NSImage? {
        guard let url = workspace.urlForApplication(withBundleIdentifier: bundleID) else {
            return nil
        }
        return workspace.icon(forFile: url.path)
    }
    
    private func getAppName(forBundleID bundleID: String) -> String? {
        guard let url = workspace.urlForApplication(withBundleIdentifier: bundleID) else {
            return nil
        }
        return url.deletingPathExtension().lastPathComponent
    }
    
    // MARK: - Computed Properties
    var filteredRunningApps: [RunningApp] {
        if searchText.isEmpty {
            return runningApps
        }
        return runningApps.filter { app in
            app.name.localizedCaseInsensitiveContains(searchText) ||
            app.bundleID.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Manual Refresh
    func manualRefreshRunningApps() {
        refreshRunningApps()
    }
    
    var currentlyBlockedApps: [BlockedApp] {
        blockedApps.filter { $0.isBlocked }
    }

    var isAnyAppBlocked: Bool {
        blockedApps.contains { $0.isBlocked }
    }

    // MARK: - Cleanup
    deinit {
        stopMonitoring()
        cachedBlockedApps.removeAll()
    }
}