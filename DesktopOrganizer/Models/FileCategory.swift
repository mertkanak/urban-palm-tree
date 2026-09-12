import SwiftUI
import UniformTypeIdentifiers

/// Masaüstü dosyalarının gruplandığı kategoriler
public enum FileCategory: String, CaseIterable, Identifiable, Sendable {
    case images = "Resimler"
    case documents = "Dokümanlar"
    case downloads = "İndirilenler / Arşivler"
    case applications = "Uygulamalar"
    case developer = "Kod & Geliştirme"
    case other = "Diğer"

    public var id: String { rawValue }

    @MainActor
    public var localizedTitle: String {
        L10n.categoryName(rawValue)
    }

    public var systemIconName: String {
        switch self {
        case .images:
            return "photo.on.rectangle.angled"
        case .documents:
            return "doc.text.fill"
        case .downloads:
            return "archivebox.fill"
        case .applications:
            return "app.badge.checkmark.fill"
        case .developer:
            return "chevron.left.forwardslash.chevron.right"
        case .other:
            return "folder.fill"
        }
    }

    public var color: Color {
        switch self {
        case .images:
            return Color.purple
        case .documents:
            return Color.blue
        case .downloads:
            return Color.orange
        case .applications:
            return Color.green
        case .developer:
            return Color.cyan
        case .other:
            return Color.gray
        }
    }

    /// Verilen dosya URL'sine göre kategoriyi belirler
    public static func category(for url: URL) -> FileCategory {
        let ext = url.pathExtension.lowercased()

        // 1. Uygulama kontrolü
        if ext == "app" {
            return .applications
        }

        // 2. Resimler
        let imageExtensions: Set<String> = ["png", "jpg", "jpeg", "heic", "gif", "webp", "svg", "bmp", "tiff", "ico", "psd"]
        if imageExtensions.contains(ext) {
            return .images
        }

        // 3. Dokümanlar
        let documentExtensions: Set<String> = ["pdf", "doc", "docx", "txt", "rtf", "md", "markdown", "pages", "key", "numbers", "xlsx", "xls", "csv", "pptx", "ppt", "epub"]
        if documentExtensions.contains(ext) {
            return .documents
        }

        // 4. Arşiv ve İndirilenler
        let archiveExtensions: Set<String> = ["zip", "rar", "tar", "gz", "7z", "dmg", "pkg", "iso", "bin"]
        if archiveExtensions.contains(ext) {
            return .downloads
        }

        // 5. Kod & Geliştirme
        let devExtensions: Set<String> = ["swift", "js", "ts", "jsx", "tsx", "py", "html", "css", "scss", "json", "yaml", "yml", "xml", "c", "cpp", "h", "m", "mm", "go", "rs", "java", "kt", "sh", "zsh", "sql"]
        if devExtensions.contains(ext) {
            return .developer
        }

        // 6. UTType ile yedek kontrol
        if let utType = UTType(filenameExtension: ext) {
            if utType.conforms(to: .image) {
                return .images
            }
            if utType.conforms(to: .pdf) || utType.conforms(to: .text) || utType.conforms(to: .spreadsheet) || utType.conforms(to: .presentation) {
                return .documents
            }
            if utType.conforms(to: .archive) || utType.conforms(to: .diskImage) {
                return .downloads
            }
            if utType.conforms(to: .application) {
                return .applications
            }
            if utType.conforms(to: .sourceCode) {
                return .developer
            }
        }

        return .other
    }
}
