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

        let quickItem = NSMenuItem(title: "Hızlı Geçiş (⌥+Tab)", action: #selector(toggleQuickSwitch), keyEquivalent: "")
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

    // MARK: - Quick Switch Panel (⌥+Tab)

    private func setupQuickSwitchPanel() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 60),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.level = .statusBar
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
            if let screen = NSScreen.main {
                let sw = panel.frame.width
                let x = screen.frame.midX - sw / 2
                let y = screen.frame.midY + 80
                panel.setFrameOrigin(CGPoint(x: x, y: y))
            }
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // MARK: - Global Kısayol Dinleyici

    private func setupGlobalShortcut() {
        // Global monitor (uygulama arka plandayken)
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // ⌥+Space → Ana panel aç/kapat
            if event.modifierFlags.contains(.option) && event.keyCode == 49 {
                Task { @MainActor in self?.toggleOverlay() }
            }
            // ⌥+Tab → Quick Switch aç/kapat
            if event.modifierFlags.contains(.option) && event.keyCode == 48 {
                Task { @MainActor in self?.toggleQuickSwitch() }
            }
        }

        // Local monitor (uygulama aktifken)
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }

            // ESC → Overlay kapat
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
