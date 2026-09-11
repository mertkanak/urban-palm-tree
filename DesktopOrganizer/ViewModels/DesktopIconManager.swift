import AppKit
import Combine
import Foundation
import SwiftUI

/// Masaüstü görünüm modu
public enum DesktopViewMode: String, CaseIterable, Identifiable {
    case grid = "Izgara"
    case stack = "Yığın (Kategorili)"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .grid: return "square.grid.3x3.fill"
        case .stack: return "square.stack.3d.up.fill"
        }
    }
}

/// Masaüstü dosyalarını organize eden, kategorize eden ve görünümünü yöneten ViewModel
@MainActor
public final class DesktopIconManager: ObservableObject {
    public static let shared = DesktopIconManager()

    @Published public private(set) var items: [DesktopFileItem] = []
    @Published public var selectedCategory: FileCategory? = nil
    @Published public var viewMode: DesktopViewMode = .stack
    @Published public var areDesktopIconsHidden: Bool = false
    @Published public var searchQuery: String = ""

    private let fileManager = DesktopFileManager.shared

    public init() {
        refreshFiles()
        startWatching()
    }

    // MARK: - Filtrelenmiş ve Gruplanmış Öğeler

    public var filteredItems: [DesktopFileItem] {
        var result = items

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(query) }
        }

        return result
    }

    /// Kategori bazında gruplanmış liste
    public var groupedItems: [(category: FileCategory, items: [DesktopFileItem])] {
        let grouped = Dictionary(grouping: filteredItems, by: { $0.category })
        return FileCategory.allCases.compactMap { cat in
            if let list = grouped[cat], !list.isEmpty {
                return (category: cat, items: list)
            }
            return nil
        }
    }

    // MARK: - Dosya İşlemleri

    public func refreshFiles() {
        let newItems = fileManager.fetchDesktopItems()
        self.items = newItems
    }

    public func startWatching() {
        fileManager.startWatchingDesktop { [weak self] in
            Task { @MainActor in
                self?.refreshFiles()
            }
        }
    }

    /// Dosyayı varsayılan uygulamasıyla açar
    public func openItem(_ item: DesktopFileItem) {
        NSWorkspace.shared.open(item.url)
    }

    /// Dosyayı Finder içinde gösterir
    public func showInFinder(_ item: DesktopFileItem) {
        NSWorkspace.shared.activateFileViewerSelecting([item.url])
    }

    /// Masaüstü ikonlarını Finder üzerinde gizler veya gösterir
    public func toggleDesktopIcons() {
        areDesktopIconsHidden.toggle()
        fileManager.toggleDesktopIconsVisibility(hide: areDesktopIconsHidden)
    }
}
