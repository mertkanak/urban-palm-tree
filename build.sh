#!/usr/bin/env bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

APP_NAME="DesktopOrganizer"
BUILD_DIR="$PROJECT_DIR/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "=========================================="
echo "  Desktop & Window Organizer Build Script"
echo "=========================================="

# 1. Klasörleri hazırla
rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

# 2. Kaynak dosyaları listele
SOURCES=(
    "DesktopOrganizer/Models/PermissionState.swift"
    "DesktopOrganizer/Models/FileCategory.swift"
    "DesktopOrganizer/Models/DesktopFileItem.swift"
    "DesktopOrganizer/Models/WindowItem.swift"
    "DesktopOrganizer/Models/WindowSession.swift"
    "DesktopOrganizer/Managers/PermissionManager.swift"
    "DesktopOrganizer/Managers/AccessibilityManager.swift"
    "DesktopOrganizer/Managers/WindowCaptureManager.swift"
    "DesktopOrganizer/Managers/DesktopFileManager.swift"
    "DesktopOrganizer/Managers/SessionManager.swift"
    "DesktopOrganizer/Managers/AutoUpdater.swift"
    "DesktopOrganizer/ViewModels/WindowManager.swift"
    "DesktopOrganizer/ViewModels/DesktopIconManager.swift"
    "DesktopOrganizer/Views/Components/VisualEffectBackground.swift"
    "DesktopOrganizer/Views/Components/CardHoverEffect.swift"
    "DesktopOrganizer/Views/Components/UpdateBannerView.swift"
    "DesktopOrganizer/Views/Permissions/PermissionWarningBanner.swift"
    "DesktopOrganizer/Views/WindowsGrid/WindowSearchBar.swift"
    "DesktopOrganizer/Views/WindowsGrid/WindowCardView.swift"
    "DesktopOrganizer/Views/WindowsGrid/WindowMiniCardView.swift"
    "DesktopOrganizer/Views/WindowsGrid/RecentWindowsStrip.swift"
    "DesktopOrganizer/Views/WindowsGrid/WindowGridView.swift"
    "DesktopOrganizer/Views/DesktopOrganizer/FileCategorySectionView.swift"
    "DesktopOrganizer/Views/DesktopOrganizer/DesktopOrganizerView.swift"
    "DesktopOrganizer/Views/Sessions/SessionManagerView.swift"
    "DesktopOrganizer/Views/QuickSwitch/QuickSwitchView.swift"
    "DesktopOrganizer/Views/MainOverlayView.swift"
    "DesktopOrganizer/App/AppDelegate.swift"
    "DesktopOrganizer/App/DesktopOrganizerApp.swift"
)

echo "-> Swift kaynak dosyaları derleniyor (macOS 14+ / Apple Silicon)..."

CACHE_DIR="$PROJECT_DIR/.build_cache"
TMP_DIR="$PROJECT_DIR/.tmp"
mkdir -p "$CACHE_DIR" "$TMP_DIR"

TMPDIR="$TMP_DIR" swiftc \
    -module-cache-path "$CACHE_DIR" \
    -parse-as-library \
    -O \
    -target arm64-apple-macosx14.0 \
    -sdk "$(xcrun --show-sdk-path)" \
    -framework Cocoa \
    -framework SwiftUI \
    -framework ScreenCaptureKit \
    -framework ApplicationServices \
    -framework CoreGraphics \
    -framework UniformTypeIdentifiers \
    "${SOURCES[@]}" \
    -o "$MACOS_DIR/$APP_NAME"

# Geçici derleme önbelleğini temizle (disk tasarrufu için)
rm -rf "$TMP_DIR"

# 3. Info.plist ve Entitlements kopyala
echo "-> Paket dosyaları ve Info.plist hazırlanıyor..."
cp "DesktopOrganizer/Resources/Info.plist" "$CONTENTS_DIR/Info.plist"
echo -n "APPL????" > "$CONTENTS_DIR/PkgInfo"

# 4. Kod İmzalama (Ad-hoc)
echo "-> Uygulama imzalanıyor (ad-hoc codesign)..."
codesign --force --deep --sign - --entitlements "DesktopOrganizer/Resources/DesktopOrganizer.entitlements" "$APP_BUNDLE" 2>/dev/null || true

echo ""
echo " Derleme başarıyla tamamlandı!"
echo " Paket Yolu: $APP_BUNDLE"
echo ""

# 5. Çalıştırma argümanı kontrolü
if [ "$1" == "run" ]; then
    echo "-> Uygulama başlatılıyor..."
    open "$APP_BUNDLE"
fi
