import SwiftUI

/// Eksik sistem izinleri durumunda kullanıcıya rehberlik eden uyarı şeridi
public struct PermissionWarningBanner: View {
    @ObservedObject var permissionManager: PermissionManager = .shared

    public init() {}

    public var body: some View {
        if permissionManager.state.hasAnyMissing {
            VStack(spacing: 8) {
                HStack(alignment: .center, spacing: 14) {
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sistem İzinleri Gerekli")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)

                        Text("Pencereleri öne getirmek, taşımak, boyutlandırmak ve canlı thumbnail görüntüleri almak için izinler gereklidir.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        if !permissionManager.state.isAccessibilityGranted {
                            Button(action: {
                                permissionManager.requestAccessibilityPermission()
                                permissionManager.openAccessibilitySettings()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "hand.raised.fill")
                                    Text("Erişilebilirlik İzni")
                                }
                                .font(.system(size: 11, weight: .medium))
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                        }

                        if !permissionManager.state.isScreenCaptureGranted {
                            Button(action: {
                                permissionManager.requestScreenCapturePermission()
                                permissionManager.openScreenCaptureSettings()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "rectangle.inset.filled.and.cursorarrow")
                                    Text("Ekran Kaydı İzni")
                                }
                                .font(.system(size: 11, weight: .medium))
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.purple)
                        }

                        Button(action: {
                            permissionManager.checkPermissions()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .buttonStyle(.bordered)
                        .help("İzinleri Yeniden Kontrol Et")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.orange.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
}
