# 🖥️ Desktop Organizer

**macOS 14+ için SwiftUI + AppKit tabanlı, tam özellikli Akıllı Pencere & Masaüstü Yöneticisi**

[![Release](https://img.shields.io/github/v/release/mertkanak/urban-palm-tree?color=blue&label=Son%20S%C3%BCr%C3%BCm)](https://github.com/mertkanak/urban-palm-tree/releases/latest)
[![Platform](https://img.shields.io/badge/Platform-macOS%2014.0%2B%20%28Sonoma%29-black?logo=apple)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange?logo=swift)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## ⚡ Hızlı İndir ve Başlat (Git veya Xcode Gerekmez!)

Uygulamayı kullanmak için herhangi bir kodlama veya geliştirici aracına ihtiyacınız yoktur. Doğrudan hazır paketi indirip kullanabilirsiniz:

### 📥 1. Adım: İndirin
👉 **[En Son Sürümü İndirin (DesktopOrganizer.zip)](https://github.com/mertkanak/urban-palm-tree/releases/latest)**

### 📦 2. Adım: Kurun
1. İndirdiğiniz `DesktopOrganizer.zip` dosyasına çift tıklayarak açın.
2. Çıkan `DesktopOrganizer.app` uygulamasını **Uygulamalar** (`Applications`) klasörünüze sürükleyip bırakın.
3. Uygulamayı çalıştırın. Menü çubuğunuzda menü simgesi belirecektir.

---

### ⚠️ İlk Açılışta "Apple Geliştiriciyi Doğrulayamadı" Uyarısı Alırsanız:
Apple, yıllık 99$ geliştirici programı üyeliği olmayan açık kaynaklı bağımsız projelerde bu güvenlik uyarısını ilk açılışta gösterir. Bu durum tamamen normaldir ve **yalnızca ilk seferde 1 kez** çözmeniz yeterlidir:

#### Yöntem 1 (Önerilen - Finder İle):
1. **Finder** > **Uygulamalar** klasörüne gidin.
2. `DesktopOrganizer` uygulamasına **sağ tıklayın** (veya Control tuşuna basılı tutarak tıklayın).
3. Menüden **Aç (Open)** seçeneğini seçin.
4. Açılan diyalog kutusunda **"Aç" (Open)** butonuna tıklayın. Artık uygulama normal şekilde çift tıklanarak da açılacaktır.

#### Yöntem 2 (Terminal İle - Tek Satır):
Terminal uygulamasını açıp şu komutu yapıştırın ve Enter'a basın:
```bash
xattr -cr /Applications/DesktopOrganizer.app
```

---

## 🔄 Otomatik Güncelleme Sistemi (Auto-Updater)
Desktop Organizer, entegre GitHub Releases desteğine sahiptir:
- Yeni bir sürüm yayınlandığında menü panelinizin üst kısmında **"Yeni Sürüm Mevcut"** bildirimi belirir.
- **"Şimdi Güncelle"** butonuna basmanız yeterlidir.
- Uygulama otomatik olarak yeni ZIP paketini indirir, `/Applications` klasöründeki eski sürümü günceller ve uygulamayı yeniden başlatır. 
- Bir daha asla elle dosya indirmek veya güncellemek zorunda kalmazsınız!

---

## ✨ Temel Özellikler

### 🪟 Akıllı Pencere Yönetimi
- **Canlı Önizleme (ScreenCaptureKit):** Tüm açık pencereler gerçek zamanlı küçük resimlerle (thumbnail) listelenir.
- **Tek Tıkla Odaklanma (AXUIElement):** İstediğiniz karta tıklayarak ilgili pencereyi anında en öne getirin.
- **Sürükle-Bırak Konumlandırma:** Kartı sürükleyerek pencereyi masaüstünüzde istediğiniz yere taşıyın.
- **Tiling & Snap:** Sol yarı, sağ yarı, tam ekran veya ortalama kısayolları ile pencerelerinizi ekranınıza yerleştirin.
- **Pencere Sabitleme (Pin):** Sık kullandığınız pencereleri listenin en tepesine sabitleyin.
- **Son Kullanılanlar Şeridi:** Son aktif olan pencerelere grid üstündeki hızlı banttan tek tıkla ulaşın.

### ⚡ Quick Switcher (Spotlight Tarzı Hızlı Geçiş)
- `⌥ + Tab` (Option + Tab) kısayolu ile açılan kompakt pencere arama çubuğu.
- `↑` ve `↓` yön tuşları ile gezinip `Enter` ile pencereye geçin.
- `⌘ + 1...9` kısayollarıyla ilk 9 pencereye anında zıplayın.

### 💾 Pencere Çalışma Alanları (Session Management)
- Farklı projeler veya iş akışları için pencere konumlarınızı ve açık pencerelerinizi **"Session"** olarak kaydedin.
- Dilediğiniz zaman tek tıkla kayıtlı pencere düzeninizi masaüstünüze geri yükleyin.

### 📁 Masaüstü Dosya Düzenleyici
- Masaüstünüzdeki dağınık dosyaları kategorilere göre (Görseller, Dokümanlar, İndirilenler, Kod vb.) otomatik gruplayın.
- **"Masaüstünü Gizle/Göster"** anahtarı ile masaüstü simgelerini tek tıkla temizleyin.
- Canlı dosya izleyici ile masaüstüne gelen yeni dosyalar anında arayüze yansır.

---

## ⌨️ Kısayollar

| Kısayol | İşlev |
|---------|-------|
| `⌥ + Space` (Option + Boşluk) | Ana Overlay Panelini Aç / Kapat |
| `⌥ + Tab` (Option + Tab) | Quick Switch (Spotlight Tarzı Hızlı Geçiş) |
| `⌘ + 1...9` | Quick Switch panelinde ilk 9 pencereye doğrudan geçiş |
| `ESC` | Panelleri Kapat |

---

## 🔑 Gerekli İzinler

Uygulama ilk kez başlatıldığında macOS tarafından iki temel sistem izni istenir:
1. **Erişilebilirlik (Accessibility):** Pencereleri öne getirmek, taşımak ve yeniden boyutlandırmak için gereklidir.
2. **Ekran Kaydı (Screen Recording):** Açık pencerelerin canlı küçük resim önizlemelerini oluşturmak için gereklidir.

> İzinler verilmediğinde arayüz üzerinde rehberlik eden uyarı paneli görünür ve tek tıkla Sistem Ayarları'na yönlendirir.

---

## 🛠️ Geliştiriciler İçin (Kaynak Koddan Derleme)

Projeyi kendiniz derlemek isterseniz:

```bash
# Depoyu klonlayın
git clone https://github.com/mertkanak/urban-palm-tree.git
cd urban-palm-tree

# Hızlı derleme ve çalıştırma scripti
bash build.sh run
```

Veya `DesktopOrganizer.xcodeproj` dosyasını Xcode ile açıp `⌘ + R` ile çalıştırabilirsiniz.

---

## 📄 Lisans
Bu proje MIT lisansı altında sunulmaktadır.
