import AppKit
import ApplicationServices
import Foundation

/// macOS Accessibility API (AXUIElement) ile pencereleri öne getirme, taşıma, boyutlandırma ve kapatma servisi
public final class AccessibilityManager: Sendable {
    public static let shared = AccessibilityManager()

    private init() {}

    // MARK: - Pencere Bulma Yardımcısı

    /// Belirtilen PID ve pencere özelliklerine uyan AXUIElement referansını bulur
    public func findWindowElement(for pid: pid_t, windowId: CGWindowID? = nil, title: String? = nil) -> AXUIElement? {
        let appElement = AXUIElementCreateApplication(pid)
        var windowListRef: CFTypeRef?
        let copyResult = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowListRef)

        guard copyResult == .success, let windowList = windowListRef as? [AXUIElement], !windowList.isEmpty else {
            return nil
        }

        // Eğer başlık verilmişse eşleşen başlığa sahip pencereyi bul
        if let targetTitle = title, !targetTitle.isEmpty {
            for win in windowList {
                var titleRef: CFTypeRef?
                if AXUIElementCopyAttributeValue(win, kAXTitleAttribute as CFString, &titleRef) == .success,
                   let winTitle = titleRef as? String,
                   winTitle == targetTitle {
                    return win
                }
            }
        }

        // İlk pencereyi varsayılan olarak döndür
        return windowList.first
    }

    // MARK: - Öne Getirme ve Odaklanma (Raise & Focus)

    /// İlgili uygulamayı ve pencereyi en öne getirir
    public func raiseAndFocus(pid: pid_t, windowId: CGWindowID? = nil, title: String? = nil) {
        // 1. Önce NSRunningApplication ile uygulamayı aktif yap (macOS 14+ uyumlu)
        if let app = NSRunningApplication(processIdentifier: pid) {
            app.activate()
        }

        // 2. Erişilebilirlik izni varsa AXUIElement ile spesifik pencereyi öne çek
        if AXIsProcessTrusted(), let windowElement = findWindowElement(for: pid, windowId: windowId, title: title) {
            AXUIElementPerformAction(windowElement, kAXRaiseAction as CFString)
            AXUIElementSetAttributeValue(windowElement, kAXMainAttribute as CFString, kCFBooleanTrue)
        }
    }

    // MARK: - Sürükle-Bırak ile Taşıma (Drag & Reposition)

    /// Pencereyi ekranda yeni koordinata taşır
    public func moveWindow(pid: pid_t, windowId: CGWindowID? = nil, title: String? = nil, to point: CGPoint) {
        guard AXIsProcessTrusted(), let windowElement = findWindowElement(for: pid, windowId: windowId, title: title) else {
            return
        }

        var newPoint = point
        guard let value = AXValueCreate(.cgPoint, &newPoint) else { return }
        AXUIElementSetAttributeValue(windowElement, kAXPositionAttribute as CFString, value)
    }

    // MARK: - Yeniden Boyutlandırma (Resize)

    /// Pencere boyutunu masaüstünde günceller
    public func resizeWindow(pid: pid_t, windowId: CGWindowID? = nil, title: String? = nil, to size: CGSize) {
        guard AXIsProcessTrusted(), let windowElement = findWindowElement(for: pid, windowId: windowId, title: title) else {
            return
        }

        var newSize = size
        guard let value = AXValueCreate(.cgSize, &newSize) else { return }
        AXUIElementSetAttributeValue(windowElement, kAXSizeAttribute as CFString, value)
    }

    // MARK: - Konum ve Boyut Birlikte (Frame)

    /// Pencere konum ve boyutunu tek adımda ayarlar (Snap/Tiling için)
    public func setWindowFrame(pid: pid_t, windowId: CGWindowID? = nil, title: String? = nil, frame: CGRect) {
        moveWindow(pid: pid, windowId: windowId, title: title, to: frame.origin)
        resizeWindow(pid: pid, windowId: windowId, title: title, to: frame.size)
    }

    // MARK: - Pencere Kapatma (Close)

    /// Pencereyi kapatır (kAXPressAction close button veya fallback)
    public func closeWindow(pid: pid_t, windowId: CGWindowID? = nil, title: String? = nil) {
        guard AXIsProcessTrusted(), let windowElement = findWindowElement(for: pid, windowId: windowId, title: title) else {
            // Erişilebilirlik izni yoksa uygulamayı kapatmayı dener
            if let app = NSRunningApplication(processIdentifier: pid) {
                app.terminate()
            }
            return
        }

        var closeButtonRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(windowElement, kAXCloseButtonAttribute as CFString, &closeButtonRef)
        if result == .success, let closeButton = closeButtonRef {
            // AXUIElementRef üzerinden kapat butonuna bas
            let axButton = closeButton as! AXUIElement
            AXUIElementPerformAction(axButton, kAXPressAction as CFString)
        } else {
            // Alternatif: Uygulamaya standart terminate gönder
            if let app = NSRunningApplication(processIdentifier: pid) {
                app.terminate()
            }
        }
    }

    // MARK: - Pencere Küçültme (Minimize)

    public func minimizeWindow(pid: pid_t, windowId: CGWindowID? = nil, title: String? = nil) {
        guard AXIsProcessTrusted(), let windowElement = findWindowElement(for: pid, windowId: windowId, title: title) else { return }
        AXUIElementSetAttributeValue(windowElement, kAXMinimizedAttribute as CFString, kCFBooleanTrue)
    }
}
