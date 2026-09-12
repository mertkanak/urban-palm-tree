import SwiftUI

/// Açık pencereleri filtreleyen, arayan ve gruplama modunu değiştiren kontrol çubuğu
public struct WindowSearchBar: View {
    @ObservedObject var windowManager: WindowManager = .shared
    @ObservedObject var l10n: LocalizationManager = .shared

    public init() {}

    public var body: some View {
        HStack(spacing: 12) {
            // Arama Kutusu
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13))

                TextField(L10n.searchPlaceholder, text: $windowManager.searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))

                if !windowManager.searchQuery.isEmpty {
                    Button(action: {
                        windowManager.searchQuery = ""
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
            .frame(maxWidth: 300)

            // Görünüm Modu Seçici (Büyük / Küçük / Liste)
            HStack(spacing: 2) {
                ForEach(GridViewMode.allCases) { mode in
                    let isSelected = windowManager.gridViewMode == mode
                    Button(action: {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                            windowManager.gridViewMode = mode
                        }
                    }) {
                        Image(systemName: mode.systemIcon)
                            .font(.system(size: 12, weight: isSelected ? .bold : .regular))
                            .foregroundColor(isSelected ? .white : .secondary)
                            .frame(width: 28, height: 26)
                            .background(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .fill(isSelected ? Color.blue.opacity(0.75) : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                    .help(mode.localizedTitle)
                }
            }
            .padding(3)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            )

            // Uygulamaya Göre Gruplama Toggle'ı
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                    windowManager.isGroupingByApp.toggle()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: windowManager.isGroupingByApp ? "square.grid.2x2.fill" : "square.grid.2x2")
                    Text(L10n.groupByApp)
                        .font(.system(size: 12, weight: .medium))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(windowManager.isGroupingByApp ? Color.blue.opacity(0.25) : Color(nsColor: .controlBackgroundColor).opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(windowManager.isGroupingByApp ? Color.blue.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            Spacer()

            // Açık Pencere Sayacı Rozeti
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 7, height: 7)

                Text(L10n.openWindowsCount(windowManager.filteredWindows.count))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.3))
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }
}
