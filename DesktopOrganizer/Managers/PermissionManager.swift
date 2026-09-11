import AppKit
import CoreGraphics
import Foundation

/// macOS Accessibility ve Screen Recording izinlerini yöneten servis
@MainActor
public final class PermissionManager: ObservableObject {
    public static let shared = PermissionManager()

    @Published public private(set) var state: PermissionState = .initial

    private var timer: Timer?

    public init() {
        checkPermissions()
        startPeriodicCheck()
    }

    deinit {
        timer?.invalidate()
    }

    /// İzin durumlarını sorgular
    public func checkPermissions() {
        let isAccessibilityGranted = AXIsProcessTrusted()
        let isScreenCaptureGranted = CGPreflightScreenCaptureAccess()

        let newState = PermissionState(
            isAccessibilityGranted: isAccessibilityGranted,
            isScreenCaptureGranted: isScreenCaptureGranted
        )

        if self.state != newState {
            self.state = newState
        }
    }

    /// Kullanıcı Ayarlar'dan izni verince arayüzün anında güncellenmesi için periyodik kontrol
    public func startPeriodicCheck() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkPermissions()
            }
        }
    }

    /// Erişilebilirlik izni isteme iletişim kutusunu tetikler
    public func requestAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        _ = AXIsProcessTrustedWithOptions(options)
        checkPermissions()
    }

    /// Ekran Kaydı iznini talep eder
    public func requestScreenCapturePermission() {
        CGRequestScreenCaptureAccess()
        checkPermissions()
    }

    /// macOS Sistem Ayarları > Gizlilik ve Güvenlik > Erişilebilirlik sayfasını açar
    public func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    /// macOS Sistem Ayarları > Gizlilik ve Güvenlik > Ekran Kaydı sayfasını açar
    public func openScreenCaptureSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }
}
