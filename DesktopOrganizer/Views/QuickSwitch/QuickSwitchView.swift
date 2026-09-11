import SwiftUI

/// Hızlı Pencere Değiştirici (Quick Window Switcher)
/// Sol-Sağ ve Yukarı-Aşağı yön tuşlarıyla veya Tab ile pencereler arasında gezinilir,
/// Enter ile seçilen pencereye zıplanır, ESC ile kapatılır.
public struct QuickSwitchView: View {
    @ObservedObject var windowManager: WindowManager = .shared
    @State private var selectedIndex: Int = 0
    @State private var searchText: String = ""

    public var onDismiss: () -> Void

    public init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }

    private var displayWindows: [WindowItem] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return windowManager.windows
        }
        return windowManager.windows.filter {
            $0.windowTitle.localizedCaseInsensitiveContains(trimmed) ||
            $0.appName.localizedCaseInsensitiveContains(trimmed)
        }
    }

    public var body: some View {
        VStack(spacing: 14) {
            // Üst Başlık & Arama / Bilgi Barı
            HStack(spacing: 10) {
                Image(systemName: "square.2.layers.3d")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.blue)

                Text("Hızlı Pencere Geçişi")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)

                Spacer()

                Text("\(displayWindows.count) Açık Pencere")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)

            // Pencerelerin Kare Önizleme Kartları (Yatay Kaydırılabilir Grid)
            if displayWindows.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "macwindow.on.rectangle")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary.opacity(0.6))
                    Text("Açık pencere bulunamadı")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .frame(height: 170)
            } else {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(Array(displayWindows.enumerated()), id: \.element.id) { index, item in
                                QuickSwitchCard(
                                    item: item,
                                    isSelected: index == selectedIndex
                                )
                                .id(index)
                                .onTapGesture {
                                    selectedIndex = index
                                    activateWindow(item)
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                    }
                    .onChange(of: selectedIndex) {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            proxy.scrollTo(selectedIndex, anchor: .center)
                        }
                    }
                }
                .frame(height: 175)
            }

            // Seçili Pencere Detay Başlığı
            if !displayWindows.isEmpty && selectedIndex < displayWindows.count {
                let current = displayWindows[selectedIndex]
                HStack(spacing: 8) {
                    if let icon = current.appIcon {
                        Image(nsImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                    }

                    Text(current.appName)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(current.colorTint)

                    Text("—")
                        .foregroundColor(.secondary)

                    Text(current.windowTitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()
                .opacity(0.25)
                .padding(.horizontal, 14)

            // Alt Bilgi / Kısayol İpuçları
            HStack(spacing: 20) {
                HStack(spacing: 4) {
                    Text("← → / ↑ ↓")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(4)
                    Text("Gezin")
                }

                HStack(spacing: 4) {
                    Text("Tab")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(4)
                    Text("Sonraki")
                }

                HStack(spacing: 4) {
                    Text("Enter ↵")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.35))
                        .cornerRadius(4)
                    Text("Pencereye Geç")
                }

                HStack(spacing: 4) {
                    Text("ESC")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(4)
                    Text("Kapat")
                }
            }
            .font(.system(size: 10))
            .foregroundColor(.secondary)
            .padding(.bottom, 12)
        }
        .frame(width: 620)
        .background(VisualEffectBackground(material: .hudWindow, blendingMode: .behindWindow))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(LinearGradient(colors: [Color.white.opacity(0.25), Color.white.opacity(0.08)], startPoint: .top, endPoint: .bottom), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.55), radius: 30, x: 0, y: 15)
        .onAppear {
            windowManager.refreshWindows()
            selectedIndex = 0
        }
        // Klavye kontrolü: Oklar, Tab, Return, ESC
        .onKeyPress(.leftArrow) {
            selectPrevious()
            return .handled
        }
        .onKeyPress(.upArrow) {
            selectPrevious()
            return .handled
        }
        .onKeyPress(.rightArrow) {
            selectNext()
            return .handled
        }
        .onKeyPress(.downArrow) {
            selectNext()
            return .handled
        }
        .onKeyPress(.tab) {
            selectNext()
            return .handled
        }
        .onKeyPress(.return) {
            confirmSelection()
            return .handled
        }
        .onKeyPress(.escape) {
            onDismiss()
            return .handled
        }
        .onKeyPress(.space) {
            confirmSelection()
            return .handled
        }
    }

    private func selectNext() {
        guard !displayWindows.isEmpty else { return }
        if selectedIndex < displayWindows.count - 1 {
            selectedIndex += 1
        } else {
            selectedIndex = 0 // Başa sar
        }
    }

    private func selectPrevious() {
        guard !displayWindows.isEmpty else { return }
        if selectedIndex > 0 {
            selectedIndex -= 1
        } else {
            selectedIndex = displayWindows.count - 1 // Sona sar
        }
    }

    private func confirmSelection() {
        guard !displayWindows.isEmpty, selectedIndex < displayWindows.count else {
            onDismiss()
            return
        }
        activateWindow(displayWindows[selectedIndex])
    }

    private func activateWindow(_ item: WindowItem) {
        windowManager.focusWindow(item)
        onDismiss()
    }
}

// MARK: - Kare Görünür Thumbnail Kartı

private struct QuickSwitchCard: View {
    let item: WindowItem
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            // Thumbnail / Ekran Görüntüsü Alanı
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.black.opacity(0.45))
                    .frame(width: 170, height: 110)

                if let thumb = item.thumbnail {
                    Image(nsImage: thumb)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 170, height: 110)
                        .clipped()
                        .cornerRadius(10)
                } else {
                    VStack(spacing: 4) {
                        Image(systemName: "macwindow")
                            .font(.system(size: 26))
                            .foregroundColor(item.colorTint.opacity(0.8))
                        Text(item.appName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 170, height: 110)
                }

                // Sol Üstte App İkonu Rozeti
                if let icon = item.appIcon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .frame(width: 26, height: 26)
                        )
                        .padding(6)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(
                        isSelected ? Color.blue : Color.white.opacity(0.12),
                        lineWidth: isSelected ? 3 : 1
                    )
            )
            .shadow(
                color: isSelected ? Color.blue.opacity(0.55) : Color.black.opacity(0.2),
                radius: isSelected ? 10 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
            .scaleEffect(isSelected ? 1.05 : 0.98)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: isSelected)

            // Başlık
            Text(item.windowTitle.isEmpty ? item.appName : item.windowTitle)
                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : .secondary)
                .lineLimit(1)
                .frame(width: 165)
        }
        .contentShape(Rectangle())
    }
}
