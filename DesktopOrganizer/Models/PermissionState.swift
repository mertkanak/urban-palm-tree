import Foundation

/// Sistem izinlerinin durumunu temsil eden model
public struct PermissionState: Equatable, Sendable {
    public var isAccessibilityGranted: Bool
    public var isScreenCaptureGranted: Bool

    public var allGranted: Bool {
        isAccessibilityGranted && isScreenCaptureGranted
    }

    public var hasAnyMissing: Bool {
        !allGranted
    }

    public static let initial = PermissionState(
        isAccessibilityGranted: false,
        isScreenCaptureGranted: false
    )
}
