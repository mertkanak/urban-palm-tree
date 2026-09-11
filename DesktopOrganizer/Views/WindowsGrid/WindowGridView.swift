import SwiftUI

/// Açık pencereleri üç farklı görünüm modunda sunan ana grid görünümü
public struct WindowGridView: View {
    @ObservedObject var windowManager: WindowManager = .shared

    public init() {}

    // MARK: - Büyük Kart Kolonları

    private var largeColumns: [GridItem] {
        let count = windowManager.filteredWindows.count
        let minWidth: CGFloat
        if count <= 4 {
            minWidth = 360
        } else if count <= 10 {
            minWidth = 300
        } else {
            minWidth = 260
        }
        return [GridItem(.adaptive(minimum: minWidth, maximum: 460), spacing: 18)]
    }

    // MARK: - Küçük Thumbnail Kolonları

    private var compactColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 160, maximum: 240), spacing: 10)]
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            // Son kullanılanlar şeridi (varsa)
            RecentWindowsStrip()

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 22) {
                    if windowManager.filteredWindows.isEmpty {
                        emptyStateView
                    } else if windowManager.isGroupingByApp {
                        groupedContent
                    } else {
                        flatContent
                    }
                }
                .padding(.vertical, 16)
            }
        }
    }

    // MARK: - Grouped Content

    @ViewBuilder
    private var groupedContent: some View {
        LazyVStack(alignment: .leading, spacing: 24) {
            ForEach(windowManager.groupedWindows, id: \.appName) { group in
                VStack(alignment: .leading, spacing: 12) {
                    // Grup Başlığı
                    HStack(spacing: 8) {
                        if let icon = group.icon {
                            Image(nsImage: icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                        Text(group.appName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                        Text("(\(group.windows.count))")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(group.color)
                        Spacer()
                    }
                    .padding(.horizontal, 4)

                    // Grup içi görünüm modu
                    gridForWindows(group.windows)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(group.color.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(group.color.opacity(0.18), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Flat Content

    @ViewBuilder
    private var flatContent: some View {
        gridForWindows(windowManager.filteredWindows)
            .padding(.horizontal, 20)
    }

    // MARK: - Grid / List / Compact Switcher

    @ViewBuilder
    private func gridForWindows(_ items: [WindowItem]) -> some View {
        switch windowManager.gridViewMode {

        case .large:
            LazyVGrid(columns: largeColumns, spacing: 18) {
                ForEach(items) { windowItem in
                    WindowCardView(item: windowItem)
                }
            }

        case .compact:
            LazyVGrid(columns: compactColumns, spacing: 10) {
                ForEach(items) { windowItem in
                    WindowMiniCardView(item: windowItem)
                }
            }

        case .list:
            LazyVStack(spacing: 6) {
                ForEach(items) { windowItem in
                    WindowListRowView(item: windowItem)
                }
            }
        }
    }

    // MARK: - Boş Durum

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 60)

            Image(systemName: windowManager.searchQuery.isEmpty ? "macwindow.on.rectangle" : "magnifyingglass")
                .font(.system(size: 52))
                .foregroundColor(.secondary.opacity(0.6))

            Text(windowManager.searchQuery.isEmpty ? "Açık Pencere Bulunamadı" : "Aramanızla Eşleşen Pencere Yok")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)

            Text(windowManager.searchQuery.isEmpty
                 ? "Diğer uygulamalarda pencereler açıldığında otomatik olarak burada görünecektir."
                 : "'\(windowManager.searchQuery)' araması için açık olan hiçbir pencere bulunamadı.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)

            Button(action: {
                windowManager.searchQuery = ""
                windowManager.refreshWindows()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("Yenile")
                }
                .font(.system(size: 12, weight: .medium))
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)

            Spacer(minLength: 60)
        }
        .frame(maxWidth: .infinity)
    }
}
