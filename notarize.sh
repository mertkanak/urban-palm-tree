#!/usr/bin/env bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

APP_NAME="DesktopOrganizer"
BUILD_DIR="$PROJECT_DIR/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
ENTITLEMENTS="$PROJECT_DIR/DesktopOrganizer/Resources/DesktopOrganizer.entitlements"

echo "=========================================="
echo "  Desktop Organizer Notarization Pipeline "
echo "=========================================="

# 1. Developer ID Application sertifikasını bul
IDENTITY=$(security find-identity -v -p codesigning | grep "Developer ID Application:" | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$IDENTITY" ]; then
    echo "❌ HATA: 'Developer ID Application' sertifikası Keychain'de bulunamadı!"
    echo "Lütfen Xcode -> Settings -> Accounts -> Manage Certificates -> '+' -> Developer ID Application adımlarını tamamlayın."
    exit 1
fi

echo "-> Bulunan Sertifika: $IDENTITY"

# 2. Önce temiz derleme yap
echo "-> Uygulama derleniyor..."
./build.sh

# 3. Hardened Runtime ve Developer ID ile İmzala
echo "-> Uygulama Developer ID ve Hardened Runtime ile imzalanıyor..."
codesign --force --deep --verify --verbose \
    --options runtime \
    --timestamp \
    --sign "$IDENTITY" \
    --entitlements "$ENTITLEMENTS" \
    "$APP_BUNDLE"

echo "-> İmza doğrulanıyor..."
codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"

# 4. Apple Notarytool için ZIP paketi hazırla
ZIP_NAME="$BUILD_DIR/DesktopOrganizer-to-notarize.zip"
echo "-> Notarytool için paketleniyor..."
rm -f "$ZIP_NAME"
ditto -c -k --sequesterRsrc --keepParent "$APP_BUNDLE" "$ZIP_NAME"

# 5. Apple sunucularına gönder ve onayı bekle
echo "-> Apple sunucularına gönderiliyor ve onay bekleniyor (bu işlem 1-3 dk sürebilir)..."
xcrun notarytool submit "$ZIP_NAME" \
    --keychain-profile "notary-profile" \
    --wait

# 6. Onay biletini uygulamaya mühürle (Staple)
echo "-> Onay bileti uygulamaya mühürleniyor (Staple)..."
xcrun stapler staple "$APP_BUNDLE"

# 7. Gatekeeper çevrimdışı doğrulama testi
echo "-> Gatekeeper doğrulaması test ediliyor..."
spctl --assess --type execute --verbose "$APP_BUNDLE"

# 8. Web sitesinden dağıtım için son ZIP'i oluştur
FINAL_ZIP="$PROJECT_DIR/DesktopOrganizer-signed.zip"
rm -f "$FINAL_ZIP"
ditto -c -k --sequesterRsrc --keepParent "$APP_BUNDLE" "$FINAL_ZIP"

echo ""
echo "========================================================="
echo "🎉 TEBRİKLER! Uygulama başarıyla Notarize edildi ve mühürlendi!"
echo "Dağıtım ZIP Dosyası: $FINAL_ZIP"
echo "Bu ZIP'i indiren hiçbir Mac kullanıcısı güvenlik uyarısı almaz!"
echo "========================================================="
