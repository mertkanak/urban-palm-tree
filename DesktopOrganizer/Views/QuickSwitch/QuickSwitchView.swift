import SwiftUI

/// Spotlight tarzı hızlı pencere geçiş paneli
/// ⌥+Tab ile açılır, ESC veya Enter ile kapanır
public struct QuickSwitchView: View {
    @ObservedObject var windowManager: WindowManager = .shared
    @State private var query: String = ""
    @State private var selectedIndex: Int = 0
    @FocusState private var isSearchFocused: Bool

    /// Panel kapanma callback'i
    public var onDismiss: () -> Void

    public init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }

    private var results: [WindowItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return Array(windowManager.windows.prefix(8)) }
        return windowManager.windows.filter {
            $0.windowTitle.localizedCaseInsensitiveContains(q) ||
            $0.appName.localizedCaseInsensitiveContains(q)
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Arama Çubuğu
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)

                TextField("Pencereye geç...", text: $query)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                    .focused($isSearchFocused)
                    .onSubmit { activateSelected() }

                if !query.isEmpty {
                    Button(action: { query = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if !results.isEmpty {
                Divider().opacity(0.3)

                // Sonuçlar Listesi
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 2) {
                        ForEach(Array(results.enumerated()), id: \.element.id) { idx, item in
                            QuickSwitchRow(
                                item: item,
                                isSelected: idx == selectedIndex,
                                shortcutNumber: idx < 9 ? idx + 1 : nil
                            )
                            .onTapGesture {
                                selectedIndex = idx
                                activateItem(item)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                }
                .frame(maxHeight: 340)
            }

            // Kısayol ipuçları
            HStack(spacing: 16) {
                Label("Seç", systemImage: "return")
                Label("Kapat", systemImage: "escape")
                Label("Gezin", systemImage: "arrowkeys")
            }
            .font(.system(size: 10))
            .foregroundColor(.secondary.opacity(0.7))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(VisualEffectBackground(material: .hudWindow, blendingMode: .behindWindow))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 24, x: 0, y: 12)
        .frame(width: 460)
        .onAppear {
            isSearchFocused = true
            selectedIndex = 0
        }
        .onChange(of: query) {
            selectedIndex = 0
        }
        // Klavye yönlendirmesi
        .onKeyPress(.upArrow) {
            if selectedIndex > 0 { selectedIndex -= 1 }
            return .handled
        }
        .onKeyPress(.downArrow) {
            if selectedIndex < results.count - 1 { selectedIndex += 1 }
            return .handled
        }
        .onKeyPress(.escape) {
            onDismiss()
            return .handled
        }
        .onKeyPress(.return) {
            activateSelected()
            return .handled
        }
    }

    private func activateSelected() {
        guard selectedIndex < results.count else { return }
        activateItem(results[selectedIndex])
    }

    private func activateItem(_ item: WindowItem) {
        windowManager.focusWindow(item)
        onDismiss()
    }
}

// MARK: - Row

private struct QuickSwitchRow: View {
    let item: WindowItem
    let isSelected: Bool
    let shortcutNumber: Int?

    var body: some View {
        HStack(spacing: 10) {
            // App İkonu
            Group {
                if let icon = item.appIcon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                } else {
                    Image(systemName: "macwindow")
                        .font(.system(size: 22))
                        .foregroundColor(item.colorTint)
                        .frame(width: 28, height: 28)
                }
            }

            // Thumbnail mini
            if let thumb = item.thumbnail {
                Image(nsImage: thumb)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 52, height: 34)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.windowTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(item.appName)
                    .font(.system(size: 11))
                    .foregroundColor(item.colorTint)
                    .lineLimit(1)
            }

            Spacer()

            if let num = shortcutNumber {
                Text("⌘\(num)")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary.opacity(0.6))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(nsColor: .controlBackgroundColor).opacity(0.4))
                    )
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isSelected
                      ? Color.blue.opacity(0.25)
                      : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
    }
}
