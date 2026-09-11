import SwiftUI

/// Kullanıcının sağladığı 3 çekmeceli dosya dolabı (Cabinet / Drawer) ikonu
public struct DrawerIconView: View {
    public var size: CGFloat = 16
    public var color: Color = .primary

    public init(size: CGFloat = 16, color: Color = .primary) {
        self.size = size
        self.color = color
    }

    public var body: some View {
        Canvas { context, sz in
            let w = sz.width * 0.8
            let h = sz.height * 0.92
            let x = (sz.width - w) / 2
            let y = (sz.height - h) / 2

            let rect = CGRect(x: x, y: y, width: w, height: h)
            let path = Path(roundedRect: rect, cornerRadius: sz.width * 0.12)

            // Dış Çerçeve
            context.stroke(path, with: .color(color), lineWidth: sz.width * 0.08)

            // 3 Çekmeceyi ayıran 2 yatay çizgi
            let drawerH = h / 3
            for i in 1...2 {
                let lineY = y + CGFloat(i) * drawerH
                var line = Path()
                line.move(to: CGPoint(x: x, y: lineY))
                line.addLine(to: CGPoint(x: x + w, y: lineY))
                context.stroke(line, with: .color(color), lineWidth: sz.width * 0.07)
            }

            // Kulplar
            for i in 0..<3 {
                let centerY = y + CGFloat(i) * drawerH + drawerH / 2
                let handleW = w * 0.38
                let handleH = drawerH * 0.24
                let handleRect = CGRect(x: (sz.width - handleW) / 2, y: centerY - handleH / 2, width: handleW, height: handleH)
                let handlePath = Path(roundedRect: handleRect, cornerRadius: handleH / 2)
                context.fill(handlePath, with: .color(color))
            }
        }
        .frame(width: size, height: size)
    }
}

/// Kullanıcının sağladığı retro Monitör / Masaüstü (Desktop) ikonu
public struct MonitorIconView: View {
    public var size: CGFloat = 20

    public init(size: CGFloat = 20) {
        self.size = size
    }

    public var body: some View {
        Canvas { context, sz in
            // 1. Ekran Gövdesi
            let bodyW = sz.width * 0.86
            let bodyH = sz.height * 0.60
            let bodyX = (sz.width - bodyW) / 2
            let bodyY = sz.height * 0.12

            let bodyRect = CGRect(x: bodyX, y: bodyY, width: bodyW, height: bodyH)
            let bodyPath = Path(roundedRect: bodyRect, cornerRadius: sz.width * 0.14)

            context.fill(
                bodyPath,
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 0.62, green: 0.64, blue: 0.68),
                        Color(red: 0.38, green: 0.40, blue: 0.44)
                    ]),
                    startPoint: CGPoint(x: sz.width / 2, y: bodyY),
                    endPoint: CGPoint(x: sz.width / 2, y: bodyY + bodyH)
                )
            )

            // İç Ekran Hafif Parlaklık
            let innerRect = bodyRect.insetBy(dx: sz.width * 0.05, dy: sz.width * 0.05)
            let innerPath = Path(roundedRect: innerRect, cornerRadius: sz.width * 0.09)
            context.fill(
                innerPath,
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 0.52, green: 0.54, blue: 0.58),
                        Color(red: 0.30, green: 0.32, blue: 0.35)
                    ]),
                    startPoint: CGPoint(x: sz.width / 2, y: innerRect.minY),
                    endPoint: CGPoint(x: sz.width / 2, y: innerRect.maxY)
                )
            )

            // 2. Monitör Ayağı / Taban Kapsülü
            let standW = sz.width * 0.48
            let standH = sz.height * 0.18
            let standX = (sz.width - standW) / 2
            let standY = sz.height * 0.74
            let standRect = CGRect(x: standX, y: standY, width: standW, height: standH)
            let standPath = Path(roundedRect: standRect, cornerRadius: standH / 2)

            context.fill(
                standPath,
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: 0.55, green: 0.57, blue: 0.60),
                        Color(red: 0.32, green: 0.34, blue: 0.37)
                    ]),
                    startPoint: CGPoint(x: sz.width / 2, y: standY),
                    endPoint: CGPoint(x: sz.width / 2, y: standY + standH)
                )
            )
        }
        .frame(width: size, height: size)
    }
}
