import SwiftUI

/// Son odaklanılan pencerelerin küçük yatay şeridini gösteren bileşen
public struct RecentWindowsStrip: View {
    @ObservedObject var windowManager: WindowManager = .shared

    public init() {}

    public var body: some View {
        let recents = windowManager.recentWindows
        if !recents.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text(L10n.recentWindows)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(recents) { item in
                            RecentMiniCard(item: item)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 2)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 4)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

/// Son kullanılanlar şeridindeki küçük kart
private struct RecentMiniCard: View {
    let item: WindowItem
    @ObservedObject var windowManager: WindowManager = .shared
    @State private var isHovered = false

    var body: some View {
        Button(action: { windowManager.focusWindow(item) }) {
            VStack(spacing: 0) {
                // Thumbnail veya renk
                Group {
                    if let thumb = item.thumbnail {
                        Image(nsImage: thumb)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 96, height: 60)
                            .clipped()
                    } else {
                        ZStack {
                            LinearGradient(
                                colors: [item.colorTint.opacity(0.4), item.colorTint.opacity(0.12)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            if let icon = item.appIcon {
                                Image(nsImage: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 28, height: 28)
                            } else {
                                Image(systemName: "macwindow")
                                    .font(.system(size: 22))
                                    .foregroundColor(item.colorTint.opacity(0.7))
                            }
                        }
                        .frame(width: 96, height: 60)
                    }
                }
                .cornerRadius(7, corners: [.topLeft, .topRight])

                // Alt etiket
                HStack(spacing: 4) {
                    if let icon = item.appIcon {
                        Image(nsImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 11, height: 11)
                    }
                    Text(item.appName)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .foregroundColor(.primary.opacity(0.85))
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
                .background(Color(nsColor: .windowBackgroundColor).opacity(0.5))
                .cornerRadius(7, corners: [.bottomLeft, .bottomRight])
            }
            .frame(width: 96)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(
                        isHovered ? item.colorTint.opacity(0.8) : Color.white.opacity(0.15),
                        lineWidth: isHovered ? 1.5 : 0.8
                    )
            )
            .shadow(
                color: isHovered ? item.colorTint.opacity(0.3) : Color.black.opacity(0.2),
                radius: isHovered ? 8 : 3,
                x: 0, y: 2
            )
            .scaleEffect(isHovered ? 1.04 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.75), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
