import SwiftUI

/// Güncelleme mevcut olduğunda gösterilen yeşil banner
public struct UpdateBannerView: View {
    @ObservedObject var updater: AutoUpdater = .shared
    @State private var isInstalling: Bool = false

    public init() {}

    public var body: some View {
        if updater.updateAvailable {
            HStack(spacing: 14) {
                // Animasyonlu roket ikonu
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 34, height: 34)
                    Text("🚀")
                        .font(.system(size: 17))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Yeni Güncelleme Mevcut!")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Sürüm \(updater.latestVersion) hazır  •  Mevcut: \(updater.currentVersion)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()

                if updater.isDownloading {
                    HStack(spacing: 8) {
                        ProgressView(value: updater.downloadProgress)
                            .progressViewStyle(.linear)
                            .frame(width: 100)
                        Text("\(Int(updater.downloadProgress * 100))%")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                    }
                } else {
                    Button(action: {
                        isInstalling = true
                        Task { await updater.downloadAndInstall() }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.down.circle.fill")
                            Text("Şimdi Güncelle ve Yeniden Başlat")
                        }
                        .font(.system(size: 12, weight: .semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(isInstalling)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.green.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.green.opacity(0.35), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}
