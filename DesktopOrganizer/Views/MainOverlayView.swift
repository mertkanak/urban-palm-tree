import SwiftUI

/// Uygulamanın ana overlay penceresi ve sekmeler arası yönlendirme görünümü
public struct MainOverlayView: View {
    @State private var selectedTab: Int = 0
    @State private var showingSessionSheet: Bool = false
    @ObservedObject var windowManager: WindowManager = .shared
    @ObservedObject var iconManager: DesktopIconManager = .shared
    @ObservedObject var permissionManager: PermissionManager = .shared
    @ObservedObject var sessionManager: SessionManager = .shared
    @ObservedObject var updater: AutoUpdater = .shared
    @ObservedObject var l10n: LocalizationManager = .shared

    public init() {}

    public var body: some View {
        ZStack {
            // 1. Buzlu Cam Arka Planı (macOS Vibrancy)
            VisualEffectBackground(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 2. Üst Ana Başlık ve Kontrol Alanı
                headerView

                Divider()
                    .opacity(0.3)

                // 3. Güncelleme Bannerı (varsa)
                UpdateBannerView()
                    .animation(.spring(response: 0.4), value: updater.updateAvailable)

                // 4. Sistem İzin Uyardı (Eksik İzin Varsa)
                PermissionWarningBanner()

                // 4. Seçili Sekme İçeriği
                if selectedTab == 0 {
                    VStack(spacing: 0) {
                        WindowSearchBar()
                        WindowGridView()
                    }
                } else {
                    DesktopOrganizerView()
                }

                Divider()
                    .opacity(0.3)

                // 5. Alt Bilgi / Durum Çubuğu
                statusBarView
            }
        }
        .frame(minWidth: 900, minHeight: 650)
    }

    // MARK: - Üst Başlık & Sekmeler

    private var headerView: some View {
        HStack(spacing: 16) {
            // Logo ve Başlık
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)

                    MonitorIconView(size: 22)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(L10n.appTitle)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)

                    Text(L10n.appSubtitle)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Ana Sekmeler (Pencereler vs Çekmece/Masaüstü)
            HStack(spacing: 4) {
                // 1. Sekme: Pencereler
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 0 } }) {
                    HStack(spacing: 6) {
                        Image(systemName: "macwindow.on.rectangle")
                            .font(.system(size: 13, weight: selectedTab == 0 ? .bold : .regular))
                        Text("\(L10n.windowsTab) (\(windowManager.windows.count))")
                            .font(.system(size: 12, weight: selectedTab == 0 ? .bold : .medium))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundColor(selectedTab == 0 ? .white : .secondary)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(selectedTab == 0 ? Color.blue.opacity(0.8) : Color.clear)
                    )
                }
                .buttonStyle(.plain)

                // 2. Sekme: Masaüstü (Kullanıcının verdiği Çekmece İkonu)
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 1 } }) {
                    HStack(spacing: 6) {
                        DrawerIconView(size: 15, color: selectedTab == 1 ? .white : .secondary)
                        Text("\(L10n.desktopTab) (\(iconManager.items.count))")
                            .font(.system(size: 12, weight: selectedTab == 1 ? .bold : .medium))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundColor(selectedTab == 1 ? .white : .secondary)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(selectedTab == 1 ? Color.purple.opacity(0.8) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(3)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.35))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )

            Spacer()

            // Hızlı Eylemler (Session + Yenile + Kapat + Dil)
            HStack(spacing: 8) {
                // Quick Switcher
                Button(action: {
                    (NSApplication.shared.delegate as? AppDelegate)?.toggleQuickSwitch()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.2.layers.3d")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                    )
                }
                .buttonStyle(.plain)
                .help(L10n.quickSwitchHelp)

                // Session Manager
                Button(action: { showingSessionSheet.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 11, weight: .semibold))
                        if !sessionManager.sessions.isEmpty {
                            Text("\(sessionManager.sessions.count)")
                                .font(.system(size: 10, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                    )
                }
                .buttonStyle(.plain)
                .help(L10n.sessionsHelp)
                .popover(isPresented: $showingSessionSheet, arrowEdge: .bottom) {
                    SessionManagerView()
                }

                Button(action: {
                    windowManager.refreshWindows()
                    iconManager.refreshFiles()
                    permissionManager.checkPermissions()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(.bordered)
                .help(L10n.refreshAll)

                // Tüm Açık Uygulamaları Force Quit Yap Butonu
                Button(action: {
                    windowManager.forceQuitAllApps()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.octagon.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text(L10n.forceQuitAll)
                            .font(.system(size: 11, weight: .semibold))
                        Text("⌥⇧Q")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(4)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color.red.opacity(0.85))
                    )
                }
                .buttonStyle(.plain)
                .help(L10n.forceQuitAllHelp)

                // Dil Seçici Butonu (🇺🇸 EN / 🇹🇷 TR)
                Button(action: {
                    l10n.toggleLanguage()
                }) {
                    HStack(spacing: 3) {
                        Text(l10n.currentLanguage.flag)
                            .font(.system(size: 11))
                        Text(l10n.currentLanguage.codeUpper)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .help(L10n.languageHelp)

                Button(action: {
                    NSApplication.shared.hide(nil)
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                }
                .buttonStyle(.bordered)
                .help(L10n.hidePanelHelp)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - Alt Durum Çubuğu

    private var statusBarView: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Circle()
                    .fill(permissionManager.state.allGranted ? Color.green : Color.orange)
                    .frame(width: 7, height: 7)

                Text(permissionManager.state.allGranted ? L10n.permissionsGranted : L10n.permissionsMissing)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(L10n.statusBarTip)
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.8))

            Spacer()

            Text("macOS 14+ • Swift Concurrency")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.3))
    }
}
