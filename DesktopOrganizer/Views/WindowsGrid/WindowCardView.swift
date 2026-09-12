import SwiftUI

/// Açık bir pencereyi büyük ikon, başlık, canlı thumbnail ve aksiyonlarla temsil eden kart bileşeni
public struct WindowCardView: View {
    public let item: WindowItem
    @ObservedObject var windowManager: WindowManager = .shared

    @State private var isHovered: Bool = false
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false

    public init(item: WindowItem) {
        self.item = item
    }

    public var body: some View {
        VStack(spacing: 0) {
            // 1. Üst Kısım: Thumbnail Önizleme Alanı
            ZStack(alignment: .topTrailing) {
                Group {
                    if let thumbnail = item.thumbnail {
                        Image(nsImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 155)
                            .clipped()
                    } else {
                        // Thumbnail henüz yoksa veya izin bekleniyorsa şık soyut önizleme
                        ZStack {
                            LinearGradient(
                                colors: [item.colorTint.opacity(0.35), item.colorTint.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )

                            VStack(spacing: 8) {
                                if let icon = item.appIcon {
                                    Image(nsImage: icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 54, height: 54)
                                        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                                } else {
                                    Image(systemName: "macwindow")
                                        .font(.system(size: 44))
                                        .foregroundColor(item.colorTint)
                                }

                                Text(item.appName)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.primary.opacity(0.85))
                            }
                        }
                        .frame(height: 155)
                    }
                }
                .cornerRadius(12, corners: [.topLeft, .topRight])

                // Hover'da görünen Kapat (X) butonu
                if isHovered {
                    HStack(spacing: 6) {
                        // Hazır Boyutlandırma / Tiling Menüsü
                        Menu {
                            Button(L10n.snapLeft) {
                                windowManager.snapToLeftHalf(item)
                            }
                            Button(L10n.snapRight) {
                                windowManager.snapToRightHalf(item)
                            }
                            Button(L10n.maximize) {
                                windowManager.snapToMaximize(item)
                            }
                            Button(L10n.center) {
                                windowManager.snapToCenter(item)
                            }
                            Divider()
                            Button(L10n.minimize) {
                                windowManager.minimizeWindow(item)
                            }
                            Divider()
                            Button(windowManager.isPinned(item) ? L10n.unpin : L10n.pinToTop) {
                                withAnimation(.spring(response: 0.3)) {
                                    windowManager.togglePin(item)
                                }
                            }
                            Button(L10n.copyScreenshot) {
                                windowManager.screenshotWindow(item)
                            }
                        } label: {
                            Image(systemName: "rectangle.split.2x1")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 22, height: 22)
                                .background(Circle().fill(Color.black.opacity(0.65)))
                        }
                        .menuStyle(.borderlessButton)
                        .frame(width: 22, height: 22)

                        // Force Quit Butonu (Tamamen Kapat - Dock'tan Kaldır)
                        Button(action: {
                            windowManager.forceQuitApp(item)
                        }) {
                            Image(systemName: "xmark.octagon.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 22, height: 22)
                                .background(Circle().fill(Color.purple.opacity(0.9)))
                        }
                        .buttonStyle(.plain)
                        .help(L10n.forceQuitHelp(app: item.appName))

                        // Kapat (X) Butonu (⌥ ile tıklanırsa da Force Quit yapar)
                        Button(action: {
                            if NSEvent.modifierFlags.contains(.option) {
                                windowManager.forceQuitApp(item)
                            } else {
                                windowManager.closeWindow(item)
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 22, height: 22)
                                .background(Circle().fill(Color.red.opacity(0.85)))
                        }
                        .buttonStyle(.plain)
                        .help(L10n.closeWindowHelp)
                    }
                    .padding(8)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                // Sabitlenmiş rozet (pin badge)
                if windowManager.isPinned(item) {
                    VStack {
                        HStack {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Circle().fill(Color.orange.opacity(0.9)))
                                .padding(6)
                            Spacer()
                        }
                        Spacer()
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }

            // 2. Alt Kısım: Büyük İkon, Pencere Başlığı ve Uygulama Etiketi
            HStack(alignment: .center, spacing: 12) {
                // Büyük Uygulama İkonu
                if let icon = item.appIcon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                } else {
                    Image(systemName: "app.fill")
                        .font(.system(size: 32))
                        .foregroundColor(item.colorTint)
                }

                // Başlık ve Etiket
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.windowTitle)
                        .font(.system(size: 13, weight: .bold))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(.primary)

                    HStack(spacing: 6) {
                        // Uygulama Adı Küçük Etiketi
                        Text(item.appName)
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(item.colorTint.opacity(0.25))
                            )
                            .foregroundColor(item.colorTint)

                        // Boyut / Koordinat İpucu
                        Text("\(Int(item.bounds.width))×\(Int(item.bounds.height))")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer(minLength: 0)

                // Öne Getir Butonu / İkonu
                Image(systemName: "arrow.up.forward.app.fill")
                    .font(.system(size: 14))
                    .foregroundColor(isHovered ? item.colorTint : .secondary.opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                Color(nsColor: .windowBackgroundColor).opacity(0.4)
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.25))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(
                    isHovered ? item.colorTint.opacity(0.7) : Color.white.opacity(0.12),
                    lineWidth: isHovered ? 1.5 : 1.0
                )
        )
        .shadow(
            color: isHovered ? item.colorTint.opacity(0.3) : Color.black.opacity(0.2),
            radius: isHovered ? 12 : 5,
            x: 0,
            y: isHovered ? 6 : 2
        )
        .scaleEffect(isDragging ? 1.04 : (isHovered ? 1.02 : 1.0))
        .offset(dragOffset)
        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isHovered)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: dragOffset)
        .onHover { hovering in
            self.isHovered = hovering
        }
        // 1. Tıklama: Pencereyi öne getir ve odakla
        .onTapGesture {
            windowManager.focusWindow(item)
        }
        // 2. Sürükle-Bırak: Gerçek pencereyi ekranda o pozisyona taşı
        .gesture(
            DragGesture(minimumDistance: 8)
                .onChanged { value in
                    self.isDragging = true
                    self.dragOffset = value.translation
                }
                .onEnded { value in
                    self.isDragging = false
                    withAnimation(.spring()) {
                        self.dragOffset = .zero
                    }

                    // Sürüklenen mesafeyi gerçek ekran koordinatlarına uyarla
                    guard let screen = NSScreen.main else { return }
                    let screenBounds = screen.visibleFrame

                    // Yeni hedef konum: Ekran üzerindeki bağıl hareket
                    let factor: CGFloat = 2.0 // Canvas hareketini ekrana ölçekle
                    let targetX = max(screenBounds.minX, min(screenBounds.maxX - 100, item.bounds.origin.x + (value.translation.width * factor)))
                    let targetY = max(screenBounds.minY, min(screenBounds.maxY - 100, item.bounds.origin.y + (value.translation.height * factor)))

                    let targetPoint = CGPoint(x: targetX, y: targetY)
                    windowManager.moveWindow(item, to: targetPoint)
                }
        )
    }
}

// Yardımcı uzantı: Sadece belirli köşeleri yuvarlatma
extension View {
    func cornerRadius(_ radius: CGFloat, corners: Set<RectCorner>) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

public enum RectCorner: Sendable {
    case topLeft, topRight, bottomLeft, bottomRight
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: Set<RectCorner>

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let p1 = CGPoint(x: rect.minX, y: rect.minY)
        let p2 = CGPoint(x: rect.maxX, y: rect.minY)
        let p3 = CGPoint(x: rect.maxX, y: rect.maxY)
        let p4 = CGPoint(x: rect.minX, y: rect.maxY)

        path.move(to: CGPoint(x: rect.minX + (corners.contains(.topLeft) ? radius : 0), y: rect.minY))

        // Üst kenar & sağ üst köşe
        path.addLine(to: CGPoint(x: rect.maxX - (corners.contains(.topRight) ? radius : 0), y: rect.minY))
        if corners.contains(.topRight) {
            path.addArc(tangent1End: p2, tangent2End: p3, radius: radius)
        }

        // Sağ kenar & sağ alt köşe
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - (corners.contains(.bottomRight) ? radius : 0)))
        if corners.contains(.bottomRight) {
            path.addArc(tangent1End: p3, tangent2End: p4, radius: radius)
        }

        // Alt kenar & sol alt köşe
        path.addLine(to: CGPoint(x: rect.minX + (corners.contains(.bottomLeft) ? radius : 0), y: rect.maxY))
        if corners.contains(.bottomLeft) {
            path.addArc(tangent1End: p4, tangent2End: p1, radius: radius)
        }

        // Sol kenar & sol üst köşe
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + (corners.contains(.topLeft) ? radius : 0)))
        if corners.contains(.topLeft) {
            path.addArc(tangent1End: p1, tangent2End: p2, radius: radius)
        }

        path.closeSubpath()
        return path
    }
}
