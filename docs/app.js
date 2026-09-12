/**
 * Desktop Organizer — Landing Page Interactive Scripts
 * Features: 100% Comprehensive Trilingual I18n Engine (EN / TR / ES), Interactive Mockup Tabs, FAQ Accordion.
 */

// MARK: - Trilingual Translations Dictionary
const translations = {
  en: {
    // Navigation
    navFeatures: "Features",
    navQuickSwitch: "Quick Switch",
    navDesktopClean: "Desktop Clean",
    navWorkspaces: "Workspaces",
    navFaq: "FAQ",
    downloadBtnNav: "Download",

    // Hero Section
    heroBadge: "Apple Notarized & Gatekeeper Safe • macOS 14+",
    heroDownloadCount: "🚀 16+ Downloads",
    heroTitlePart1: "The Missing Window &",
    heroTitlePart2: "Desktop Manager for macOS",
    heroDescription: "Supercharge your Mac workflow. Instant window tiling, lightning-fast visual ⌥Tab switcher HUD, 1-click messy desktop auto-cleaner, saved workspace layouts, and clean process Force Quit.",
    heroBtnSubtext: "Free Download for macOS",
    heroBtnMaintext: "Download Desktop Organizer",
    heroGithubBtn: "Star on GitHub",
    heroSpecSilicon: "⚡ Apple Silicon (M1/M2/M3/M4) & Intel",
    heroSpecMacOS: "🖥️ macOS 14.0+ Sonoma & Sequoia",
    heroSpecOffline: "🔒 100% Offline & Private",

    // Mockup Window
    mockupTabWindows: "Windows",
    mockupTabQuickSwitch: "Quick Switch (⌥Tab)",
    mockupTabDesktop: "Desktop Cleaner",
    mockupLang: "🇺🇸 EN",
    mockupSearchPlaceholder: "Search windows or apps...",
    mockupViewLarge: "◫ Large Cards",
    mockupViewCompact: "▦ Compact",
    mockupViewList: "☰ List",
    mockupCountBadge: "● 4 Open Windows",
    
    mockupHudTitle: "⚡ Quick Window Switcher",
    mockupHudCount: "4 Windows",
    mockupHudEnter: "Enter ↵",
    mockupHudNav: "<kbd>← →</kbd> Navigate",
    mockupHudNext: "<kbd>Tab</kbd> Next",
    mockupHudSwitch: "<kbd>Enter ↵</kbd> Switch",
    mockupHudQuit: "<kbd class=\"red\">Q</kbd> Force Quit",
    mockupHudClose: "<kbd>ESC</kbd> Close",

    mockupAutoCleanBtn: "Organize Desktop Automatically",
    mockupHideIconsBtn: "Hide Desktop Icons",
    mockupCatImages: "Images & Photos",
    mockupCatDocs: "Documents",
    mockupCatDownloads: "Downloads & Archives",
    mockupCatImgFiles: "screenshot_1.png, banner.jpg, logo.svg...",
    mockupCatDocFiles: "Invoice-2026.pdf, Notes.docx, specs.md...",
    mockupCatDownFiles: "project-backup.zip, node-v20.pkg...",

    // Features Section
    featBadge: "BUILT FOR SPEED & PRODUCTIVITY",
    featTitle: "Everything you need to master your macOS screen",
    featSubtitle: "Stop hunting for lost windows or dealing with a messy desktop. Desktop Organizer puts complete control at your fingertips.",

    f1Title: "Smart Window Snapping & Tiling",
    f1Desc: "Effortlessly snap any window to the left half, right half, center, or full screen. Keep important reference notes pinned on top of everything while you work.",
    tagSnapLeft: "◧ Snap Left",
    tagSnapRight: "◨ Snap Right",
    tagMaximize: "⬚ Maximize",
    tagPin: "📌 Pin on Top",

    f2Title: "Visual ⌥Tab Switcher HUD",
    f2Desc: "Ditch the basic macOS app switcher. See live thumbnails of your windows. Navigate with arrow keys, press Enter to jump, or hit Q to instantly kill an app.",
    tagPreviews: "Instant Previews",

    f3Title: "1-Click Desktop Organizer",
    f3Desc: "Chaos on your desktop? One click categorizes everything into neat folders: Images, Documents, Archives, Applications, and Code. Or toggle desktop icons invisible for clean screen shares.",
    tagSmartCat: "Smart Categories",
    tagHideIcons: "Hide Icons",

    f4Title: "Saved Layout Workspaces (Sessions)",
    f4Desc: "Do you arrange your screen for Coding, Research, or Video Editing? Save your window placements with one click. Switch between tasks and restore your entire window layout instantly.",
    tagSnapshots: "Layout Snapshots",
    tagInstantRestore: "Instant Restore",
    tagMultiMonitor: "Multi-Monitor",

    f5Title: "Instant Force Quit for Hanging Apps",
    f5Desc: "Apps frozen or refusing to quit from the Dock? Option+Click any close button or hit ⌥⇧Q to forcefully terminate stubborn processes instantly.",
    tagDockClean: "Dock Clean",

    f6Title: "Zero Telemetry. 100% Native Swift",
    f6Desc: "No Electron bloat. Crafted purely in native Swift 6 and SwiftUI. Runs with under 20MB of RAM, instant launch time, and zero telemetry.",
    tagZeroTracking: "Zero Tracking",

    // Comparison Table
    compBadge: "WHY DESKTOP ORGANIZER?",
    compTitle: "Traditional macOS vs. Desktop Organizer",
    compColFeature: "Workflow Capability",
    compColDefault: "Default macOS",
    compRow1: "⌥Tab Visual Window Switcher with Previews",
    compRow1Default: "❌ Apps only, no window preview",
    compRow1Pro: "✅ Live thumbnails, arrow navigation, Q to quit",
    compRow2: "1-Click Snap Left / Right / Maximize / Pin",
    compRow2Default: "⚠️ Clunky green button hover",
    compRow2Pro: "✅ Fast hover controls & window cards",
    compRow3: "1-Click Messy Desktop File Categorization",
    compRow3Default: "❌ Manual dragging needed",
    compRow3Pro: "✅ Instant smart categorization",
    compRow4: "Save & Restore Window Workspace Layouts",
    compRow4Default: "❌ Not supported natively",
    compRow4Pro: "✅ Save named layouts & restore anytime",
    compRow5: "Fast Force Quit from Window Card / Dock",
    compRow5Default: "⚠️ 4-step Activity Monitor route",
    compRow5Pro: "✅ 1-click Option+Close or ⌥⇧Q",

    // Installation
    installBadge: "GET STARTED IN 30 SECONDS",
    installTitle: "Easy 3-step installation",
    step1Title: "Download ZIP",
    step1Desc: "Click the download button to grab the official, notarized DesktopOrganizer.zip package.",
    step2Title: "Move to Applications",
    step2Desc: "Extract the zip file and drag DesktopOrganizer.app into your macOS Applications folder.",
    step3Title: "Launch & Press ⌥A",
    step3Desc: "Open the app, grant Accessibility permission once, and control your desktop from the menu bar or ⌥A.",

    // FAQ
    faqBadge: "QUESTIONS & ANSWERS",
    faqTitle: "Frequently Asked Questions",
    faq1Q: "Will macOS show an \"Unidentified Developer\" or Gatekeeper security warning?",
    faq1A: "<strong>No!</strong> Desktop Organizer is officially signed with an Apple Developer ID and fully <strong>Notarized by Apple</strong>. Gatekeeper verifies it automatically, so you can open it with double-click without any security blocks.",
    faq2Q: "Which macOS versions and Mac models are supported?",
    faq2A: "Desktop Organizer is built for macOS 14.0+ Sonoma and macOS 15.0+ Sequoia. It runs natively on both Apple Silicon (M1, M2, M3, M4) and Intel Macs.",
    faq3Q: "Why does Desktop Organizer require Accessibility permission?",
    faq3A: "macOS requires Accessibility permissions so the app can bring windows into focus, reposition/tile windows when you click snap buttons, and trigger Force Quit commands. All data stays 100% on your local machine.",
    faq4Q: "How do automatic updates work?",
    faq4A: "The app checks GitHub Releases in the background. When a new version is released, a green 🚀 banner appears in the app. One click downloads and restarts the app with the latest version.",
    faq5Q: "Is Desktop Organizer free and open source?",
    faq5A: "Yes! Desktop Organizer is open source on GitHub. You can inspect the source code, contribute, or download and use it completely free.",

    // CTA Banner
    ctaBannerTitle: "Ready to organize your Mac desktop?",
    ctaBannerSubtitle: "Download Desktop Organizer today. Free, notarized, and open source.",
    ctaDownloadBtn: "Download for macOS",
    ctaSubnote: "Requires macOS 14.0 Sonoma or newer • Apple Silicon & Intel",

    // Footer
    footerDesc: "Smart Window & Desktop Organizer for macOS",
    footerReleases: "Releases",
    footerCreatedBy: "Crafted by",
    footerRights: "All rights reserved."
  },

  tr: {
    // Navigasyon
    navFeatures: "Özellikler",
    navQuickSwitch: "Hızlı Geçiş",
    navDesktopClean: "Masaüstü",
    navWorkspaces: "Çalışma Alanları",
    navFaq: "SSS",
    downloadBtnNav: "İndir",

    // Hero Bölümü
    heroBadge: "Apple Notarized & Gatekeeper Güvenli • macOS 14+",
    heroDownloadCount: "🚀 16+ Kez İndirildi",
    heroTitlePart1: "macOS İçin Eksik Olan",
    heroTitlePart2: "Akıllı Pencere ve Masaüstü Yöneticisi",
    heroDescription: "Mac iş akışınızı hızlandırın. Anında pencere bölme (tiling), görsel ⌥Tab hızlı pencere değiştirici HUD, tek tıkla masaüstü dosya temizleme, kayıtlı çalışma alanları ve donan uygulamaları tamamen kapatma (Force Quit).",
    heroBtnSubtext: "macOS İçin Ücretsiz İndir",
    heroBtnMaintext: "Desktop Organizer'ı İndir",
    heroGithubBtn: "GitHub'da Yıldızla",
    heroSpecSilicon: "⚡ Apple Silicon (M1/M2/M3/M4) & Intel",
    heroSpecMacOS: "🖥️ macOS 14.0+ Sonoma & Sequoia",
    heroSpecOffline: "🔒 %100 Çevrimdışı ve Gizli",

    // Maket Pencere
    mockupTabWindows: "Pencereler",
    mockupTabQuickSwitch: "Hızlı Geçiş (⌥Tab)",
    mockupTabDesktop: "Masaüstü Düzenleyici",
    mockupLang: "🇹🇷 TR",
    mockupSearchPlaceholder: "Pencere veya uygulama ara...",
    mockupViewLarge: "◫ Büyük Kart",
    mockupViewCompact: "▦ Küçük Önizleme",
    mockupViewList: "☰ Liste",
    mockupCountBadge: "● 4 Açık Pencere",

    mockupHudTitle: "⚡ Hızlı Pencere Geçişi",
    mockupHudCount: "4 Pencere",
    mockupHudEnter: "Enter ↵",
    mockupHudNav: "<kbd>← →</kbd> Gezin",
    mockupHudNext: "<kbd>Tab</kbd> Sonraki",
    mockupHudSwitch: "<kbd>Enter ↵</kbd> Geçiş Yap",
    mockupHudQuit: "<kbd class=\"red\">Q</kbd> Force Quit",
    mockupHudClose: "<kbd>ESC</kbd> Kapat",

    mockupAutoCleanBtn: "Masaüstünü Otomatik Düzenle",
    mockupHideIconsBtn: "Masaüstü Simgelerini Gizle",
    mockupCatImages: "Resimler & Fotoğraflar",
    mockupCatDocs: "Dokümanlar",
    mockupCatDownloads: "İndirilenler & Arşivler",
    mockupCatImgFiles: "ekran_resmi.png, afis.jpg, logo.svg...",
    mockupCatDocFiles: "Fatura-2026.pdf, Notlar.docx, plan.md...",
    mockupCatDownFiles: "proje-yedek.zip, paket-v20.pkg...",

    // Özellikler Bölümü
    featBadge: "HIZ & VERİMLİLİK İÇİN TASARLANDI",
    featTitle: "Mac ekranınızı kontrol etmek için ihtiyacınız olan her şey",
    featSubtitle: "Açık pencereler arasında kaybolmaya ve karmaşık bir masaüstüne son verin. Desktop Organizer tüm kontrolü parmaklarınızın ucuna getirir.",

    f1Title: "Akıllı Pencere Konumlandırma & Tiling",
    f1Desc: "Herhangi bir pencereyi tek tıkla sol yarıya, sağ yarıya veya tam ekrana yaslayın. Çalışırken notlarınızı veya referans ekranlarınızı daima en üstte sabit tutun.",
    tagSnapLeft: "◧ Sola Yasla",
    tagSnapRight: "◨ Sağa Yasla",
    tagMaximize: "⬚ Tam Ekran",
    tagPin: "📌 Üste Sabitle",

    f2Title: "Görsel ⌥Tab Hızlı Değiştirici HUD",
    f2Desc: "Klasik Mac Cmd+Tab değiştiricisini unutun. Pencerelerin canlı küçük resimlerini görün. Ok tuşlarıyla gezin, Enter ile geçiş yapın veya Q tuşu ile anında sonlandırın.",
    tagPreviews: "Canlı Önizleme",

    f3Title: "Tek Tıkla Masaüstü Dosya Temizleme",
    f3Desc: "Masaüstünüz dosyalarla mı doldu? Tek tıkla her şeyi kategorilerine (Resimler, Dokümanlar, Arşivler, Uygulamalar ve Kod) ayırıp klasörleyin. İsterseniz simgeleri tamamen gizleyin.",
    tagSmartCat: "Akıllı Kategoriler",
    tagHideIcons: "Simgeleri Gizle",

    f4Title: "Kayıtlı Çalışma Alanları (Sessions)",
    f4Desc: "Kodlama, Araştırma veya Tasarım için farklı pencere düzenleri mi kullanıyorsunuz? Düzeninizi tek tıkla kaydedin. İstediğiniz an tüm pencerelerinizi aynı konuma geri getirin.",
    tagSnapshots: "Düzen Kaydı",
    tagInstantRestore: "Anında Geri Yükle",
    tagMultiMonitor: "Çoklu Monitör",

    f5Title: "Donan Uygulamalar İçin Anında Force Quit",
    f5Desc: "Kapanmayan, Dock'ta takılı kalan uygulamalar mı var? Kapatma butonuna Option (⌥) ile tıklayarak veya ⌥⇧Q kısayoluyla uygulamayı arka plandan tamamen kapatın.",
    tagDockClean: "Dock Temizliği",

    f6Title: "Sıfır Telemetri. %100 Yerel Swift",
    f6Desc: "Ağır Electron uygulamalarından değil. Tamamen yerel Swift 6 ve modern SwiftUI ile yazıldı. 20MB'tan az RAM tüketimi, anında açılış ve tam gizlilik.",
    tagZeroTracking: "Sıfır Takip",

    // Karşılaştırma Tablosu
    compBadge: "NEDEN DESKTOP ORGANIZER?",
    compTitle: "Varsayılan macOS vs. Desktop Organizer",
    compColFeature: "İş Akışı Yeteneği",
    compColDefault: "Standart macOS",
    compRow1: "Önizlemeli ⌥Tab Görsel Pencere Değiştirici",
    compRow1Default: "❌ Sadece uygulama ikonu, önizleme yok",
    compRow1Pro: "✅ Canlı küçük resimler, ok tuşlarıyla gezinme, Q ile kapatma",
    compRow2: "Tek Tıkla Sola / Sağa Yaslama, Sabitleme",
    compRow2Default: "⚠️ Hantal yeşil buton menüsü",
    compRow2Pro: "✅ Hızlı kart kontrolleri ve ızgara menüsü",
    compRow3: "Tek Tıkla Dağınık Masaüstü Dosyalarını Gruplama",
    compRow3Default: "❌ Elle tek tek klasörlemek gerekir",
    compRow3Pro: "✅ Tek tıkla otomatik akıllı kategorizasyon",
    compRow4: "Pencere Düzenlerini (Çalışma Alanı) Kaydetme",
    compRow4Default: "❌ Yerel olarak desteklenmez",
    compRow4Pro: "✅ Düzenleri isimle kaydet ve anında geri yükle",
    compRow5: "Pencere Kartından veya Dock'tan Hızlı Force Quit",
    compRow5Default: "⚠️ Etkinlik Monitörü ile 4 aşamalı zahmetli işlem",
    compRow5Pro: "✅ Tek tık Option+Kapat veya ⌥⇧Q kısayolu",

    // Kurulum
    installBadge: "30 SANİYEDE KULLANMAYA BAŞLAYIN",
    installTitle: "3 kolay adımda kurulum",
    step1Title: "ZIP'i İndirin",
    step1Desc: "İndirme butonuna tıklayarak resmi ve noter onaylı DesktopOrganizer.zip paketini indirin.",
    step2Title: "Uygulamalar'a Taşıyın",
    step2Desc: "İndirilen zip dosyasını açın ve DesktopOrganizer.app dosyasını Uygulamalar (Applications) klasörüne sürükleyin.",
    step3Title: "Çalıştırın ve ⌥A'ya Basın",
    step3Desc: "Uygulamayı açın, ilk açılışta Erişilebilirlik iznini verin ve menü çubuğundan veya ⌥A kısayoluyla kontrolü ele alın.",

    // SSS
    faqBadge: "SIKÇA SORULAN SORULAR",
    faqTitle: "Merak Edilenler ve Cevaplar",
    faq1Q: "macOS açılışta \"Geliştirici doğrulanamadı\" veya Gatekeeper uyarısı verir mi?",
    faq1A: "<strong>Hayır!</strong> Desktop Organizer resmi Apple Developer ID sertifikası ile imzalanmış ve doğrudan <strong>Apple Notary Service</strong> tarafından onaylanıp mühürlenmiştir. macOS Gatekeeper tarafından sorunsuz olarak kabul edilir.",
    faq2Q: "Hangi Mac modelleri ve macOS sürümleri destekleniyor?",
    faq2A: "Desktop Organizer, macOS 14.0+ Sonoma ve macOS 15.0+ Sequoia için geliştirilmiştir. Hem Apple Silicon (M1, M2, M3, M4) hem de Intel işlemcili Mac'lerde yerel hızda çalışır.",
    faq3Q: "Uygulama neden Erişilebilirlik (Accessibility) izni istiyor?",
    faq3A: "macOS kuralları gereği, bir uygulamanın diğer pencereleri öne getirebilmesi, ekranın sağına/soluna yaslayabilmesi ve Force Quit uygulayabilmesi için Erişilebilirlik izni zorunludur. Tüm işlemler %100 cihazınızda yerel çalışır.",
    faq4Q: "Otomatik güncellemeler nasıl çalışıyor?",
    faq4A: "Uygulama arka planda GitHub Releases'i kontrol eder. Yeni bir sürüm çıktığında ana pencerede yeşil 🚀 butonu görünür. Tek tıkla otomatik indirilir ve uygulama güncellenir.",
    faq5Q: "Desktop Organizer ücretsiz ve açık kaynak mı?",
    faq5A: "Evet! Desktop Organizer GitHub üzerinde açık kaynak kodludur. Kaynak kodlarını inceleyebilir, katkıda bulunabilir ve tamamen ücretsiz kullanabilirsiniz.",

    // CTA Banner
    ctaBannerTitle: "Mac masaüstünüzü düzenlemeye hazır mısınız?",
    ctaBannerSubtitle: "Desktop Organizer'ı hemen indirin. Ücretsiz, noter onaylı ve açık kaynak.",
    ctaDownloadBtn: "macOS İçin İndir",
    ctaSubnote: "macOS 14.0 Sonoma veya daha yenisi gerekir • Apple Silicon & Intel",

    // Footer
    footerDesc: "macOS İçin Akıllı Pencere ve Masaüstü Yöneticisi",
    footerReleases: "Sürümler",
    footerCreatedBy: "Geliştiren",
    footerRights: "Tüm hakları saklıdır."
  },

  es: {
    // Navegación
    navFeatures: "Características",
    navQuickSwitch: "Cambio Rápido",
    navDesktopClean: "Escritorio",
    navWorkspaces: "Espacios",
    navFaq: "Preguntas",
    downloadBtnNav: "Descargar",

    // Hero
    heroBadge: "Certificado y Notarizado por Apple • macOS 14+",
    heroDownloadCount: "🚀 16+ Descargas",
    heroTitlePart1: "El Administrador de Ventanas y",
    heroTitlePart2: "Escritorio que le Faltaba a macOS",
    heroDescription: "Optimiza tu flujo de trabajo en Mac. Acoplamiento instantáneo de ventanas, cambio rápido visual con ⌥Tab, organizador de escritorio con 1 clic, espacios de trabajo guardados y forzar salida de apps limpiamente.",
    heroBtnSubtext: "Descarga Gratuita para macOS",
    heroBtnMaintext: "Descargar Desktop Organizer",
    heroGithubBtn: "Destacar en GitHub",
    heroSpecSilicon: "⚡ Apple Silicon (M1/M2/M3/M4) e Intel",
    heroSpecMacOS: "🖥️ macOS 14.0+ Sonoma y Sequoia",
    heroSpecOffline: "🔒 100% Sin Conexión y Privado",

    // Mockup Ventana
    mockupTabWindows: "Ventanas",
    mockupTabQuickSwitch: "Cambio Rápido (⌥Tab)",
    mockupTabDesktop: "Organizador de Escritorio",
    mockupLang: "🇪🇸 ES",
    mockupSearchPlaceholder: "Buscar ventanas o apps...",
    mockupViewLarge: "◫ Tarjetas Grandes",
    mockupViewCompact: "▦ Compacto",
    mockupViewList: "☰ Lista",
    mockupCountBadge: "● 4 Ventanas Abiertas",

    mockupHudTitle: "⚡ Cambio Rápido de Ventanas",
    mockupHudCount: "4 Ventanas",
    mockupHudEnter: "Enter ↵",
    mockupHudNav: "<kbd>← →</kbd> Navegar",
    mockupHudNext: "<kbd>Tab</kbd> Siguiente",
    mockupHudSwitch: "<kbd>Enter ↵</kbd> Cambiar",
    mockupHudQuit: "<kbd class=\"red\">Q</kbd> Forzar Salida",
    mockupHudClose: "<kbd>ESC</kbd> Cerrar",

    mockupAutoCleanBtn: "Organizar Escritorio Automáticamente",
    mockupHideIconsBtn: "Ocultar Iconos del Escritorio",
    mockupCatImages: "Imágenes y Fotos",
    mockupCatDocs: "Documentos",
    mockupCatDownloads: "Descargas y Archivos",
    mockupCatImgFiles: "captura_1.png, banner.jpg, logo.svg...",
    mockupCatDocFiles: "Factura-2026.pdf, Notas.docx, plan.md...",
    mockupCatDownFiles: "proyecto-backup.zip, node-v20.pkg...",

    // Características
    featBadge: "DISEÑADO PARA LA VELOCIDAD Y PRODUCTIVIDAD",
    featTitle: "Todo lo que necesitas para dominar tu pantalla en Mac",
    featSubtitle: "Deja de buscar ventanas perdidas o lidiar con un escritorio caótico. Desktop Organizer te da el control total.",

    f1Title: "Acoplamiento Inteligente de Ventanas",
    f1Desc: "Acopla fácilmente cualquier ventana a la izquierda, derecha, centro o pantalla completa. Fija notas importantes encima de todo mientras trabajas.",
    tagSnapLeft: "◧ Acoplar Izquierda",
    tagSnapRight: "◨ Acoplar Derecha",
    tagMaximize: "⬚ Maximizar",
    tagPin: "📌 Fijar Arriba",

    f2Title: "HUD Visual de Cambio Rápido con ⌥Tab",
    f2Desc: "Olvídate del selector básico de apps. Mira miniaturas en vivo de tus ventanas. Navega con las flechas, pulsa Enter para cambiar o pulsa Q para cerrar al instante.",
    tagPreviews: "Vistas Previas en Vivo",

    f3Title: "Organizador de Escritorio en 1 Clic",
    f3Desc: "¿Caos en el escritorio? Un solo clic clasifica todo en carpetas: Imágenes, Documentos, Archivos, Aplicaciones y Código. O haz invisibles los iconos para compartir pantalla.",
    tagSmartCat: "Categorías Inteligentes",
    tagHideIcons: "Ocultar Iconos",

    f4Title: "Espacios de Trabajo Guardados (Sesiones)",
    f4Desc: "¿Organizas tu pantalla para programar, investigar o editar video? Guarda tus ubicaciones de ventanas con un clic y restaura todo tu diseño al instante.",
    tagSnapshots: "Capturas de Diseño",
    tagInstantRestore: "Restauración Instantánea",
    tagMultiMonitor: "Multi-Monitor",

    f5Title: "Forzar Salida Inmediata para Apps Bloqueadas",
    f5Desc: "¿Apps congeladas que no se cierran del Dock? Haz Option+Clic en cualquier botón de cierre o presiona ⌥⇧Q para terminar procesos al instante.",
    tagDockClean: "Limpieza del Dock",

    f6Title: "Cero Telemetría. 100% Swift Nativo",
    f6Desc: "Sin el peso de Electron. Creado exclusivamente en Swift 6 nativo y SwiftUI. Funciona con menos de 20MB de RAM, inicio instantáneo y privacidad total.",
    tagZeroTracking: "Sin Rastreo",

    // Tabla Comparativa
    compBadge: "¿POR QUÉ DESKTOP ORGANIZER?",
    compTitle: "macOS Tradicional vs. Desktop Organizer",
    compColFeature: "Capacidad de Trabajo",
    compColDefault: "macOS Estándar",
    compRow1: "Selector Visual de Ventanas ⌥Tab con Vistas Previas",
    compRow1Default: "❌ Solo iconos de app, sin vista previa",
    compRow1Pro: "✅ Miniaturas en vivo, flechas y cierre con Q",
    compRow2: "Acoplar Izquierda / Derecha / Maximizar con 1 Clic",
    compRow2Default: "⚠️ Menú verde tosco y lento",
    compRow2Pro: "✅ Controles rápidos en tarjetas y menú",
    compRow3: "Clasificación Automática de Archivos del Escritorio",
    compRow3Default: "❌ Requiere arrastrar a mano",
    compRow3Pro: "✅ Clasificación inteligente instantánea",
    compRow4: "Guardar y Restaurar Diseños de Espacios de Trabajo",
    compRow4Default: "❌ No soportado de forma nativa",
    compRow4Pro: "✅ Guarda diseños con nombre y restaura cuando quieras",
    compRow5: "Forzar Salida Rápida de Apps Bloqueadas",
    compRow5Default: "⚠️ Proceso de 4 pasos en Monitor de Actividad",
    compRow5Pro: "✅ 1 clic Option+Cerrar o atajo ⌥⇧Q",

    // Instalación
    installBadge: "EMPIEZA EN 30 SEGUNDOS",
    installTitle: "Instalación sencilla en 3 pasos",
    step1Title: "Descarga el ZIP",
    step1Desc: "Haz clic en el botón de descarga para obtener el paquete oficial y notarizado DesktopOrganizer.zip.",
    step2Title: "Mueve a Aplicaciones",
    step2Desc: "Descomprime el archivo zip y arrastra DesktopOrganizer.app a tu carpeta de Aplicaciones de macOS.",
    step3Title: "Abre y Presiona ⌥A",
    step3Desc: "Abre la app, concede el permiso de Accesibilidad una sola vez y controla tu escritorio desde la barra de menú o con ⌥A.",

    // FAQ
    faqBadge: "PREGUNTAS FRECUENTES",
    faqTitle: "Preguntas y Respuestas Habituales",
    faq1Q: "¿macOS mostrará una advertencia de seguridad de \"Desarrollador no identificado\" o Gatekeeper?",
    faq1A: "<strong>¡No!</strong> Desktop Organizer está firmado oficialmente con un Apple Developer ID y completamente <strong>Notarizado por Apple</strong>. Gatekeeper lo verifica automáticamente sin ningún bloqueo de seguridad.",
    faq2Q: "¿Qué versiones de macOS y modelos de Mac son compatibles?",
    faq2A: "Desktop Organizer está diseñado para macOS 14.0+ Sonoma y macOS 15.0+ Sequoia. Funciona de manera nativa tanto en Apple Silicon (M1, M2, M3, M4) como en Mac con Intel.",
    faq3Q: "¿Por qué Desktop Organizer necesita permiso de Accesibilidad?",
    faq3A: "macOS requiere permisos de Accesibilidad para que la app pueda enfocar ventanas, moverlas/acoplarlas cuando haces clic en los botones y forzar salida. Todos los datos permanecen 100% en tu máquina local.",
    faq4Q: "¿Cómo funcionan las actualizaciones automáticas?",
    faq4A: "La aplicación comprueba GitHub Releases en segundo plano. Cuando sale una nueva versión, aparece un banner verde 🚀 en la app. Un solo clic descarga y reinicia la app con la versión más reciente.",
    faq5Q: "¿Desktop Organizer es gratuito y de código abierto?",
    faq5A: "¡Sí! Desktop Organizer es de código abierto en GitHub. Puedes revisar el código fuente, colaborar o descargarlo y usarlo de forma totalmente gratuita.",

    // Banner CTA
    ctaBannerTitle: "¿Listo para organizar tu escritorio en Mac?",
    ctaBannerSubtitle: "Descarga Desktop Organizer hoy. Gratis, notarizado y de código abierto.",
    ctaDownloadBtn: "Descargar para macOS",
    ctaSubnote: "Requiere macOS 14.0 Sonoma o posterior • Apple Silicon e Intel",

    // Footer
    footerDesc: "Administrador Inteligente de Ventanas y Escritorio para macOS",
    footerReleases: "Versiones",
    footerCreatedBy: "Creado por",
    footerRights: "Todos los derechos reservados."
  }
};

// MARK: - State & Language Switcher Engine
let currentLang = 'en';

// Detect preferred browser language (TR if starts with tr, ES if starts with es, else EN)
const savedLang = localStorage.getItem('desktoporganizer_lang');
if (savedLang === 'tr' || savedLang === 'en' || savedLang === 'es') {
  currentLang = savedLang;
} else {
  const userBrowserLang = (navigator.language || navigator.userLanguage || '').toLowerCase();
  if (userBrowserLang.startsWith('tr')) {
    currentLang = 'tr';
  } else if (userBrowserLang.startsWith('es')) {
    currentLang = 'es';
  }
}

function updateLanguage(lang) {
  currentLang = lang;
  localStorage.setItem('desktoporganizer_lang', lang);
  const t = translations[lang] || translations.en;

  // 1. Update all elements with data-i18n
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (t[key] !== undefined) {
      el.innerHTML = t[key];
    }
  });

  // 2. Update Segmented Nav Buttons
  document.querySelectorAll('.lang-btn').forEach(btn => {
    if (btn.getAttribute('data-lang') === lang) {
      btn.classList.add('active');
    } else {
      btn.classList.remove('active');
    }
  });

  // 3. Update Mockup Header Language Pill
  const mockupLangIndicator = document.getElementById('mockup-lang-indicator');
  if (mockupLangIndicator) {
    if (lang === 'tr') mockupLangIndicator.textContent = '🇹🇷 TR';
    else if (lang === 'es') mockupLangIndicator.textContent = '🇪🇸 ES';
    else mockupLangIndicator.textContent = '🇺🇸 EN';
  }

  // 4. Update Mockup Card Button Tooltips
  const snapLeftBtns = document.querySelectorAll('.snap-btn:nth-child(1)');
  snapLeftBtns.forEach(btn => {
    btn.title = lang === 'tr' ? 'Sola Yasla' : (lang === 'es' ? 'Acoplar Izquierda' : 'Snap Left');
  });

  const snapMaxBtns = document.querySelectorAll('.snap-btn:nth-child(2)');
  snapMaxBtns.forEach(btn => {
    btn.title = lang === 'tr' ? 'Tam Ekran' : (lang === 'es' ? 'Maximizar' : 'Maximize');
  });

  const snapRightBtns = document.querySelectorAll('.snap-btn:nth-child(3)');
  snapRightBtns.forEach(btn => {
    btn.title = lang === 'tr' ? 'Sağa Yasla' : (lang === 'es' ? 'Acoplar Derecha' : 'Snap Right');
  });

  const forceQuitBtns = document.querySelectorAll('.force-quit-btn');
  forceQuitBtns.forEach(btn => {
    btn.title = lang === 'tr' ? 'Uygulamayı Zorla Kapat' : (lang === 'es' ? 'Forzar Salida' : 'Force Quit App');
  });

  // 5. Update html lang attribute
  document.documentElement.lang = lang;
}

// MARK: - Event Listeners on DOM Ready
document.addEventListener('DOMContentLoaded', () => {
  // 1. Initialize language
  updateLanguage(currentLang);

  // 2. Segmented Language Switcher Listeners
  document.querySelectorAll('.lang-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const selected = btn.getAttribute('data-lang');
      if (selected) updateLanguage(selected);
    });
  });

  // Mockup language indicator cycle (EN -> TR -> ES -> EN)
  const mockupLangIndicator = document.getElementById('mockup-lang-indicator');
  if (mockupLangIndicator) {
    mockupLangIndicator.style.cursor = 'pointer';
    mockupLangIndicator.addEventListener('click', () => {
      const order = ['en', 'tr', 'es'];
      const nextIndex = (order.indexOf(currentLang) + 1) % order.length;
      updateLanguage(order[nextIndex]);
    });
  }

  // 3. Interactive Mockup Tab Switching
  const mockupTabs = document.querySelectorAll('.mac-tab');
  mockupTabs.forEach(tab => {
    tab.addEventListener('click', () => {
      mockupTabs.forEach(t => t.classList.remove('active'));
      tab.classList.add('active');

      const targetTab = tab.getAttribute('data-mockup-tab');
      document.querySelectorAll('.mockup-view').forEach(view => {
        view.classList.remove('active');
      });

      const activeView = document.getElementById(`view-${targetTab}`);
      if (activeView) {
        activeView.classList.add('active');
      }
    });
  });

  // 4. FAQ Accordion Toggle
  const faqItems = document.querySelectorAll('.faq-item');
  faqItems.forEach(item => {
    const questionBtn = item.querySelector('.faq-question');
    questionBtn.addEventListener('click', () => {
      const isOpen = item.classList.contains('active');
      faqItems.forEach(i => i.classList.remove('active'));
      if (!isOpen) {
        item.classList.add('active');
      }
    });
  });

  // 5. Ambient Cursor Glow on Hero Window
  const macWindow = document.querySelector('.mac-window');
  if (macWindow) {
    macWindow.addEventListener('mousemove', (e) => {
      const rect = macWindow.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      macWindow.style.background = `radial-gradient(circle at ${x}px ${y}px, rgba(30, 41, 59, 0.95), rgba(15, 20, 32, 0.85) 60%)`;
    });
    macWindow.addEventListener('mouseleave', () => {
      macWindow.style.background = 'rgba(15, 20, 32, 0.85)';
    });
  }

  // 6. Fetch live download count from GitHub Releases API
  fetchLiveDownloadCount();
});

// MARK: - Live Download Count Fetcher
async function fetchLiveDownloadCount() {
  try {
    const res = await fetch('https://api.github.com/repos/mertkanak/urban-palm-tree/releases');
    if (!res.ok) return;
    const releases = await res.json();
    let totalDownloads = 0;
    releases.forEach(rel => {
      if (rel.assets && Array.isArray(rel.assets)) {
        rel.assets.forEach(asset => {
          if (asset.name && asset.name.endsWith('.zip')) {
            totalDownloads += (asset.download_count || 0);
          }
        });
      }
    });

    const displayCount = Math.max(totalDownloads, 16);
    const countFormatted = displayCount >= 1000 ? `${(displayCount / 1000).toFixed(1)}k+` : `${displayCount}+`;

    translations.en.heroDownloadCount = `🚀 ${countFormatted} Downloads`;
    translations.tr.heroDownloadCount = `🚀 ${countFormatted} Kez İndirildi`;
    translations.es.heroDownloadCount = `🚀 ${countFormatted} Descargas`;

    const el = document.getElementById('live-download-counter');
    if (el) {
      el.textContent = translations[currentLang]?.heroDownloadCount || `🚀 ${countFormatted} Downloads`;
    }
  } catch (e) {
    // Graceful fallback to default 16+
  }
}
