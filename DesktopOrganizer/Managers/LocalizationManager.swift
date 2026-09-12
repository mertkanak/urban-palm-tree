import Foundation
import SwiftUI
import Combine

/// Desteklenen diller
public enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case english = "en"
    case turkish = "tr"
    case spanish = "es"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        case .spanish: return "Español"
        }
    }

    public var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .turkish: return "🇹🇷"
        case .spanish: return "🇪🇸"
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
            // Sistem dili kontrolü: Türkçe -> Türkçe, İspanyolca -> İspanyolca, diğerleri -> İngilizce
            let preferred = Locale.preferredLanguages.first?.lowercased() ?? ""
            if preferred.hasPrefix("tr") {
                self.currentLanguage = .turkish
            } else if preferred.hasPrefix("es") {
                self.currentLanguage = .spanish
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

    /// Bir sonraki dile geçiş yapar (EN -> TR -> ES -> EN)
    public func toggleLanguage() {
        switch currentLanguage {
        case .english: setLanguage(.turkish)
        case .turkish: setLanguage(.spanish)
        case .spanish: setLanguage(.english)
        }
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
        switch lang {
        case .turkish: return "Pencere & Masaüstü Yöneticisi"
        case .spanish: return "Administrador Inteligente de Ventanas y Escritorio"
        case .english: return "Smart Window & Desktop Organizer"
        }
    }

    public static var windowsTab: String {
        switch lang {
        case .turkish: return "Pencereler"
        case .spanish: return "Ventanas"
        case .english: return "Windows"
        }
    }

    public static var desktopTab: String {
        switch lang {
        case .turkish: return "Masaüstü"
        case .spanish: return "Escritorio"
        case .english: return "Desktop"
        }
    }

    // MARK: - Üst Araç Çubuğu Butonları
    public static var quickSwitchHelp: String {
        switch lang {
        case .turkish: return "Hızlı Pencere Değiştirici (⌥Tab / ⌃Tab)"
        case .spanish: return "Selector Rápido de Ventanas (⌥Tab / ⌃Tab)"
        case .english: return "Quick Window Switcher (⌥Tab / ⌃Tab)"
        }
    }

    public static var sessionsHelp: String {
        switch lang {
        case .turkish: return "Kaydedilmiş Çalışma Alanları"
        case .spanish: return "Espacios de Trabajo Guardados"
        case .english: return "Saved Window Workspaces"
        }
    }

    public static var refreshAll: String {
        switch lang {
        case .turkish: return "Tümünü Yenile"
        case .spanish: return "Actualizar Todo"
        case .english: return "Refresh All"
        }
    }

    public static var forceQuitAll: String {
        switch lang {
        case .turkish: return "Tümünü Kapat"
        case .spanish: return "Cerrar Todo"
        case .english: return "Force Quit All"
        }
    }

    public static var forceQuitAllHelp: String {
        switch lang {
        case .turkish: return "Açık olan tüm uygulamaları tamamen zorla kapat (⌥⇧Q)"
        case .spanish: return "Forzar el cierre de todas las aplicaciones abiertas (⌥⇧Q)"
        case .english: return "Force quit all open applications from Dock and background (⌥⇧Q)"
        }
    }

    public static var hidePanelHelp: String {
        switch lang {
        case .turkish: return "Paneli Gizle (Menü çubuğundan veya kısayolla tekrar açılabilir)"
        case .spanish: return "Ocultar Panel (Se puede volver a abrir desde la barra de menú o con atajo)"
        case .english: return "Hide Panel (Can be reopened via shortcut or menu bar)"
        }
    }

    public static var languageHelp: String {
        switch lang {
        case .turkish: return "Dili Değiştir (Language)"
        case .spanish: return "Cambiar Idioma (Language)"
        case .english: return "Switch Language"
        }
    }

    // MARK: - Arama & Filtreleme
    public static var searchPlaceholder: String {
        switch lang {
        case .turkish: return "Pencere veya uygulama ara..."
        case .spanish: return "Buscar ventanas o apps..."
        case .english: return "Search windows or apps..."
        }
    }

    public static var searchDesktopFilesPlaceholder: String {
        switch lang {
        case .turkish: return "Masaüstü dosyalarında ara..."
        case .spanish: return "Buscar archivos en escritorio..."
        case .english: return "Search desktop files..."
        }
    }

    public static var desktopIconsToggleHelp: String {
        switch lang {
        case .turkish: return "Masaüstündeki tüm dosya ikonlarını gizler veya tekrar görünür yapar"
        case .spanish: return "Oculta o muestra todos los iconos del escritorio"
        case .english: return "Hide or show all desktop icons"
        }
    }

    public static var refreshDesktopFilesHelp: String {
        switch lang {
        case .turkish: return "Masaüstü Dosyalarını Yenile"
        case .spanish: return "Actualizar Archivos del Escritorio"
        case .english: return "Refresh Desktop Files"
        }
    }

    public static var noMatchingWindowsTitle: String {
        switch lang {
        case .turkish: return "Aramanızla Eşleşen Pencere Yok"
        case .spanish: return "No Hay Ventanas Coincidentes"
        case .english: return "No Matching Windows Found"
        }
    }

    public static var refresh: String {
        switch lang {
        case .turkish: return "Yenile"
        case .spanish: return "Actualizar"
        case .english: return "Refresh"
        }
    }

    public static var allApps: String {
        switch lang {
        case .turkish: return "Tümü"
        case .spanish: return "Todo"
        case .english: return "All"
        }
    }

    public static var noWindowsFoundTitle: String {
        switch lang {
        case .turkish: return "Açık Pencere Bulunamadı"
        case .spanish: return "No Hay Ventanas Abiertas"
        case .english: return "No Open Windows Found"
        }
    }

    public static var noWindowsFoundSubtitle: String {
        switch lang {
        case .turkish: return "Diğer uygulamalarda pencereler açıldığında otomatik olarak burada görünecektir."
        case .spanish: return "Las ventanas aparecerán aquí automáticamente cuando se abran en otras aplicaciones."
        case .english: return "Windows will automatically appear here when opened in other applications."
        }
    }

    public static func searchNoMatch(query: String) -> String {
        switch lang {
        case .turkish: return "'\(query)' araması için açık olan hiçbir pencere bulunamadı."
        case .spanish: return "No se encontraron ventanas abiertas que coincidan con '\(query)'."
        case .english: return "No open windows found matching '\(query)'."
        }
    }

    public static var recentWindows: String {
        switch lang {
        case .turkish: return "Son Kullanılanlar"
        case .spanish: return "Recientes"
        case .english: return "Recently Focused"
        }
    }

    // MARK: - Pencere Kartı & Tiling Aksiyonları
    public static var snapLeft: String {
        switch lang {
        case .turkish: return "◧ Sol Yarıya Yerleştir"
        case .spanish: return "◧ Acoplar a la Izquierda"
        case .english: return "◧ Snap to Left Half"
        }
    }

    public static var snapRight: String {
        switch lang {
        case .turkish: return "◨ Sağ Yarıya Yerleştir"
        case .spanish: return "◨ Acoplar a la Derecha"
        case .english: return "◨ Snap to Right Half"
        }
    }

    public static var maximize: String {
        switch lang {
        case .turkish: return "⬚ Tam Ekran Yap"
        case .spanish: return "⬚ Maximizar Ventana"
        case .english: return "⬚ Maximize Window"
        }
    }

    public static var center: String {
        switch lang {
        case .turkish: return "◲ Ortala"
        case .spanish: return "◲ Centrar en Pantalla"
        case .english: return "◲ Center on Screen"
        }
    }

    public static var minimize: String {
        switch lang {
        case .turkish: return "➖ Simge Durumuna Küçült"
        case .spanish: return "➖ Minimizar Ventana"
        case .english: return "➖ Minimize Window"
        }
    }

    public static var pinToTop: String {
        switch lang {
        case .turkish: return "📌 Yukarıya Sabitle"
        case .spanish: return "📌 Fijar Arriba"
        case .english: return "📌 Pin to Top"
        }
    }

    public static var unpin: String {
        switch lang {
        case .turkish: return "📌 Sabitlemeyi Kaldır"
        case .spanish: return "📌 Desfijar de Arriba"
        case .english: return "📌 Unpin from Top"
        }
    }

    public static var copyScreenshot: String {
        switch lang {
        case .turkish: return "📸 Screenshot Al (Panoya)"
        case .spanish: return "📸 Copiar Captura (Portapapeles)"
        case .english: return "📸 Copy Screenshot (Clipboard)"
        }
    }

    public static func forceQuitHelp(app: String) -> String {
        switch lang {
        case .turkish: return "\(app) Uygulamasını Tamamen Zorla Kapat (Force Quit - Dock'ta Kalmaz)"
        case .spanish: return "Forzar salida completa de \(app) (Cierra proceso y quita del Dock)"
        case .english: return "Force Quit \(app) completely (Closes process and removes from Dock)"
        }
    }

    public static var closeWindowHelp: String {
        switch lang {
        case .turkish: return "Pencereyi Kapat (⌥ Tıklama: Tamamen Force Quit)"
        case .spanish: return "Cerrar Ventana (⌥ Clic: Forzar Cierre de la App)"
        case .english: return "Close Window (⌥ Click: Force Quit App)"
        }
    }

    // MARK: - Hızlı Pencere Değiştirici (Quick Switcher HUD)
    public static var quickSwitchTitle: String {
        switch lang {
        case .turkish: return "Hızlı Pencere Geçişi"
        case .spanish: return "Cambio Rápido de Ventanas"
        case .english: return "Quick Window Switcher"
        }
    }

    public static func openWindowsCount(_ count: Int) -> String {
        switch lang {
        case .turkish:
            return "\(count) Açık Pencere"
        case .spanish:
            return count == 1 ? "1 Ventana Abierta" : "\(count) Ventanas Abiertas"
        case .english:
            return count == 1 ? "1 Open Window" : "\(count) Open Windows"
        }
    }

    public static var quickSwitchEmpty: String {
        switch lang {
        case .turkish: return "Açık pencere bulunamadı"
        case .spanish: return "No se encontraron ventanas abiertas"
        case .english: return "No open windows found"
        }
    }

    public static var hintNavigate: String {
        switch lang {
        case .turkish: return "Gezin"
        case .spanish: return "Navegar"
        case .english: return "Navigate"
        }
    }

    public static var hintNext: String {
        switch lang {
        case .turkish: return "Sonraki"
        case .spanish: return "Siguiente"
        case .english: return "Next"
        }
    }

    public static var hintSwitch: String {
        switch lang {
        case .turkish: return "Pencereye Geç"
        case .spanish: return "Cambiar"
        case .english: return "Switch to Window"
        }
    }

    public static var hintForceQuit: String {
        switch lang {
        case .turkish: return "Force Quit"
        case .spanish: return "Forzar Salida"
        case .english: return "Force Quit"
        }
    }

    public static var hintClose: String {
        switch lang {
        case .turkish: return "Kapat"
        case .spanish: return "Cerrar"
        case .english: return "Close"
        }
    }

    // MARK: - Masaüstü Düzenleyici (Desktop Clean Up)
    public static var hideDesktopIcons: String {
        switch lang {
        case .turkish: return "Masaüstü Simgelerini Gizle"
        case .spanish: return "Ocultar Iconos del Escritorio"
        case .english: return "Hide Desktop Icons"
        }
    }

    public static var showDesktopIcons: String {
        switch lang {
        case .turkish: return "Masaüstü Simgelerini Göster"
        case .spanish: return "Mostrar Iconos del Escritorio"
        case .english: return "Show Desktop Icons"
        }
    }

    public static var autoOrganize: String {
        switch lang {
        case .turkish: return "Masaüstünü Otomatik Düzenle"
        case .spanish: return "Organizar Escritorio Automáticamente"
        case .english: return "Organize Desktop Automatically"
        }
    }

    public static var autoOrganizeHelp: String {
        switch lang {
        case .turkish: return "Masaüstündeki tüm dosyaları kategorilere göre alt klasörlere taşır"
        case .spanish: return "Mueve todos los archivos del escritorio a carpetas organizadas por categoría"
        case .english: return "Moves all files on desktop into organized category folders"
        }
    }

    public static var emptyCategory: String {
        switch lang {
        case .turkish: return "Bu kategoride dosya yok"
        case .spanish: return "No hay archivos en esta categoría"
        case .english: return "No files in this category"
        }
    }

    public static var desktopCleanTitle: String {
        switch lang {
        case .turkish: return "Masaüstü Temiz"
        case .spanish: return "Escritorio Limpio"
        case .english: return "Desktop is Clean"
        }
    }

    public static var desktopCleanSubtitle: String {
        switch lang {
        case .turkish: return "Masaüstünüzde düzenlenecek dosya bulunmuyor."
        case .spanish: return "No se encontraron archivos en tu escritorio para organizar."
        case .english: return "No files found on your desktop to organize."
        }
    }

    // MARK: - Dosya Kategorileri (File Categories)
    public static func categoryName(_ category: String) -> String {
        switch category {
        case "images", "Resimler":
            switch lang {
            case .turkish: return "Resimler"
            case .spanish: return "Imágenes y Fotos"
            case .english: return "Images & Photos"
            }
        case "documents", "Dokümanlar":
            switch lang {
            case .turkish: return "Dokümanlar"
            case .spanish: return "Documentos"
            case .english: return "Documents"
            }
        case "downloads", "İndirilenler / Arşivler":
            switch lang {
            case .turkish: return "İndirilenler / Arşivler"
            case .spanish: return "Descargas y Archivos"
            case .english: return "Downloads & Archives"
            }
        case "applications", "Uygulamalar":
            switch lang {
            case .turkish: return "Uygulamalar"
            case .spanish: return "Aplicaciones"
            case .english: return "Applications"
            }
        case "developer", "Kod & Geliştirme":
            switch lang {
            case .turkish: return "Kod & Geliştirme"
            case .spanish: return "Código y Desarrollo"
            case .english: return "Code & Development"
            }
        case "other", "Diğer":
            switch lang {
            case .turkish: return "Diğer"
            case .spanish: return "Otros Archivos"
            case .english: return "Other Files"
            }
        default:
            return category
        }
    }

    // MARK: - Çalışma Alanları (Session Management)
    public static var sessionsTitle: String {
        switch lang {
        case .turkish: return "Kayıtlı Çalışma Alanları"
        case .spanish: return "Espacios de Trabajo Guardados"
        case .english: return "Saved Workspaces"
        }
    }

    public static var saveCurrentSession: String {
        switch lang {
        case .turkish: return "Mevcut Düzeni Kaydet"
        case .spanish: return "Guardar Diseño Actual"
        case .english: return "Save Current Layout"
        }
    }

    public static var sessionNamePlaceholder: String {
        switch lang {
        case .turkish: return "Çalışma alanı adı (ör. Proje X, Araştırma)..."
        case .spanish: return "Nombre del espacio (ej. Proyecto X, Estudio)..."
        case .english: return "Workspace name (e.g. Project A, Research)..."
        }
    }

    public static var restoreSession: String {
        switch lang {
        case .turkish: return "Geri Yükle"
        case .spanish: return "Restaurar"
        case .english: return "Restore"
        }
    }

    public static var deleteSession: String {
        switch lang {
        case .turkish: return "Sil"
        case .spanish: return "Eliminar"
        case .english: return "Delete"
        }
    }

    public static var noSessionsYet: String {
        switch lang {
        case .turkish: return "Henüz kayıtlı bir çalışma alanı yok"
        case .spanish: return "Aún no hay espacios de trabajo guardados"
        case .english: return "No saved workspaces yet"
        }
    }

    public static func sessionSummary(count: Int, date: String) -> String {
        let countText: String
        switch lang {
        case .turkish:
            countText = "\(count) pencere"
        case .spanish:
            countText = count == 1 ? "1 ventana" : "\(count) ventanas"
        case .english:
            countText = count == 1 ? "1 window" : "\(count) windows"
        }
        return "\(countText) • \(date)"
    }

    // MARK: - Menü Çubuğu (Menu Bar Context Menu)
    public static var menuToggle: String {
        switch lang {
        case .turkish: return "Desktop Organizer'ı Aç/Kapat"
        case .spanish: return "Abrir/Cerrar Desktop Organizer"
        case .english: return "Toggle Desktop Organizer"
        }
    }

    public static var menuQuickSwitch: String {
        switch lang {
        case .turkish: return "Hızlı Pencere Değiştirici (⌥+Tab / ⌃+Tab)"
        case .spanish: return "Selector Rápido de Ventanas (⌥+Tab / ⌃+Tab)"
        case .english: return "Quick Window Switcher (⌥+Tab / ⌃+Tab)"
        }
    }

    public static var menuRefreshWindows: String {
        switch lang {
        case .turkish: return "Pencereleri Yenile"
        case .spanish: return "Actualizar Ventanas"
        case .english: return "Refresh Windows"
        }
    }

    public static var menuToggleDesktopIcons: String {
        switch lang {
        case .turkish: return "Masaüstü İkonlarını Gizle/Göster"
        case .spanish: return "Ocultar/Mostrar Iconos del Escritorio"
        case .english: return "Toggle Desktop Icons"
        }
    }

    public static var menuForceQuitAll: String {
        switch lang {
        case .turkish: return "Tüm Açık Uygulamaları Kapat (⌥+⇧+Q)"
        case .spanish: return "Cerrar Todas las Apps Abiertas (⌥+⇧+Q)"
        case .english: return "Force Quit All Open Apps (⌥+⇧+Q)"
        }
    }

    public static var menuLanguage: String {
        switch lang {
        case .turkish: return "Dil / Language"
        case .spanish: return "Idioma / Language"
        case .english: return "Language / Idioma"
        }
    }

    public static var menuQuit: String {
        switch lang {
        case .turkish: return "Çıkış"
        case .spanish: return "Salir"
        case .english: return "Quit"
        }
    }

    // MARK: - İzinler & Güncelleme
    public static var permissionsTitle: String {
        switch lang {
        case .turkish: return "Gerekli İzinler"
        case .spanish: return "Permisos Requeridos"
        case .english: return "Required Permissions"
        }
    }

    public static var systemPermissionsTitle: String {
        switch lang {
        case .turkish: return "Sistem İzinleri Gerekli"
        case .spanish: return "Se Requieren Permisos del Sistema"
        case .english: return "System Permissions Required"
        }
    }

    public static var systemPermissionsSubtitle: String {
        switch lang {
        case .turkish:
            return "Pencereleri öne getirmek ve canlı önizlemeler için izinler gereklidir.\n⚠️ Ayarlarda zaten açık görünüyorsa: Anahtarı bir kez kapatıp tekrar açmanız yeterlidir."
        case .spanish:
            return "Se requieren permisos para administrar ventanas y vistas previas en vivo.\n⚠️ Si ya aparece activado en Ajustes: Desactiva y activa el interruptor una vez."
        case .english:
            return "Permissions are required for window management and live previews.\n⚠️ If already enabled in Settings: Simply toggle the switch off and on once."
        }
    }

    public static var accessibilityPermission: String {
        switch lang {
        case .turkish: return "Erişilebilirlik İzni"
        case .spanish: return "Permiso de Accesibilidad"
        case .english: return "Accessibility Permission"
        }
    }

    public static var screenCapturePermission: String {
        switch lang {
        case .turkish: return "Ekran Kaydı İzni"
        case .spanish: return "Permiso de Grabación de Pantalla"
        case .english: return "Screen Recording Permission"
        }
    }

    public static var recheckPermissions: String {
        switch lang {
        case .turkish: return "İzinleri Yeniden Kontrol Et"
        case .spanish: return "Volver a Comprobar Permisos"
        case .english: return "Recheck Permissions"
        }
    }

    public static var accessibilityNotice: String {
        switch lang {
        case .turkish: return "Pencere yönetimi ve odaklanma için Erişilebilirlik izni gereklidir."
        case .spanish: return "El permiso de Accesibilidad es necesario para gestionar y enfocar ventanas."
        case .english: return "Accessibility permission is required for window management and focus."
        }
    }

    public static var screenRecordingNotice: String {
        switch lang {
        case .turkish: return "Pencerelerin canlı önizlemeleri için Ekran Kaydı izni gereklidir."
        case .spanish: return "El permiso de Grabación de Pantalla es necesario para las miniaturas en vivo."
        case .english: return "Screen Recording permission is required for live window thumbnails."
        }
    }

    public static var grantPermission: String {
        switch lang {
        case .turkish: return "İzin Ver"
        case .spanish: return "Conceder Permiso"
        case .english: return "Grant Permission"
        }
    }

    public static var permissionsGranted: String {
        switch lang {
        case .turkish: return "Tüm İzinler Tamam"
        case .spanish: return "Todos los Permisos Concedidos"
        case .english: return "All Permissions Granted"
        }
    }

    public static var permissionsMissing: String {
        switch lang {
        case .turkish: return "Eksik İzinler Var"
        case .spanish: return "Faltan Permisos"
        case .english: return "Permissions Missing"
        }
    }

    public static var updateAvailableTitle: String {
        switch lang {
        case .turkish: return "Yeni Güncelleme Mevcut!"
        case .spanish: return "¡Nueva Actualización Disponible!"
        case .english: return "New Update Available!"
        }
    }

    public static func updateVersionText(latest: String, current: String) -> String {
        switch lang {
        case .turkish: return "Sürüm \(latest) hazır  •  Mevcut: \(current)"
        case .spanish: return "Versión \(latest) lista  •  Actual: \(current)"
        case .english: return "Version \(latest) ready  •  Current: \(current)"
        }
    }

    public static var updateButton: String {
        switch lang {
        case .turkish: return "Şimdi Güncelle ve Yeniden Başlat"
        case .spanish: return "Actualizar Ahora y Reiniciar"
        case .english: return "Update Now & Restart"
        }
    }

    // MARK: - Ek Genel Metinler (Diğer Görünümler)
    public static var groupByApp: String {
        switch lang {
        case .turkish: return "Grupla"
        case .spanish: return "Agrupar"
        case .english: return "Group"
        }
    }

    public static var statusBarTip: String {
        switch lang {
        case .turkish:
            return "İpucu: Karta tıklayarak öne getirebilir, sürükleyerek masaüstünde konumlandırabilirsiniz."
        case .spanish:
            return "Consejo: Haz clic en una tarjeta para enfocarla o arrastra para colocarla en la pantalla."
        case .english:
            return "Tip: Click a card to focus, drag to position anywhere on your desktop."
        }
    }

    public static var open: String {
        switch lang {
        case .turkish: return "Aç"
        case .spanish: return "Abrir"
        case .english: return "Open"
        }
    }

    public static var showInFinder: String {
        switch lang {
        case .turkish: return "Finder'da Göster"
        case .spanish: return "Mostrar en Finder"
        case .english: return "Show in Finder"
        }
    }

    public static var doubleClickToOpen: String {
        switch lang {
        case .turkish: return "Çift tıklayarak açın"
        case .spanish: return "Doble clic para abrir"
        case .english: return "Double-click to open"
        }
    }

    public static var folder: String {
        switch lang {
        case .turkish: return "Klasör"
        case .spanish: return "Carpeta"
        case .english: return "Folder"
        }
    }

    public static var cancel: String {
        switch lang {
        case .turkish: return "İptal"
        case .spanish: return "Cancelar"
        case .english: return "Cancel"
        }
    }

    public static var save: String {
        switch lang {
        case .turkish: return "Kaydet"
        case .spanish: return "Guardar"
        case .english: return "Save"
        }
    }

    public static var rename: String {
        switch lang {
        case .turkish: return "Yeniden Adlandır"
        case .spanish: return "Renombrar"
        case .english: return "Rename"
        }
    }

    public static var renameLayoutTitle: String {
        switch lang {
        case .turkish: return "Düzeni Yeniden Adlandır"
        case .spanish: return "Renombrar Diseño"
        case .english: return "Rename Layout"
        }
    }

    public static var layoutNamePlaceholder: String {
        switch lang {
        case .turkish: return "Düzen adı"
        case .spanish: return "Nombre del diseño"
        case .english: return "Layout name"
        }
    }

    public static var layoutDefaultPrefix: String {
        switch lang {
        case .turkish: return "Düzen"
        case .spanish: return "Diseño"
        case .english: return "Layout"
        }
    }

    public static var sessionsEmptyDescription: String {
        switch lang {
        case .turkish:
            return "\"Düzeni Kaydet\" ile mevcut pencere\nkonumlarını isimle kaydedebilirsiniz."
        case .spanish:
            return "Usa \"Guardar Diseño Actual\" para guardar\ny restaurar la disposición de tus ventanas."
        case .english:
            return "Use \"Save Current Layout\" to save\nand restore window arrangements."
        }
    }
}


