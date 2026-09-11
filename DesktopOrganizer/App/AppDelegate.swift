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

        let quickItem = NSMenuItem(title: "Hızlı Pencere Değiştirici (⌥+Tab / ⌃+Tab)", action: #selector(toggleQuickSwitch), keyEquivalent: "")
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

        let forceQuitAllItem = NSMenuItem(title: "Tüm Açık Uygulamaları Kapat (⌥+⇧+Q)", action: #selector(forceQuitAllClicked), keyEquivalent: "")
        forceQuitAllItem.target = self
        menu.addItem(forceQuitAllItem)

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

    @objc private func forceQuitAllClicked() {
        WindowManager.shared.forceQuitAllApps()
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

    // MARK: - Quick Switch Panel (⌥+Tab / ⌃+Tab / ⌃⇧W / ⌥`)

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

        let rootView = QuickSwitchView()
        panel.contentView = NSHostingView(rootView: rootView)
        self.quickSwitchPanel = panel

        QuickSwitchManager.shared.onDismiss = { [weak self] in
            Task { @MainActor in
                self?.quickSwitchPanel?.orderOut(nil)
            }
        }
    }

    @objc public func toggleQuickSwitch() {
        guard let panel = quickSwitchPanel else { return }

        if panel.isVisible {
            QuickSwitchManager.shared.dismiss()
        } else {
            QuickSwitchManager.shared.prepare()
            panel.center()
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // MARK: - Global Kısayol Dinleyici

    /// Ana panelin açılıp kapanmasını tetikleyen kısayolları kontrol eder
    private func isToggleOverlayEvent(_ event: NSEvent) -> Bool {
        // 1. ⌥ + Space (Option + Space: keyCode 49)
        if event.modifierFlags.contains(.option) && !event.modifierFlags.contains(.control) && event.keyCode == 49 {
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

            // ⌥ + A (Option + A)
            if flags.contains(.option) && !flags.contains(.command) {
                return true
            }
        }

        return false
    }

    /// Hızlı Pencere Değiştiriciyi tetikleyen kısayolları kontrol eder (Çakışmayan: ⌥Tab, ⌃Tab, ⌃⇧W, ⌥W, ⌥`)
    private func isToggleQuickSwitchEvent(_ event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // 1. ⌥ + Tab veya ⌃ + Tab (keyCode 48) - En popüler ve çakışmayan standart
        if (flags.contains(.option) || flags.contains(.control)) && event.keyCode == 48 {
            return true
        }

        // 2. ⌥ + ` (Option + Tırnak: keyCode 50 - Mac pencereler arası geçiş)
        if flags.contains(.option) && event.keyCode == 50 {
            return true
        }

        // 3. 'W' tuşu (keyCode 13: Window) -> ⌃ + ⇧ + W veya ⌥ + ⇧ + W veya ⌥ + W
        if event.keyCode == 13 {
            if flags.contains(.control) && flags.contains(.shift) {
                return true
            }
            if flags.contains(.option) && !flags.contains(.command) {
                return true
            }
        }

        // 4. ⌃ + ⌥ + Space (keyCode 49)
        if flags.contains(.control) && flags.contains(.option) && event.keyCode == 49 {
            return true
        }

        return false
    }

    /// Toplu Force Quit kısayolunu kontrol eder (⌥ + ⇧ + Q)
    private func isForceQuitAllEvent(_ event: NSEvent) -> Bool {
        // 'Q' tuşu keyCode: 12
        guard event.keyCode == 12 else { return false }
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        return flags.contains(.option) && flags.contains(.shift)
    }

    private func setupGlobalShortcut() {
        // Global monitor (uygulama arka plandayken)
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Toplu Force Quit kısayolu (⌥ + ⇧ + Q)
            if self?.isForceQuitAllEvent(event) == true {
                Task { @MainActor in WindowManager.shared.forceQuitAllApps() }
                return
            }

            // Ana panel kısayolu (⌥A, ⌥Space, Caps+Shift+A, ⌃⇧A, ⌥⇧A)
            if self?.isToggleOverlayEvent(event) == true {
                Task { @MainActor in self?.toggleOverlay() }
                return
            }

            // Quick Switch kısayolu (⌥Tab, ⌃Tab, ⌥W, ⌃⇧W, ⌥`)
            if self?.isToggleQuickSwitchEvent(event) == true {
                Task { @MainActor in self?.toggleQuickSwitch() }
                return
            }
        }

        // Local monitor (uygulama aktifken)
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }

            // Toplu Force Quit kısayolu (⌥ + ⇧ + Q)
            if self.isForceQuitAllEvent(event) {
                Task { @MainActor in WindowManager.shared.forceQuitAllApps() }
                return nil
            }

            // Eğer Quick Switch paneli açıksa ESC ile hemen kapat
            if self.quickSwitchPanel?.isVisible == true && event.keyCode == 53 {
                Task { @MainActor in QuickSwitchManager.shared.dismiss() }
                return nil
            }

            // Ana panel kısayolu basılırsa kapat
            if self.isToggleOverlayEvent(event) {
                Task { @MainActor in self.toggleOverlay() }
                return nil
            }

            // Quick Switch kısayolu basılırsa
            if self.isToggleQuickSwitchEvent(event) {
                Task { @MainActor in self.toggleQuickSwitch() }
                return nil
            }

            // ESC → Ana overlay kapat
            if event.keyCode == 53 {
                Task { @MainActor in
                    self.overlayWindow?.orderOut(nil)
                    QuickSwitchManager.shared.dismiss()
                }
                return nil
            }

            return event
        }
    }
}

/// Klavye olaylarını doğrudan AppKit seviyesinde yakalayan borderless NSPanel
fileprivate final class KeyableQuickSwitchPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func sendEvent(_ event: NSEvent) {
        if event.type == .keyDown {
            // ESC (53)
            if event.keyCode == 53 {
                QuickSwitchManager.shared.dismiss()
                return
            }

            // Q (12) veya ⌘+Q: Seçili uygulamaya anında Force Quit at
            if event.keyCode == 12 || (event.keyCode == 51 && event.modifierFlags.contains(.command)) {
                QuickSwitchManager.shared.forceQuitSelected()
                return
            }

            // Sol Ok (123) veya Yukarı Ok (126)
            if event.keyCode == 123 || event.keyCode == 126 {
                QuickSwitchManager.shared.selectPrevious()
                return
            }

            // Sağ Ok (124) veya Aşağı Ok (125)
            if event.keyCode == 124 || event.keyCode == 125 {
                QuickSwitchManager.shared.selectNext()
                return
            }

            // Tab (48)
            if event.keyCode == 48 {
                if event.modifierFlags.contains(.shift) {
                    QuickSwitchManager.shared.selectPrevious()
                } else {
                    QuickSwitchManager.shared.selectNext()
                }
                return
            }

            // Enter / Return (36 / 76) veya Space (49)
            if event.keyCode == 36 || event.keyCode == 76 || event.keyCode == 49 {
                QuickSwitchManager.shared.confirmSelection()
                return
            }
        }
        super.sendEvent(event)
    }

    override func resignKey() {
        super.resignKey()
        DispatchQueue.main.async {
            QuickSwitchManager.shared.dismiss()
        }
    }
}
