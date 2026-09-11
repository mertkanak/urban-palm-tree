import AppKit
import SwiftUI

/// Menü çubuğu simgesini, global kısayolları ve overlay penceresini yöneten AppDelegate
@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var overlayWindow: NSPanel?
    private var quickSwitchPanel: NSPanel?
    private var globalEventMonitor: Any?
    private var localEventMonitor: Any?

    public func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupOverlayWindow()
        setupQuickSwitchPanel()
        setupGlobalShortcut()

        // Uygulama ilk açıldığında izinleri sorgula
        PermissionManager.shared.checkPermissions()

        // Arka planda güncelleme kontrolü başlat
        AutoUpdater.shared.startPeriodicCheck()
    }

    // MARK: - Menü Çubuğu (NSStatusItem)

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "macwindow.on.rectangle", accessibilityDescription: "Desktop Organizer")
            button.action = #selector(statusItemClicked)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc private func statusItemClicked() {
        guard let event = NSApp.currentEvent else {
            toggleOverlay()
            return
        }

        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            toggleOverlay()
        }
    }

    private func showContextMenu() {
        let menu = NSMenu()

        let toggleItem = NSMenuItem(title: "Desktop Organizer'ı Aç/Kapat", action: #selector(toggleOverlay), keyEquivalent: "o")
        toggleItem.target = self
        menu.addItem(toggleItem)

        let quickItem = NSMenuItem(title: "Hızlı Pencere Değiştirici (⌥+S veya ⌥+Tab)", action: #selector(toggleQuickSwitch), keyEquivalent: "")
        quickItem.target = self
        menu.addItem(quickItem)

        menu.addItem(NSMenuItem.separator())

        let refreshItem = NSMenuItem(title: "Pencereleri Yenile", action: #selector(refreshAll), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)

        let toggleDesktopItem = NSMenuItem(title: "Masaüstü İkonlarını Gizle/Göster", action: #selector(toggleDesktopIcons), keyEquivalent: "d")
        toggleDesktopItem.target = self
        menu.addItem(toggleDesktopItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Çıkış", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    @objc public func refreshAll() {
        WindowManager.shared.refreshWindows()
        DesktopIconManager.shared.refreshFiles()
    }

    @objc public func toggleDesktopIcons() {
        DesktopIconManager.shared.toggleDesktopIcons()
    }

    @objc public func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Overlay Penceresi

    private func setupOverlayWindow() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 1060, height: 740),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        panel.title = "Desktop Organizer"
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.level = .floating
        panel.isFloatingPanel = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = NSHostingView(rootView: MainOverlayView())
        panel.center()
        panel.setFrameAutosaveName("DesktopOrganizerMainWindow")

        self.overlayWindow = panel
        panel.makeKeyAndOrderFront(nil)
    }

    @objc public func toggleOverlay() {
        guard let window = overlayWindow else { return }

        if window.isVisible {
            window.orderOut(nil)
        } else {
            WindowManager.shared.refreshWindows()
            window.center()
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // MARK: - Quick Switch Panel (⌥+Tab / ⌥+S)

    private func setupQuickSwitchPanel() {
        let panel = KeyableQuickSwitchPanel(
            contentRect: NSRect(x: 0, y: 0, width: 620, height: 260),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.level = .floating
        panel.isFloatingPanel = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hidesOnDeactivate = false

        let rootView = QuickSwitchView {
            Task { @MainActor in
                self.quickSwitchPanel?.orderOut(nil)
            }
        }
        panel.contentView = NSHostingView(rootView: rootView)
        self.quickSwitchPanel = panel
    }

    @objc public func toggleQuickSwitch() {
        guard let panel = quickSwitchPanel else { return }

        if panel.isVisible {
            panel.orderOut(nil)
        } else {
            WindowManager.shared.refreshWindows()
            panel.center()
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // MARK: - Global Kısayol Dinleyici

    /// Ana panelin açılıp kapanmasını tetikleyen kısayolları kontrol eder
    private func isToggleOverlayEvent(_ event: NSEvent) -> Bool {
        // 1. ⌥ + Space (Option + Space: keyCode 49)
        if event.modifierFlags.contains(.option) && event.keyCode == 49 {
            return true
        }

        // 2. 'A' tuşu (keyCode 0) kombinasyonları
        if event.keyCode == 0 {
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

            // Caps Lock açıkken Shift + A
            if flags.contains(.capsLock) && flags.contains(.shift) {
                return true
            }

            // ⌃ + ⇧ + A (Control + Shift + A)
            if flags.contains(.control) && flags.contains(.shift) {
                return true
            }

            // ⌥ + ⇧ + A (Option + Shift + A)
            if flags.contains(.option) && flags.contains(.shift) {
                return true
            }

            // ⌥ + A (Option + A: tek elle sol parmakla tak diye açılan süper hızlı kısayol)
            if flags.contains(.option) && !flags.contains(.command) {
                return true
            }
        }

        return false
    }

    /// Hızlı Pencere Değiştiriciyi tetikleyen kısayolları kontrol eder (⌥+Tab, ⌥+S, ⌥+W)
    private func isToggleQuickSwitchEvent(_ event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // 1. ⌥ + Tab veya ⌃ + Tab (keyCode 48)
        if (flags.contains(.option) || flags.contains(.control)) && event.keyCode == 48 {
            return true
        }

        // 2. 'S' tuşu (keyCode 1: Switch) -> ⌥ + S veya ⌃ + ⇧ + S
        if event.keyCode == 1 {
            if flags.contains(.option) && !flags.contains(.command) {
                return true
            }
            if (flags.contains(.capsLock) || flags.contains(.control)) && flags.contains(.shift) {
                return true
            }
        }

        // 3. 'W' tuşu (keyCode 13: Window) -> ⌥ + W
        if event.keyCode == 13 {
            if flags.contains(.option) && !flags.contains(.command) {
                return true
            }
        }

        return false
    }

    private func setupGlobalShortcut() {
        // Global monitor (uygulama arka plandayken)
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Ana panel kısayolu (⌥A, ⌥Space, Caps+Shift+A, ⌃⇧A, ⌥⇧A)
            if self?.isToggleOverlayEvent(event) == true {
                Task { @MainActor in self?.toggleOverlay() }
                return
            }

            // Quick Switch kısayolu (⌥S, ⌥Tab, ⌥W, ⌃Tab)
            if self?.isToggleQuickSwitchEvent(event) == true {
                Task { @MainActor in self?.toggleQuickSwitch() }
                return
            }
        }

        // Local monitor (uygulama aktifken)
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }

            // Ana panel kısayolu basılırsa kapat
            if self.isToggleOverlayEvent(event) {
                Task { @MainActor in
                    self.toggleOverlay()
                }
                return nil
            }

            // Quick Switch kısayolu basılırsa
            if self.isToggleQuickSwitchEvent(event) {
                Task { @MainActor in
                    self.toggleQuickSwitch()
                }
                return nil
            }

            // ESC → Aktif paneli kapat
            if event.keyCode == 53 {
                Task { @MainActor in
                    self.overlayWindow?.orderOut(nil)
                    self.quickSwitchPanel?.orderOut(nil)
                }
                return nil
            }

            // ⌘+1…9 → Filtrelenmiş listedeki N. pencereyi öne getir
            if event.modifierFlags.contains(.command),
               let numStr = event.characters,
               let num = Int(numStr), num >= 1, num <= 9 {
                Task { @MainActor in
                    let windows = WindowManager.shared.filteredWindows
                    let idx = num - 1
                    if idx < windows.count {
                        WindowManager.shared.focusWindow(windows[idx])
                    }
                }
                return nil
            }

            return event
        }
    }
}

/// Klavye olaylarını tam yakalayabilen borderless NSPanel
fileprivate final class KeyableQuickSwitchPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
