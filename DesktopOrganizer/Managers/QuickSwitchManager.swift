import AppKit
import Foundation
import SwiftUI

/// Hızlı Pencere Değiştirici (Quick Switcher) merkezi durum ve eylem yöneticisi
@MainActor
public final class QuickSwitchManager: ObservableObject {
    public static let shared = QuickSwitchManager()

    @Published public var selectedIndex: Int = 0
    @Published public var windows: [WindowItem] = []
    @Published public var isVisible: Bool = false

    public var onDismiss: (() -> Void)?

    private init() {}

    /// Paneli açmadan önce pencereleri yeniler ve seçimi ilk pencereye alır
    public func prepare() {
        WindowManager.shared.refreshWindows()
        self.windows = WindowManager.shared.windows
        self.selectedIndex = 0
        self.isVisible = true
    }

    public func selectNext() {
        guard !windows.isEmpty else { return }
        if selectedIndex < windows.count - 1 {
            selectedIndex += 1
        } else {
            selectedIndex = 0 // Başa sar
        }
    }

    public func selectPrevious() {
        guard !windows.isEmpty else { return }
        if selectedIndex > 0 {
            selectedIndex -= 1
        } else {
            selectedIndex = windows.count - 1 // Sona sar
        }
    }

    public func confirmSelection() {
        guard !windows.isEmpty, selectedIndex < windows.count else {
            dismiss()
            return
        }
        let targetWindow = windows[selectedIndex]
        WindowManager.shared.focusWindow(targetWindow)
        dismiss()
    }

    public func dismiss() {
        isVisible = false
        onDismiss?()
    }
}
