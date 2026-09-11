import AppKit
import Foundation

/// Masaüstünde bulunan bir dosya veya klasörü temsil eden model
public struct DesktopFileItem: Identifiable, Equatable, Hashable {
    public var id: URL { url }
    public let url: URL
    public let name: String
    public let category: FileCategory
    public let icon: NSImage
    public let sizeBytes: Int64
    public let sizeString: String
    public let modifiedDate: Date
    public let isDirectory: Bool

    public init(
        url: URL,
        name: String,
        category: FileCategory,
        icon: NSImage,
        sizeBytes: Int64,
        sizeString: String,
        modifiedDate: Date,
        isDirectory: Bool
    ) {
        self.url = url
        self.name = name
        self.category = category
        self.icon = icon
        self.sizeBytes = sizeBytes
        self.sizeString = sizeString
        self.modifiedDate = modifiedDate
        self.isDirectory = isDirectory
    }

    public static func == (lhs: DesktopFileItem, rhs: DesktopFileItem) -> Bool {
        lhs.url == rhs.url && lhs.modifiedDate == rhs.modifiedDate
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}
