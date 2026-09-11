import SwiftUI

/// Küçük (kompakt) pencere önizleme kartı — Thumbnail ağırlıklı, sıkıştırılmış görünüm
public struct WindowMiniCardView: View {
    public let item: WindowItem
    @ObservedObject var windowManager: WindowManager = .shared

    @State private var isHovered: Bool = false

    public init(item: WindowItem) {
        self.item = item
    }

    public var body: some View {
        Button(action: {
            windowManager.focusWindow(item)
        }) {
            ZStack(alignment: .bottom) {
                // --- Thumbnail Alanı ---
                Group {
                    if let thumbnail = item.thumbnail {
                        Image(nsImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                    } else {
                        // Placeholder: renk gradyanı + büyük ikon
                        ZStack {
                            LinearGradient(
                                colors: [item.colorTint.opacity(0.40), item.colorTint.opacity(0.10)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            if let icon = item.appIcon {
                                Image(nsImage: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 36, height: 36)
                                    .opacity(0.85)
                            } else {
                                Image(systemName: "macwindow")
                                    .font(.system(size: 30))
                                    .foregroundColor(item.colorTint.opacity(0.7))
                            }
                        }
                    }
                }

                // --- Alt Bilgi Şeridi (frosted glass) ---
                HStack(spacing: 5) {
                    if let icon = item.appIcon {
                        Image(nsImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                    }
                    Text(item.windowTitle)
                        .font(.system(size: 10, weight: .semibold))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    // Aşağıdan yukarı gradient blur bar
                    LinearGradient(
                        colors: [Color.black.opacity(0.72), Color.black.opacity(0.0)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )

                // --- Hover'da kapat butonu ---
                if isHovered {
                    VStack {
                        HStack {
                            Spacer()
                            HStack(spacing: 3) {
                                // Force Quit Butonu
                                Button(action: { windowManager.forceQuitApp(item) }) {
                                    Image(systemName: "xmark.octagon.fill")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 16, height: 16)
                                        .background(Circle().fill(Color.purple.opacity(0.9)))
                                }
                                .buttonStyle(.plain)
                                .help("\(item.appName) Uygulamasını Tamamen Kapat (Force Quit)")
                                // Pencere Kapat (X) Butonu
                                Button(action: {
                                    if NSEvent.modifierFlags.contains(.option) {
                                        windowManager.forceQuitApp(item)
                                    } else {
                                        windowManager.closeWindow(item)
                                    }
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 16, height: 16)
                                        .background(Circle().fill(Color.red.opacity(0.85)))
                                }
                                .buttonStyle(.plain)
                                .help("Pencereyi Kapat (⌥ ile Force Quit)")
                            }
                            .padding(5)
                        }
                        Spacer()
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
            .frame(height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(
                        isHovered ? item.colorTint.opacity(0.8) : Color.white.opacity(0.15),
                        lineWidth: isHovered ? 1.5 : 0.8
                    )
            )
            .shadow(
                color: isHovered ? item.colorTint.opacity(0.35) : Color.black.opacity(0.25),
                radius: isHovered ? 10 : 4,
                x: 0,
                y: isHovered ? 4 : 2
            )
            .scaleEffect(isHovered ? 1.03 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.78), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.spring(response: 0.22, dampingFraction: 0.78)) {
                isHovered = hovering
            }
        }
    }
}

/// Liste görünümü için tek satır pencere öğesi
public struct WindowListRowView: View {
    public let item: WindowItem
    @ObservedObject var windowManager: WindowManager = .shared
    @State private var isHovered: Bool = false

    public init(item: WindowItem) {
        self.item = item
    }

    public var body: some View {
        Button(action: { windowManager.focusWindow(item) }) {
            HStack(spacing: 12) {
                // Küçük Thumbnail
                Group {
                    if let thumbnail = item.thumbnail {
                        Image(nsImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 72, height: 46)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(item.colorTint.opacity(0.2))
                            if let icon = item.appIcon {
                                Image(nsImage: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            } else {
                                Image(systemName: "macwindow")
                                    .font(.system(size: 20))
                                    .foregroundColor(item.colorTint)
                            }
                        }
                        .frame(width: 72, height: 46)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
                )

                // Uygulama İkonu + Başlık
                if let icon = item.appIcon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.windowTitle)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    Text(item.appName)
                        .font(.system(size: 11))
                        .foregroundColor(item.colorTint)
                }

                Spacer()

                // Boyut Bilgisi
                Text("\(Int(item.bounds.width))×\(Int(item.bounds.height))")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.trailing, 4)

                // Kapat Butonu (hover'da)
                if isHovered {
                    Button(action: { windowManager.closeWindow(item) }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
                }

                Image(systemName: "arrow.up.forward.app.fill")
                    .font(.system(size: 13))
                    .foregroundColor(isHovered ? item.colorTint : .secondary.opacity(0.4))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isHovered ? item.colorTint.opacity(0.10) : Color(nsColor: .controlBackgroundColor).opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(isHovered ? item.colorTint.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1)
            )
            .animation(.spring(response: 0.22, dampingFraction: 0.78), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation { isHovered = hovering }
        }
    }
}
