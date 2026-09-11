import AppKit
import SwiftUI

/// Açık olan bir pencereyi temsil eden model
public struct WindowItem: Identifiable, Equatable {
    public let id: CGWindowID
    public let pid: pid_t
    public let appName: String
    public var windowTitle: String
    public let appIcon: NSImage?
    public var bounds: CGRect
    public var thumbnail: NSImage?
    public let colorTint: Color
    public var isMinimized: Bool

    public init(
        id: CGWindowID,
        pid: pid_t,
        appName: String,
        windowTitle: String,
        appIcon: NSImage?,
        bounds: CGRect,
        thumbnail: NSImage? = nil,
        colorTint: Color? = nil,
        isMinimized: Bool = false
    ) {
        self.id = id
        self.pid = pid
        self.appName = appName
        self.windowTitle = windowTitle.isEmpty ? appName : windowTitle
        self.appIcon = appIcon
        self.bounds = bounds
        self.thumbnail = thumbnail
        self.isMinimized = isMinimized
        self.colorTint = colorTint ?? WindowItem.generateColorTint(for: appName)
    }

    public static func == (lhs: WindowItem, rhs: WindowItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.pid == rhs.pid &&
        lhs.windowTitle == rhs.windowTitle &&
        lhs.bounds == rhs.bounds &&
        lhs.isMinimized == rhs.isMinimized
    }

    /// Uygulama adına göre tutarlı ve şık bir vurgu rengi üretir
    public static func generateColorTint(for appName: String) -> Color {
        let colors: [Color] = [
            Color.blue,
            Color.purple,
            Color.indigo,
            Color.teal,
            Color.cyan,
            Color.orange,
            Color.pink,
            Color.green,
            Color.mint
        ]
        var hash: Int = 0
        for scalar in appName.unicodeScalars {
            hash = (hash &* 31) &+ Int(scalar.value)
        }
        let index = abs(hash) % colors.count
        return colors[index]
    }
}
