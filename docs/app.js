/**
 * Desktop Organizer — Landing Page Interactive Scripts
 * Features: 100% Comprehensive Bilingual I18n Engine (EN/TR), Interactive Mockup Tabs, FAQ Accordion.
 */

// MARK: - Bilingual Translations Dictionary
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
    heroBadge: "Apple Noter Onaylı & Gatekeeper Güvenli • macOS 14+",
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
  }
};

// MARK: - State & Language Switcher Engine
let currentLang = 'en';

// Detect preferred browser language (TR if starts with tr, else EN)
const savedLang = localStorage.getItem('desktoporganizer_lang');
if (savedLang === 'tr' || savedLang === 'en') {
  currentLang = savedLang;
} else {
  const userBrowserLang = navigator.language || navigator.userLanguage || '';
  if (userBrowserLang.toLowerCase().startsWith('tr')) {
    currentLang = 'tr';
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
  const btnEn = document.getElementById('btn-lang-en');
  const btnTr = document.getElementById('btn-lang-tr');
  if (btnEn && btnTr) {
    if (lang === 'tr') {
      btnTr.classList.add('active');
      btnEn.classList.remove('active');
    } else {
      btnEn.classList.add('active');
      btnTr.classList.remove('active');
    }
  }

  // 3. Update Mockup Header Language Pill
  const mockupLangIndicator = document.getElementById('mockup-lang-indicator');
  if (mockupLangIndicator) {
    mockupLangIndicator.textContent = lang === 'tr' ? '🇹🇷 TR' : '🇺🇸 EN';
  }

  // 4. Update Mockup Card Button Tooltips
  const snapLeftBtns = document.querySelectorAll('.snap-btn[title="Snap Left"], .snap-btn[title="Sola Yasla"]');
  snapLeftBtns.forEach(btn => btn.title = lang === 'tr' ? 'Sola Yasla' : 'Snap Left');

  const snapMaxBtns = document.querySelectorAll('.snap-btn[title="Maximize"], .snap-btn[title="Tam Ekran"]');
  snapMaxBtns.forEach(btn => btn.title = lang === 'tr' ? 'Tam Ekran' : 'Maximize');

  const snapRightBtns = document.querySelectorAll('.snap-btn[title="Snap Right"], .snap-btn[title="Sağa Yasla"]');
  snapRightBtns.forEach(btn => btn.title = lang === 'tr' ? 'Sağa Yasla' : 'Snap Right');

  const forceQuitBtns = document.querySelectorAll('.force-quit-btn');
  forceQuitBtns.forEach(btn => btn.title = lang === 'tr' ? 'Uygulamayı Zorla Kapat' : 'Force Quit App');

  // 5. Update html lang attribute
  document.documentElement.lang = lang;
}

// MARK: - Event Listeners on DOM Ready
document.addEventListener('DOMContentLoaded', () => {
  // 1. Initialize language
  updateLanguage(currentLang);

  // 2. Segmented Language Switcher Listeners
  const btnEn = document.getElementById('btn-lang-en');
  const btnTr = document.getElementById('btn-lang-tr');
  if (btnEn) {
    btnEn.addEventListener('click', () => updateLanguage('en'));
  }
  if (btnTr) {
    btnTr.addEventListener('click', () => updateLanguage('tr'));
  }

  // Mockup language indicator is also clickable!
  const mockupLangIndicator = document.getElementById('mockup-lang-indicator');
  if (mockupLangIndicator) {
    mockupLangIndicator.style.cursor = 'pointer';
    mockupLangIndicator.addEventListener('click', () => {
      updateLanguage(currentLang === 'en' ? 'tr' : 'en');
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
});
