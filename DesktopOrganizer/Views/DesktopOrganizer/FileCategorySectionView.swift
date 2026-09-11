import SwiftUI

/// Masaüstü dosya kategorisini ve içerisindeki dosyaları sunan bölüm bileşeni
public struct FileCategorySectionView: View {
    public let category: FileCategory
    public let items: [DesktopFileItem]
    @ObservedObject var iconManager: DesktopIconManager = .shared

    public init(category: FileCategory, items: [DesktopFileItem]) {
        self.category = category
        self.items = items
    }

    private let columns = [
        GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 14)
    ]

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Kategori Başlığı ve Rozeti
            HStack(spacing: 8) {
                Image(systemName: category.systemIconName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(category.color)

                Text(category.rawValue)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)

                Text("\(items.count)")
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(category.color.opacity(0.18)))
                    .foregroundColor(category.color)

                Spacer()
            }

            // Dosya Kartları Izgarası
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(items) { item in
                    FileItemCardView(item: item)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(category.color.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(category.color.opacity(0.15), lineWidth: 1)
        )
    }
}

/// Tekil masaüstü dosyası kartı
public struct FileItemCardView: View {
    public let item: DesktopFileItem
    @ObservedObject var iconManager: DesktopIconManager = .shared
    @State private var isHovered: Bool = false

    public var body: some View {
        VStack(spacing: 8) {
            // Dosya İkonu
            Image(nsImage: item.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)

            // Dosya Adı
            Text(item.name)
                .font(.system(size: 11, weight: .medium))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)

            // Boyut veya Tür
            Text(item.sizeString)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 110)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(isHovered ? 0.35 : 0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(isHovered ? item.category.color.opacity(0.6) : Color.white.opacity(0.08), lineWidth: 1)
        )
        .scaleEffect(isHovered ? 1.03 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isHovered)
        .onHover { hovering in
            self.isHovered = hovering
        }
        .onTapGesture(count: 2) {
            iconManager.openItem(item)
        }
        .contextMenu {
            Button("Aç") {
                iconManager.openItem(item)
            }
            Button("Finder'da Göster") {
                iconManager.showInFinder(item)
            }
        }
        .help("\(item.name)\nÇift tıklayarak açın")
    }
}
