import SwiftUI

/// Kartlar için modern hover ve gölge animasyonları
public struct CardHoverEffect: ViewModifier {
    @State private var isHovered: Bool = false
    public var cornerRadius: CGFloat = 16
    public var accentColor: Color = .blue

    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(isHovered ? 0.35 : 0.20))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        isHovered ? accentColor.opacity(0.6) : Color.white.opacity(0.12),
                        lineWidth: isHovered ? 1.5 : 1.0
                    )
            )
            .shadow(
                color: isHovered ? accentColor.opacity(0.25) : Color.black.opacity(0.18),
                radius: isHovered ? 12 : 6,
                x: 0,
                y: isHovered ? 6 : 3
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isHovered)
            .onHover { hovering in
                self.isHovered = hovering
            }
    }
}

public extension View {
    func cardHoverStyle(cornerRadius: CGFloat = 16, accentColor: Color = .blue) -> some View {
        self.modifier(CardHoverEffect(cornerRadius: cornerRadius, accentColor: accentColor))
    }
}
