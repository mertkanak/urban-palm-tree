import CoreGraphics
import Foundation

/// Tek bir pencerenin kayıtlı çerçeve ve kimlik bilgisi
public struct SessionEntry: Codable, Sendable {
    public let pid: pid_t
    public let bundleIdentifier: String
    public let windowTitle: String
    public let frame: CodableCGRect

    public init(pid: pid_t, bundleIdentifier: String, windowTitle: String, frame: CGRect) {
        self.pid = pid
        self.bundleIdentifier = bundleIdentifier
        self.windowTitle = windowTitle
        self.frame = CodableCGRect(frame)
    }
}

/// CGRect'i Codable yapan wrapper
public struct CodableCGRect: Codable, Sendable {
    public let x: CGFloat
    public let y: CGFloat
    public let width: CGFloat
    public let height: CGFloat

    public init(_ rect: CGRect) {
        self.x = rect.origin.x
        self.y = rect.origin.y
        self.width = rect.size.width
        self.height = rect.size.height
    }

    public var cgRect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }
}

/// Kaydedilmiş pencere düzenini temsil eden model
public struct WindowSession: Codable, Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public let savedAt: Date
    public let entries: [SessionEntry]

    public init(name: String, entries: [SessionEntry]) {
        self.id = UUID()
        self.name = name
        self.savedAt = Date()
        self.entries = entries
    }

    /// Ekranda gösterilecek özet açıklaması
    public var summary: String {
        "\(entries.count) pencere • \(formattedDate)"
    }

    private var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .short
        fmt.timeStyle = .short
        return fmt.string(from: savedAt)
    }
}
