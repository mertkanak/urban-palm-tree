import Foundation
import SwiftUI
import Combine

/// Desteklenen diller
public enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case english = "en"
    case turkish = "tr"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        }
    }

    public var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .turkish: return "🇹🇷"
        }
    }

    public var codeUpper: String {
        rawValue.uppercased()
    }
}

/// Tüm uygulama için merkezi yerelleştirme yöneticisi
@MainActor
public final class LocalizationManager: ObservableObject {
    public static let shared = LocalizationManager()

    private let storageKey = "com.mertkanak.desktoporganizer.selectedLanguage"

    @Published public private(set) var currentLanguage: AppLanguage = .english

    private init() {
        if let saved = UserDefaults.standard.string(forKey: storageKey),
           let lang = AppLanguage(rawValue: saved) {
            self.currentLanguage = lang
        } else {
            // Sistem dili kontrolü: Eğer sistem dili Türkçe ise Türkçe, değilse uluslararası standart olarak İngilizce
            let preferred = Locale.preferredLanguages.first?.lowercased() ?? ""
            if preferred.hasPrefix("tr") {
                self.currentLanguage = .turkish
            } else {
                self.currentLanguage = .english
            }
        }
    }

    /// Dili değiştirir, UserDefaults'a kaydeder ve tüm arayüzü anında günceller
    public func setLanguage(_ language: AppLanguage) {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.currentLanguage = language
        }
        UserDefaults.standard.set(language.rawValue, forKey: storageKey)
    }

    /// Bir sonraki dile geçiş yapar (EN <-> TR)
    public func toggleLanguage() {
        setLanguage(currentLanguage == .english ? .turkish : .english)
    }
}

/// Tüm uygulama metinlerini tip güvenli şekilde tutan sözlük yapısı
@MainActor
public enum L10n {
    private static var lang: AppLanguage {
        LocalizationManager.shared.currentLanguage
    }

    // MARK: - Genel & Başlıklar
    public static var appTitle: String {
        "Desktop Organizer"
    }

    public static var appSubtitle: String {
        lang == .turkish ? "Pencere & Masaüstü Yöneticisi" : "Smart Window & Desktop Organizer"
    }

    public static var windowsTab: String {
        lang == .turkish ? "Pencereler" : "Windows"
    }

    public static var desktopTab: String {
        lang == .turkish ? "Masaüstü" : "Desktop"
    }

    // MARK: - Üst Araç Çubuğu Butonları
    public static var quickSwitchHelp: String {
        lang == .turkish ? "Hızlı Pencere Değiştirici (⌥Tab / ⌃Tab)" : "Quick Window Switcher (⌥Tab / ⌃Tab)"
    }

    public static var sessionsHelp: String {
        lang == .turkish ? "Kaydedilmiş Çalışma Alanları" : "Saved Window Workspaces"
    }

    public static var refreshAll: String {
        lang == .turkish ? "Tümünü Yenile" : "Refresh All"
    }

    public static var forceQuitAll: String {
        lang == .turkish ? "Tümünü Kapat" : "Force Quit All"
    }

    public static var forceQuitAllHelp: String {
        lang == .turkish ? "Açık olan tüm uygulamaları tamamen zorla kapat (⌥⇧Q)" : "Force quit all open applications from Dock and background (⌥⇧Q)"
    }

    public static var hidePanelHelp: String {
        lang == .turkish ? "Paneli Gizle (Menü çubuğundan veya kısayolla tekrar açılabilir)" : "Hide Panel (Can be reopened via shortcut or menu bar)"
    }

    public static var languageHelp: String {
        lang == .turkish ? "Dili Değiştir (Language)" : "Switch Language"
    }

    // MARK: - Arama & Filtreleme
    public static var searchPlaceholder: String {
        lang == .turkish ? "Pencere veya uygulama ara..." : "Search windows or apps..."
    }

    public static var allApps: String {
        lang == .turkish ? "Tümü" : "All"
    }

    public static var noWindowsFoundTitle: String {
        lang == .turkish ? "Açık Pencere Bulunamadı" : "No Open Windows Found"
    }

    public static var noWindowsFoundSubtitle: String {
        lang == .turkish ? "Diğer uygulamalarda pencereler açıldığında otomatik olarak burada görünecektir." : "Windows will automatically appear here when opened in other applications."
    }

    public static func searchNoMatch(query: String) -> String {
        lang == .turkish ? "'\(query)' araması için açık olan hiçbir pencere bulunamadı." : "No open windows found matching '\(query)'."
    }

    public static var recentWindows: String {
        lang == .turkish ? "Son Kullanılanlar" : "Recently Focused"
    }

    // MARK: - Pencere Kartı & Tiling Aksiyonları
    public static var snapLeft: String {
        lang == .turkish ? "◧ Sol Yarıya Yerleştir" : "◧ Snap to Left Half"
    }

    public static var snapRight: String {
        lang == .turkish ? "◨ Sağ Yarıya Yerleştir" : "◨ Snap to Right Half"
    }

    public static var maximize: String {
        lang == .turkish ? "⬚ Tam Ekran Yap" : "⬚ Maximize Window"
    }

    public static var center: String {
        lang == .turkish ? "◲ Ortala" : "◲ Center on Screen"
    }

    public static var minimize: String {
        lang == .turkish ? "➖ Simge Durumuna Küçült" : "➖ Minimize Window"
    }

    public static var pinToTop: String {
        lang == .turkish ? "📌 Yukarıya Sabitle" : "📌 Pin to Top"
    }

    public static var unpin: String {
        lang == .turkish ? "📌 Sabitlemeyi Kaldır" : "📌 Unpin from Top"
    }

    public static var copyScreenshot: String {
        lang == .turkish ? "📸 Screenshot Al (Panoya)" : "📸 Copy Screenshot (Clipboard)"
    }

    public static func forceQuitHelp(app: String) -> String {
        lang == .turkish ? "\(app) Uygulamasını Tamamen Zorla Kapat (Force Quit - Dock'ta Kalmaz)" : "Force Quit \(app) completely (Closes process and removes from Dock)"
    }

    public static var closeWindowHelp: String {
        lang == .turkish ? "Pencereyi Kapat (⌥ Tıklama: Tamamen Force Quit)" : "Close Window (⌥ Click: Force Quit App)"
    }

    // MARK: - Hızlı Pencere Değiştirici (Quick Switcher HUD)
    public static var quickSwitchTitle: String {
        lang == .turkish ? "Hızlı Pencere Geçişi" : "Quick Window Switcher"
    }

    public static func openWindowsCount(_ count: Int) -> String {
        lang == .turkish ? "\(count) Açık Pencere" : "\(count) Open Windows"
    }

    public static var quickSwitchEmpty: String {
        lang == .turkish ? "Açık pencere bulunamadı" : "No open windows found"
    }

    public static var hintNavigate: String {
        lang == .turkish ? "Gezin" : "Navigate"
    }

    public static var hintNext: String {
        lang == .turkish ? "Sonraki" : "Next"
    }

    public static var hintSwitch: String {
        lang == .turkish ? "Pencereye Geç" : "Switch to Window"
    }

    public static var hintForceQuit: String {
        lang == .turkish ? "Force Quit" : "Force Quit"
    }

    public static var hintClose: String {
        lang == .turkish ? "Kapat" : "Close"
    }

    // MARK: - Masaüstü Düzenleyici (Desktop Clean Up)
    public static var hideDesktopIcons: String {
        lang == .turkish ? "Masaüstü Simgelerini Gizle" : "Hide Desktop Icons"
    }

    public static var showDesktopIcons: String {
        lang == .turkish ? "Masaüstü Simgelerini Göster" : "Show Desktop Icons"
    }

    public static var autoOrganize: String {
        lang == .turkish ? "Masaüstünü Otomatik Düzenle" : "Organize Desktop Automatically"
    }

    public static var autoOrganizeHelp: String {
        lang == .turkish ? "Masaüstündeki tüm dosyaları kategorilere göre alt klasörlere taşır" : "Moves all files on desktop into organized category folders"
    }

    public static var emptyCategory: String {
        lang == .turkish ? "Bu kategoride dosya yok" : "No files in this category"
    }

    public static var desktopCleanTitle: String {
        lang == .turkish ? "Masaüstü Temiz" : "Desktop is Clean"
    }

    public static var desktopCleanSubtitle: String {
        lang == .turkish ? "Masaüstünüzde düzenlenecek dosya bulunmuyor." : "No files found on your desktop to organize."
    }

    // MARK: - Dosya Kategorileri (File Categories)
    public static func categoryName(_ category: String) -> String {
        switch category {
        case "images", "Resimler":
            return lang == .turkish ? "Resimler" : "Images & Photos"
        case "documents", "Dokümanlar":
            return lang == .turkish ? "Dokümanlar" : "Documents"
        case "downloads", "İndirilenler / Arşivler":
            return lang == .turkish ? "İndirilenler / Arşivler" : "Downloads & Archives"
        case "applications", "Uygulamalar":
            return lang == .turkish ? "Uygulamalar" : "Applications"
        case "developer", "Kod & Geliştirme":
            return lang == .turkish ? "Kod & Geliştirme" : "Code & Development"
        case "other", "Diğer":
            return lang == .turkish ? "Diğer" : "Other Files"
        default:
            return category
        }
    }

    // MARK: - Çalışma Alanları (Session Management)
    public static var sessionsTitle: String {
        lang == .turkish ? "Kayıtlı Çalışma Alanları" : "Saved Workspaces"
    }

    public static var saveCurrentSession: String {
        lang == .turkish ? "Mevcut Düzeni Kaydet" : "Save Current Layout"
    }

    public static var sessionNamePlaceholder: String {
        lang == .turkish ? "Çalışma alanı adı (ör. Proje X, Araştırma)..." : "Workspace name (e.g. Project A, Research)..."
    }

    public static var restoreSession: String {
        lang == .turkish ? "Düzeni Geri Yükle" : "Restore Workspace"
    }

    public static var deleteSession: String {
        lang == .turkish ? "Sil" : "Delete"
    }

    public static var noSessionsYet: String {
        lang == .turkish ? "Henüz kayıtlı bir çalışma alanı yok" : "No saved workspaces yet"
    }

    public static func sessionSummary(count: Int, date: String) -> String {
        let countText: String
        if lang == .turkish {
            countText = "\(count) pencere"
        } else {
            countText = count == 1 ? "1 window" : "\(count) windows"
        }
        return "\(countText) • \(date)"
    }

    // MARK: - Menü Çubuğu (Menu Bar Context Menu)
    public static var menuToggle: String {
        lang == .turkish ? "Desktop Organizer'ı Aç/Kapat" : "Toggle Desktop Organizer"
    }

    public static var menuQuickSwitch: String {
        lang == .turkish ? "Hızlı Pencere Değiştirici (⌥+Tab / ⌃+Tab)" : "Quick Window Switcher (⌥+Tab / ⌃+Tab)"
    }

    public static var menuRefreshWindows: String {
        lang == .turkish ? "Pencereleri Yenile" : "Refresh Windows"
    }

    public static var menuToggleDesktopIcons: String {
        lang == .turkish ? "Masaüstü İkonlarını Gizle/Göster" : "Toggle Desktop Icons"
    }

    public static var menuForceQuitAll: String {
        lang == .turkish ? "Tüm Açık Uygulamaları Kapat (⌥+⇧+Q)" : "Force Quit All Open Apps (⌥+⇧+Q)"
    }

    public static var menuLanguage: String {
        lang == .turkish ? "Dil / Language" : "Language / Dil"
    }

    public static var menuQuit: String {
        lang == .turkish ? "Çıkış" : "Quit"
    }

    // MARK: - İzinler & Güncelleme
    public static var permissionsTitle: String {
        lang == .turkish ? "Gerekli İzinler" : "Required Permissions"
    }

    public static var systemPermissionsTitle: String {
        lang == .turkish ? "Sistem İzinleri Gerekli" : "System Permissions Required"
    }

    public static var systemPermissionsSubtitle: String {
        lang == .turkish
            ? "Pencereleri öne getirmek ve canlı önizlemeler için izinler gereklidir.\n⚠️ Ayarlarda zaten açık görünüyorsa: Anahtarı bir kez kapatıp tekrar açmanız yeterlidir."
            : "Permissions are required for window management and live previews.\n⚠️ If already enabled in Settings: Simply toggle the switch off and on once."
    }

    public static var accessibilityPermission: String {
        lang == .turkish ? "Erişilebilirlik İzni" : "Accessibility Permission"
    }

    public static var screenCapturePermission: String {
        lang == .turkish ? "Ekran Kaydı İzni" : "Screen Recording Permission"
    }

    public static var recheckPermissions: String {
        lang == .turkish ? "İzinleri Yeniden Kontrol Et" : "Recheck Permissions"
    }

    public static var accessibilityNotice: String {
        lang == .turkish ? "Pencere yönetimi ve odaklanma için Erişilebilirlik izni gereklidir." : "Accessibility permission is required for window management and focus."
    }

    public static var screenRecordingNotice: String {
        lang == .turkish ? "Pencerelerin canlı önizlemeleri için Ekran Kaydı izni gereklidir." : "Screen Recording permission is required for live window thumbnails."
    }

    public static var grantPermission: String {
        lang == .turkish ? "İzin Ver" : "Grant Permission"
    }

    public static var permissionsGranted: String {
        lang == .turkish ? "Tüm İzinler Tamam" : "All Permissions Granted"
    }

    public static var permissionsMissing: String {
        lang == .turkish ? "Eksik İzinler Var" : "Permissions Missing"
    }

    public static var updateAvailableTitle: String {
        lang == .turkish ? "Yeni Güncelleme Mevcut!" : "New Update Available!"
    }

    public static func updateVersionText(latest: String, current: String) -> String {
        lang == .turkish ? "Sürüm \(latest) hazır  •  Mevcut: \(current)" : "Version \(latest) ready  •  Current: \(current)"
    }

    public static var updateButton: String {
        lang == .turkish ? "Şimdi Güncelle ve Yeniden Başlat" : "Update Now & Restart"
    }

    // MARK: - Ek Genel Metinler (Diğer Görünümler)
    public static var groupByApp: String {
        lang == .turkish ? "Grupla" : "Group"
    }

    public static var statusBarTip: String {
        lang == .turkish
            ? "İpucu: Karta tıklayarak öne getirebilir, sürükleyerek masaüstünde konumlandırabilirsiniz."
            : "Tip: Click a card to focus, drag to position anywhere on your desktop."
    }

    public static var open: String {
        lang == .turkish ? "Aç" : "Open"
    }

    public static var showInFinder: String {
        lang == .turkish ? "Finder'da Göster" : "Show in Finder"
    }

    public static var doubleClickToOpen: String {
        lang == .turkish ? "Çift tıklayarak açın" : "Double-click to open"
    }

    public static var folder: String {
        lang == .turkish ? "Klasör" : "Folder"
    }

    public static var cancel: String {
        lang == .turkish ? "İptal" : "Cancel"
    }

    public static var save: String {
        lang == .turkish ? "Kaydet" : "Save"
    }

    public static var rename: String {
        lang == .turkish ? "Yeniden Adlandır" : "Rename"
    }

    public static var renameLayoutTitle: String {
        lang == .turkish ? "Düzeni Yeniden Adlandır" : "Rename Layout"
    }

    public static var layoutNamePlaceholder: String {
        lang == .turkish ? "Düzen adı" : "Layout name"
    }

    public static var layoutDefaultPrefix: String {
        lang == .turkish ? "Düzen" : "Layout"
    }

    public static var sessionsEmptyDescription: String {
        lang == .turkish
            ? "\"Düzeni Kaydet\" ile mevcut pencere\nkonumlarını isimle kaydedebilirsiniz."
            : "Use \"Save Current Layout\" to save\nand restore window arrangements."
    }
}

