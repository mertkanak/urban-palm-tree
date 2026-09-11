import AppKit
import CoreGraphics
import Foundation
import ScreenCaptureKit

/// ScreenCaptureKit (macOS 14+) ile pencerelerin thumbnail görüntülerini arka planda asenkron oluşturan yönetici
public final class WindowCaptureManager: @unchecked Sendable {
    public static let shared = WindowCaptureManager()

    /// Thumbnail önbelleği (CGWindowID -> NSImage)
    private let cache = NSCache<NSNumber, NSImage>()
    private let queue = DispatchQueue(label: "com.desktoporganizer.capturequeue", qos: .userInitiated)

    private init() {
        cache.countLimit = 60
    }

    /// Önbellekten temizler
    public func clearCache() {
        cache.removeAllObjects()
    }

    /// Belirtilen pencere ID'si için önizleme görüntüsünü getirir (varsa önbellekten, yoksa ScreenCaptureKit ile)
    public func captureThumbnail(for windowId: CGWindowID, size: CGSize = CGSize(width: 400, height: 260)) async -> NSImage? {
        let key = NSNumber(value: windowId)
        if let cached = cache.object(forKey: key) {
            return cached
        }

        // Ekran kaydı izni yoksa nil dön (Placeholder gösterilecek)
        guard CGPreflightScreenCaptureAccess() else {
            return nil
        }

        do {
            // macOS 14+ ScreenCaptureKit shareable content
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            guard let scWindow = content.windows.first(where: { $0.windowID == windowId }) else {
                return nil
            }

            let filter = SCContentFilter(desktopIndependentWindow: scWindow)
            let config = SCStreamConfiguration()
            config.width = Int(size.width * 2) // Retina 2x
            config.height = Int(size.height * 2)
            config.showsCursor = false
            config.scalesToFit = true

            let cgImage = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
            let nsImage = NSImage(cgImage: cgImage, size: size)

            self.cache.setObject(nsImage, forKey: key)
            return nsImage
        } catch {
            return nil
        }
    }

    /// Belirtilen pencere listesi için arka planda toplu önizleme yakalar ve tamamlandığında closure çağırır
    public func batchCaptureThumbnails(for windowIds: [CGWindowID], onCaptured: @escaping @Sendable (CGWindowID, NSImage) -> Void) {
        guard CGPreflightScreenCaptureAccess() else { return }

        Task.detached(priority: .utility) {
            for wid in windowIds {
                if let image = await self.captureThumbnail(for: wid) {
                    onCaptured(wid, image)
                }
            }
        }
    }
}
