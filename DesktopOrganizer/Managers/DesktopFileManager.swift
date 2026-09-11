import AppKit
import Combine
import Foundation

/// Masaüstü dizinindeki (Desktop) dosyaları izleyen, listeleyen ve kategorize eden yönetici
public final class DesktopFileManager: @unchecked Sendable {
    public static let shared = DesktopFileManager()

    private let fileManager = FileManager.default
    private var desktopFolderSource: DispatchSourceFileSystemObject?
    private let queue = DispatchQueue(label: "com.desktoporganizer.filemanager", qos: .utility)

    public var desktopURL: URL {
        fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first!
    }

    private init() {}

    deinit {
        stopWatchingDesktop()
    }

    // MARK: - Dosya Listeleme

    /// Masaüstündeki tüm dosya ve klasörleri asenkron olarak tarar
    public func fetchDesktopItems() -> [DesktopFileItem] {
        let desktop = desktopURL
        let resourceKeys: Set<URLResourceKey> = [
            .nameKey,
            .isDirectoryKey,
            .fileSizeKey,
            .contentModificationDateKey,
            .isHiddenKey
        ]

        guard let contents = try? fileManager.contentsOfDirectory(
            at: desktop,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var items: [DesktopFileItem] = []
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file

        for url in contents {
            let filename = url.lastPathComponent

            // Gizli sistem dosyalarını (.DS_Store, .localized vb.) atla
            if filename.hasPrefix(".") || filename == "Icon\r" {
                continue
            }

            guard let resourceValues = try? url.resourceValues(forKeys: resourceKeys) else {
                continue
            }

            let isDir = resourceValues.isDirectory ?? false
            let size = Int64(resourceValues.fileSize ?? 0)
            let modDate = resourceValues.contentModificationDate ?? Date()
            let category = isDir ? (url.pathExtension == "app" ? .applications : .other) : FileCategory.category(for: url)
            let icon = NSWorkspace.shared.icon(forFile: url.path)

            let item = DesktopFileItem(
                url: url,
                name: filename,
                category: category,
                icon: icon,
                sizeBytes: size,
                sizeString: isDir ? "Klasör" : formatter.string(fromByteCount: size),
                modifiedDate: modDate,
                isDirectory: isDir
            )
            items.append(item)
        }

        return items.sorted { $0.modifiedDate > $1.modifiedDate }
    }

    // MARK: - Masaüstü İzleme (File System Watcher)

    /// Masaüstü klasöründeki değişiklikleri DispatchSource ile canlı izler
    public func startWatchingDesktop(onChange: @escaping @Sendable () -> Void) {
        stopWatchingDesktop()

        let descriptor = open(desktopURL.path, O_EVTONLY)
        guard descriptor >= 0 else { return }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: [.write, .rename, .delete, .attrib],
            queue: queue
        )

        source.setEventHandler {
            onChange()
        }

        source.setCancelHandler {
            close(descriptor)
        }

        source.resume()
        desktopFolderSource = source
    }

    public func stopWatchingDesktop() {
        desktopFolderSource?.cancel()
        desktopFolderSource = nil
    }

    // MARK: - Masaüstü İkonlarını Gizle / Göster

    /// Masaüstündeki ikonları Finder CreateDesktop anahtarı üzerinden gizler veya açar
    public func toggleDesktopIconsVisibility(hide: Bool) {
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["write", "com.apple.finder", "CreateDesktop", "-bool", hide ? "false" : "true"]
        try? task.run()
        task.waitUntilExit()

        let restartTask = Process()
        restartTask.launchPath = "/usr/bin/killall"
        restartTask.arguments = ["Finder"]
        try? restartTask.run()
    }
}
