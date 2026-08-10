import Foundation
import AppKit

struct BlockedApp: Identifiable, Codable, Hashable {
    let id: UUID
    let bundleID: String
    let name: String
    let iconData: Data?
    var isBlocked: Bool
    var blockedAt: Date?
    
    init(bundleID: String, name: String, icon: NSImage? = nil, isBlocked: Bool = true) {
        self.id = UUID()
        self.bundleID = bundleID
        self.name = name
        self.iconData = icon?.tiffRepresentation
        self.isBlocked = isBlocked
        self.blockedAt = isBlocked ? Date() : nil
    }
    
    var icon: NSImage? {
        guard let iconData = iconData else { return nil }
        return NSImage(data: iconData)
    }
}

struct RunningApp: Identifiable, Hashable {
    let id: UUID
    let bundleID: String
    let name: String
    let pid: Int
    let icon: NSImage?
    
    init(bundleID: String, name: String, pid: Int, icon: NSImage? = nil) {
        self.id = UUID()
        self.bundleID = bundleID
        self.name = name
        self.pid = pid
        self.icon = icon
    }
}

enum AppBlockerConstants {
    static let blockedAppsKey = "blockedApps"
    static let bilibiliBundleID = "tv.danmaku.bili"  // Bilibili
    static let bilibiliCNBundleID = "com.bilibili.app"  // 哔哩哔哩
    static let selfBundleID = "com.iflow.tasktimer"  // TaskTimerApp itself - 必须与Info.plist中的CFBundleIdentifier匹配
}

// MARK: - Dictionary Conversion Extensions
extension BlockedApp {
    func toDictionary() -> [String: Any] {
        return [
            "bundleID": bundleID,
            "name": name,
            "isBlocked": isBlocked,
            "blockedAt": blockedAt != nil ? ISO8601DateFormatter().string(from: blockedAt!) : NSNull()
        ]
    }
}

extension RunningApp {
    func toDictionary() -> [String: Any] {
        return [
            "bundleID": bundleID,
            "name": name,
            "pid": pid
        ]
    }
}