import AppKit
import Foundation

/// GitHub Releases üzerinden otomatik güncelleme yöneten servis
/// API: https://api.github.com/repos/{owner}/{repo}/releases/latest
@MainActor
public final class AutoUpdater: ObservableObject {
    public static let shared = AutoUpdater()

    // GitHub repo koordinatları — release ZIP adı: DesktopOrganizer.zip
    private let repoOwner  = "mertkanak"
    private let repoName   = "urban-palm-tree"
    private let assetName  = "DesktopOrganizer.zip"

    @Published public var updateAvailable: Bool = false
    @Published public var latestVersion: String = ""
    @Published public var downloadURL: URL? = nil
    @Published public var isDownloading: Bool = false
    @Published public var downloadProgress: Double = 0.0
    @Published public var lastCheckError: String? = nil

    private let session = URLSession.shared
    private var checkTimer: Timer?

    public init() {}

    // MARK: - Sürüm Kontrolü

    /// Mevcut uygulamanın sürümünü döner (CFBundleShortVersionString)
    public var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    /// GitHub Releases API'sinden en son sürümü sorgular
    public func checkForUpdates() async {
        let apiURL = URL(string: "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest")!

        do {
            var request = URLRequest(url: apiURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

            let (data, response) = try await session.data(for: request)

            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                lastCheckError = "GitHub API yanıt vermedi."
                return
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let tagName = json["tag_name"] as? String
            else {
                lastCheckError = "Sürüm bilgisi okunamadı."
                return
            }

            let remoteVersion = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName

            // Asset URL bul
            var assetURL: URL? = nil
            if let assets = json["assets"] as? [[String: Any]] {
                for asset in assets {
                    if let name = asset["name"] as? String,
                       name == assetName,
                       let urlStr = asset["browser_download_url"] as? String,
                       let url = URL(string: urlStr) {
                        assetURL = url
                        break
                    }
                }
            }
            // Fallback: zipball_url
            if assetURL == nil,
               let zipball = json["zipball_url"] as? String,
               let url = URL(string: zipball) {
                assetURL = url
            }

            latestVersion = remoteVersion
            downloadURL = assetURL
            updateAvailable = isNewerVersion(remoteVersion, than: currentVersion)
            lastCheckError = nil

        } catch {
            lastCheckError = error.localizedDescription
        }
    }

    /// Arka planda periyodik sürüm kontrolü başlatır (her 2 saatte bir)
    public func startPeriodicCheck() {
        Task { await checkForUpdates() }
        checkTimer?.invalidate()
        checkTimer = Timer.scheduledTimer(withTimeInterval: 7200, repeats: true) { [weak self] _ in
            Task { await self?.checkForUpdates() }
        }
    }

    // MARK: - İndirme & Yükleme

    /// ZIP'i indirir, uygulamayı /Applications'a kopyalar, yeniden başlatır
    public func downloadAndInstall() async {
        guard let url = downloadURL else { return }

        isDownloading = true
        downloadProgress = 0

        do {
            // 1. İndir
            let tempDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("DesktopOrganizerUpdate_\(UUID().uuidString)")
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

            let zipPath = tempDir.appendingPathComponent("update.zip")
            let (localURL, _) = try await session.download(from: url)
            try FileManager.default.moveItem(at: localURL, to: zipPath)
            downloadProgress = 0.5

            // 2. ZIP'i aç
            let unzipProcess = Process()
            unzipProcess.launchPath = "/usr/bin/unzip"
            unzipProcess.arguments = ["-o", zipPath.path, "-d", tempDir.path]
            try unzipProcess.run()
            unzipProcess.waitUntilExit()
            downloadProgress = 0.75

            // 3. .app bundle'ı bul
            let contents = try FileManager.default.contentsOfDirectory(
                at: tempDir, includingPropertiesForKeys: nil
            )
            guard let appBundle = contents.first(where: { $0.pathExtension == "app" }) else {
                isDownloading = false
                return
            }

            // 4. /Applications'a kopyala (mevcut varsa sil)
            let destination = URL(fileURLWithPath: "/Applications/\(appBundle.lastPathComponent)")
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.copyItem(at: appBundle, to: destination)
            downloadProgress = 1.0

            // 5. Karantinayı kaldır ve yeniden başlat
            let xattr = Process()
            xattr.launchPath = "/usr/bin/xattr"
            xattr.arguments = ["-cr", destination.path]
            try? xattr.run()
            xattr.waitUntilExit()

            // 0.5s bekle sonra yeniden başlat
            try await Task.sleep(nanoseconds: 500_000_000)
            relaunch(with: destination)

        } catch {
            isDownloading = false
            lastCheckError = "Güncelleme başarısız: \(error.localizedDescription)"
        }
    }

    // MARK: - Yardımcılar

    private func isNewerVersion(_ remote: String, than current: String) -> Bool {
        let rParts = remote.split(separator: ".").compactMap { Int($0) }
        let cParts = current.split(separator: ".").compactMap { Int($0) }
        let maxLen = max(rParts.count, cParts.count)
        for i in 0..<maxLen {
            let r = i < rParts.count ? rParts[i] : 0
            let c = i < cParts.count ? cParts[i] : 0
            if r > c { return true }
            if r < c { return false }
        }
        return false
    }

    private func relaunch(with appURL: URL) {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [appURL.path]
        try? task.run()
        NSApplication.shared.terminate(nil)
    }
}
