import AppKit
import Combine
import CoreGraphics
import Foundation
import SwiftUI

/// Pencere ızgarası görünüm modu
public enum GridViewMode: String, CaseIterable, Identifiable {
    case large  = "Büyük Kart"
    case compact = "Küçük Önizleme"
    case list   = "Liste"

    public var id: String { rawValue }

    public var systemIcon: String {
        switch self {
        case .large:   return "rectangle.grid.2x2.fill"
        case .compact: return "square.grid.3x3.fill"
        case .list:    return "list.bullet"
        }
    }
}

/// Açık pencereleri yöneten, listeleyen, filtreleyen ve eylemleri koordine eden ViewModel
@MainActor
public final class WindowManager: ObservableObject {
    public static let shared = WindowManager()

    @Published public private(set) var windows: [WindowItem] = []
    @Published public var searchQuery: String = ""
    @Published public var isGroupingByApp: Bool = false
    @Published public var selectedAppFilter: String? = nil
    @Published public var isRefreshing: Bool = false
    @Published public var gridViewMode: GridViewMode = .large

    /// Sabitlenmiş pencere ID'leri (UserDefaults'a kaydedilir)
    @Published public private(set) var pinnedIDs: Set<CGWindowID> = []
    /// En son odaklanılan pencereler (max 6, FIFO)
    @Published public private(set) var recentWindowIDs: [CGWindowID] = []

    private let pinnedUDKey = "com.desktoporganizer.pinnedWindowIDs"

    private var refreshTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let accessibilityManager = AccessibilityManager.shared
    private let captureManager = WindowCaptureManager.shared

    public init() {
        loadPinnedIDs()
        startMonitoring()
        refreshWindows()
    }

    deinit {
        refreshTimer?.invalidate()
    }

    // MARK: - Filtrelenmiş ve Gruplanmış Pencereler

    /// Arama sorgusu ve seçili uygulama filtresine göre filtrelenmiş pencere listesi
    /// Sabitlenmiş pencereler listenin başında yer alır
    public var filteredWindows: [WindowItem] {
        var result = windows

        // 1. Uygulama filtresi
        if let appFilter = selectedAppFilter, !appFilter.isEmpty {
            result = result.filter { $0.appName.localizedCaseInsensitiveContains(appFilter) }
        }

        // 2. Metin araması
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            result = result.filter {
                $0.windowTitle.localizedCaseInsensitiveContains(query) ||
                $0.appName.localizedCaseInsensitiveContains(query)
            }
        }

        // 3. Pinned öğeler başa
        return result.sorted { a, _ in pinnedIDs.contains(a.id) }
    }

    /// Son kullanılan 6 pencere
    public var recentWindows: [WindowItem] {
        recentWindowIDs.compactMap { wid in
            windows.first { $0.id == wid }
        }
    }

    /// Uygulama adına göre gruplandırılmış sözlük
    public var groupedWindows: [(appName: String, icon: NSImage?, color: Color, windows: [WindowItem])] {
        let grouped = Dictionary(grouping: filteredWindows, by: { $0.appName })
        return grouped.map { (key, items) in
            (
                appName: key,
                icon: items.first?.appIcon,
                color: items.first?.colorTint ?? .blue,
                windows: items
            )
        }.sorted { $0.appName.localizedCaseInsensitiveCompare($1.appName) == .orderedAscending }
    }

    // MARK: - Canlı İzleme & Yenileme

    public func startMonitoring() {
        // 1. Periyodik yenileme (1.5 saniye aralıkla)
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshWindows()
            }
        }

        // 2. NSWorkspace uygulama bildirimleri
        let nc = NSWorkspace.shared.notificationCenter
        let notifications: [NSNotification.Name] = [
            NSWorkspace.didActivateApplicationNotification,
            NSWorkspace.didDeactivateApplicationNotification,
            NSWorkspace.didLaunchApplicationNotification,
            NSWorkspace.didTerminateApplicationNotification,
            NSWorkspace.didHideApplicationNotification,
            NSWorkspace.didUnhideApplicationNotification
        ]

        for name in notifications {
            nc.publisher(for: name)
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    self?.refreshWindows()
                }
                .store(in: &cancellables)
        }
    }

    /// CGWindowListCopyWindowInfo ve NSWorkspace ile açık pencereleri tarar
    public func refreshWindows() {
        let currentPID = ProcessInfo.processInfo.processIdentifier

        // Normal ekrandaki pencereleri listele
        guard let windowInfoList = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as? [[String: Any]] else {
            return
        }

        // Çalışan standart uygulamaların haritasını çıkar
        let runningApps = NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular
        }
        let appMapByPID = Dictionary(uniqueKeysWithValues: runningApps.map { ($0.processIdentifier, $0) })

        var newWindows: [WindowItem] = []
        var existingThumbnails: [CGWindowID: NSImage] = [:]
        for w in self.windows {
            if let thumb = w.thumbnail {
                existingThumbnails[w.id] = thumb
            }
        }

        for info in windowInfoList {
            guard let layer = info[kCGWindowLayer as String] as? Int, layer == 0,
                  let windowIdInt = info[kCGWindowNumber as String] as? Int,
                  let ownerPID = info[kCGWindowOwnerPID as String] as? Int32,
                  ownerPID != currentPID // Kendi uygulamamızın penceresini grid'de gösterme
            else {
                continue
            }

            let windowId = CGWindowID(windowIdInt)
            guard let boundsDict = info[kCGWindowBounds as String] as? [String: Any],
                  let bounds = CGRect(dictionaryRepresentation: boundsDict as CFDictionary)
            else {
                continue
            }

            // Çok küçük veya sıfır boyutlu yardımcı pencereleri atla
            if bounds.width < 100 || bounds.height < 60 {
                continue
            }

            let runningApp = appMapByPID[ownerPID]
            let appName = (info[kCGWindowOwnerName as String] as? String) ?? runningApp?.localizedName ?? "Uygulama"
            var windowTitle = (info[kCGWindowName as String] as? String) ?? ""

            // Sistem pencere adını vermemişse (gizlilik izni yokken) yedek başlık
            if windowTitle.isEmpty {
                windowTitle = appName
            }

            let appIcon = runningApp?.icon

            let item = WindowItem(
                id: windowId,
                pid: ownerPID,
                appName: appName,
                windowTitle: windowTitle,
                appIcon: appIcon,
                bounds: bounds,
                thumbnail: existingThumbnails[windowId],
                isMinimized: false
            )

            newWindows.append(item)
        }

        self.windows = newWindows

        // Asenkron olarak thumbnail eksik olan pencerelerin önizlemelerini yakala
        captureMissingThumbnails()
    }

    /// Önizlemesi henüz olmayan pencerelerin thumbnail'lerini arka planda çeker
    private func captureMissingThumbnails() {
        let missingIds = windows.filter { $0.thumbnail == nil }.map { $0.id }
        guard !missingIds.isEmpty else { return }

        captureManager.batchCaptureThumbnails(for: missingIds) { [weak self] (wid, image) in
            Task { @MainActor in
                guard let self = self else { return }
                if let index = self.windows.firstIndex(where: { $0.id == wid }) {
                    self.windows[index].thumbnail = image
                }
            }
        }
    }

    // MARK: - Kullanıcı Eylemleri

    /// Seçili pencereyi öne getirir, odaklanır ve son kullanılanlar listesine ekler
    public func focusWindow(_ item: WindowItem) {
        accessibilityManager.raiseAndFocus(pid: item.pid, windowId: item.id, title: item.windowTitle)
        recordRecent(item.id)
    }

    /// Seçili pencereyi kapatır
    public func closeWindow(_ item: WindowItem) {
        accessibilityManager.closeWindow(pid: item.pid, windowId: item.id, title: item.windowTitle)
        // Listeden anında kaldır
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            self.windows.removeAll(where: { $0.id == item.id })
        }
    }

    /// Seçili uygulamanın sürecini tamamen zorla kapatır (Force Quit) - Dock'tan ve arka plandan silinir
    public func forceQuitApp(_ item: WindowItem) {
        forceQuitPid(item.pid)
    }

    /// Belirtilen PID'ye sahip uygulamayı tamamen zorla kapatır
    public func forceQuitPid(_ pid: pid_t) {
        if let app = NSRunningApplication(processIdentifier: pid) {
            app.forceTerminate()
        } else {
            kill(pid, SIGKILL)
        }
        // O uygulamaya ait tüm pencereleri listeden anında kaldır
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            self.windows.removeAll(where: { $0.pid == pid })
        }
    }

    /// Açık olan tüm kullanıcı uygulamalarını zorla kapatır (DesktopOrganizer ve Finder hariç)
    public func forceQuitAllApps() {
        let myPid = ProcessInfo.processInfo.processIdentifier
        let runningApps = NSWorkspace.shared.runningApplications
        for app in runningApps {
            // Sadece normal kullanıcı uygulamalarını kapat (Dock'ta yer alan standart uygulamalar)
            guard app.activationPolicy == .regular,
                  app.processIdentifier != myPid,
                  app.bundleIdentifier != "com.apple.finder" else {
                continue
            }
            app.forceTerminate()
        }
        // Listeden anında DesktopOrganizer dışındaki pencereleri kaldır
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            self.windows.removeAll(where: { $0.pid != myPid })
        }
        // 0.4 saniye sonra pencereleri sistemden yeniden doğrula
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.refreshWindows()
        }
    }

    /// Seçili pencereyi küçültür
    public func minimizeWindow(_ item: WindowItem) {
        accessibilityManager.minimizeWindow(pid: item.pid, windowId: item.id, title: item.windowTitle)
        if let index = windows.firstIndex(where: { $0.id == item.id }) {
            windows[index].isMinimized = true
        }
    }

    /// Sürükle-bırak ile pencereyi yeni ekrandaki konuma taşır
    public func moveWindow(_ item: WindowItem, to point: CGPoint) {
        accessibilityManager.moveWindow(pid: item.pid, windowId: item.id, title: item.windowTitle, to: point)
        if let index = windows.firstIndex(where: { $0.id == item.id }) {
            windows[index].bounds.origin = point
        }
    }

    /// Pencereyi yeniden boyutlandırır
    public func resizeWindow(_ item: WindowItem, to size: CGSize) {
        accessibilityManager.resizeWindow(pid: item.pid, windowId: item.id, title: item.windowTitle, to: size)
        if let index = windows.firstIndex(where: { $0.id == item.id }) {
            windows[index].bounds.size = size
        }
    }

    // MARK: - Hazır Yerleşim Şablonları (Tiling Presets)

    public func snapToLeftHalf(_ item: WindowItem) {
        guard let screen = NSScreen.main else { return }
        let visible = screen.visibleFrame
        let newFrame = CGRect(
            x: visible.minX,
            y: visible.minY,
            width: visible.width / 2,
            height: visible.height
        )
        applyFrame(newFrame, to: item)
    }

    public func snapToRightHalf(_ item: WindowItem) {
        guard let screen = NSScreen.main else { return }
        let visible = screen.visibleFrame
        let newFrame = CGRect(
            x: visible.minX + (visible.width / 2),
            y: visible.minY,
            width: visible.width / 2,
            height: visible.height
        )
        applyFrame(newFrame, to: item)
    }

    public func snapToMaximize(_ item: WindowItem) {
        guard let screen = NSScreen.main else { return }
        let visible = screen.visibleFrame
        applyFrame(visible, to: item)
    }

    public func snapToCenter(_ item: WindowItem) {
        guard let screen = NSScreen.main else { return }
        let visible = screen.visibleFrame
        let width = visible.width * 0.75
        let height = visible.height * 0.75
        let newFrame = CGRect(
            x: visible.midX - (width / 2),
            y: visible.midY - (height / 2),
            width: width,
            height: height
        )
        applyFrame(newFrame, to: item)
    }

    private func applyFrame(_ frame: CGRect, to item: WindowItem) {
        accessibilityManager.setWindowFrame(pid: item.pid, windowId: item.id, title: item.windowTitle, frame: frame)
        if let index = windows.firstIndex(where: { $0.id == item.id }) {
            windows[index].bounds = frame
        }
    }

    // MARK: - Pin

    /// Pencereyi sabitler / sabitlemeyi kaldırır
    public func togglePin(_ item: WindowItem) {
        if pinnedIDs.contains(item.id) {
            pinnedIDs.remove(item.id)
        } else {
            pinnedIDs.insert(item.id)
        }
        savePinnedIDs()
    }

    public func isPinned(_ item: WindowItem) -> Bool {
        pinnedIDs.contains(item.id)
    }

    private func loadPinnedIDs() {
        let stored = UserDefaults.standard.array(forKey: pinnedUDKey) as? [UInt32] ?? []
        pinnedIDs = Set(stored.map { CGWindowID($0) })
    }

    private func savePinnedIDs() {
        UserDefaults.standard.set(Array(pinnedIDs).map { UInt32($0) }, forKey: pinnedUDKey)
    }

    // MARK: - Recents

    /// Pencere ID'sini son kullanılanlar listesine ekler (max 6, FIFO)
    private func recordRecent(_ windowId: CGWindowID) {
        recentWindowIDs.removeAll { $0 == windowId }
        recentWindowIDs.insert(windowId, at: 0)
        if recentWindowIDs.count > 6 {
            recentWindowIDs = Array(recentWindowIDs.prefix(6))
        }
    }

    // MARK: - Screenshot

    /// Pencerenin tam çözünürlükte screenshot'nı alır ve panoya kopyalar
    public func screenshotWindow(_ item: WindowItem) {
        Task.detached(priority: .userInitiated) {
            let bigSize = CGSize(width: 1920, height: 1200)
            if let image = await WindowCaptureManager.shared.captureThumbnail(for: item.id, size: bigSize),
               let tiff = image.tiffRepresentation {
                await MainActor.run {
                    let pb = NSPasteboard.general
                    pb.clearContents()
                    pb.setData(tiff, forType: .tiff)
                }
            }
        }
    }
}
