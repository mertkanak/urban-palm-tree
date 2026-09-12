import SwiftUI

/// Masaüstü dosya ve klasörlerini organize eden ikinci sekme görünümü
public struct DesktopOrganizerView: View {
    @ObservedObject var iconManager: DesktopIconManager = .shared

    public init() {}

    private let gridColumns = [
        GridItem(.adaptive(minimum: 130, maximum: 170), spacing: 14)
    ]

    public var body: some View {
        VStack(spacing: 0) {
            // 1. Üst Kontrol Çubuğu (Arama + Kategori Filtresi + Mod Geçişi + İkon Gizle Toggle)
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    // Arama Kutusu
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 13))

                        TextField(L10n.searchDesktopFilesPlaceholder, text: $iconManager.searchQuery)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13))

                        if !iconManager.searchQuery.isEmpty {
                            Button(action: {
                                iconManager.searchQuery = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(nsColor: .textBackgroundColor).opacity(0.4))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .frame(maxWidth: 280)

                    // Görünüm Modu Seçici (Grid vs Stack)
                    Picker("", selection: $iconManager.viewMode) {
                        ForEach(DesktopViewMode.allCases) { mode in
                            Label(mode.localizedTitle, systemImage: mode.iconName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 220)

                    Spacer()

                    // Boş masaüstüne tıklayınca ikonları geçici gizle/göster (Toggle)
                    Button(action: {
                        iconManager.toggleDesktopIcons()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: iconManager.areDesktopIconsHidden ? "eye.slash.fill" : "eye.fill")
                            Text(iconManager.areDesktopIconsHidden ? L10n.showDesktopIcons : L10n.hideDesktopIcons)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(iconManager.areDesktopIconsHidden ? Color.orange.opacity(0.25) : Color(nsColor: .controlBackgroundColor).opacity(0.35))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(iconManager.areDesktopIconsHidden ? Color.orange.opacity(0.6) : Color.white.opacity(0.15), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .help(L10n.desktopIconsToggleHelp)

                    // Yenile Butonu
                    Button(action: {
                        iconManager.refreshFiles()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.bordered)
                    .help(L10n.refreshDesktopFilesHelp)
                }

                // Kategori Filtre Hapları (Pills)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // "Tümü" butonu
                        Button(action: {
                            withAnimation(.spring(response: 0.25)) {
                                iconManager.selectedCategory = nil
                            }
                        }) {
                            Text("\(L10n.allApps) (\(iconManager.items.count))")
                                .font(.system(size: 11, weight: iconManager.selectedCategory == nil ? .bold : .medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(iconManager.selectedCategory == nil ? Color.blue.opacity(0.25) : Color(nsColor: .controlBackgroundColor).opacity(0.2))
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(iconManager.selectedCategory == nil ? Color.blue.opacity(0.6) : Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)

                        // Kategoriler
                        ForEach(FileCategory.allCases) { cat in
                            let count = iconManager.items.filter { $0.category == cat }.count
                            Button(action: {
                                withAnimation(.spring(response: 0.25)) {
                                    iconManager.selectedCategory = (iconManager.selectedCategory == cat ? nil : cat)
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: cat.systemIconName)
                                        .font(.system(size: 10))
                                    Text("\(cat.localizedTitle) (\(count))")
                                        .font(.system(size: 11, weight: iconManager.selectedCategory == cat ? .bold : .medium))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(iconManager.selectedCategory == cat ? cat.color.opacity(0.25) : Color(nsColor: .controlBackgroundColor).opacity(0.2))
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(iconManager.selectedCategory == cat ? cat.color.opacity(0.6) : Color.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 10)

            Divider()
                .opacity(0.3)

            // 2. İçerik Alanı: Yığın (Kategorili) veya Düz Izgara
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    if iconManager.filteredItems.isEmpty {
                        emptyState
                    } else if iconManager.viewMode == .stack && iconManager.selectedCategory == nil {
                        // Kategori Bölümleri (Stack Modu)
                        LazyVStack(spacing: 20) {
                            ForEach(iconManager.groupedItems, id: \.category.id) { group in
                                FileCategorySectionView(category: group.category, items: group.items)
                            }
                        }
                        .padding(.horizontal, 20)
                    } else {
                        // Düz Izgara Modu (Grid Modu)
                        LazyVGrid(columns: gridColumns, spacing: 14) {
                            ForEach(iconManager.filteredItems) { item in
                                FileItemCardView(item: item)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 16)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer(minLength: 60)

            Image(systemName: "folder")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))

            Text(L10n.desktopCleanTitle)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)

            Text(L10n.desktopCleanSubtitle)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 340)

            Spacer(minLength: 60)
        }
        .frame(maxWidth: .infinity)
    }
}
