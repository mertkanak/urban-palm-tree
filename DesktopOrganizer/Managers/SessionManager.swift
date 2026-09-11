import AppKit
import Foundation

/// Pencere düzenlerini kaydeden, listeleyen ve geri yükleyen servis
@MainActor
public final class SessionManager: ObservableObject {
    public static let shared = SessionManager()

    @Published public private(set) var sessions: [WindowSession] = []

    private let udKey = "com.desktoporganizer.sessions"
    private let accessibilityManager = AccessibilityManager.shared

    public init() {
        loadSessions()
    }

    // MARK: - Persist

    private func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: udKey),
              let decoded = try? JSONDecoder().decode([WindowSession].self, from: data)
        else { return }
        sessions = decoded.sorted { $0.savedAt > $1.savedAt }
    }

    private func persistSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: udKey)
        }
    }

    // MARK: - Save

    /// Mevcut açık pencerelerin düzenini isimle kaydeder
    public func saveSession(name: String, windows: [WindowItem]) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let runningApps = NSWorkspace.shared.runningApplications
        let appMapByPID: [pid_t: NSRunningApplication] = Dictionary(
            uniqueKeysWithValues: runningApps.compactMap { app in
                (app.processIdentifier, app)
            }
        )

        let entries: [SessionEntry] = windows.map { item in
            let bundleID = appMapByPID[item.pid]?.bundleIdentifier ?? ""
            return SessionEntry(
                pid: item.pid,
                bundleIdentifier: bundleID,
                windowTitle: item.windowTitle,
                frame: item.bounds
            )
        }

        let session = WindowSession(name: trimmed, entries: entries)
        sessions.insert(session, at: 0)
        persistSessions()
    }

    // MARK: - Restore

    /// Kaydedilmiş pencere düzenini geri yükler
    public func restoreSession(_ session: WindowSession) {
        let runningApps = NSWorkspace.shared.runningApplications

        for entry in session.entries {
            // 1. Önce PID ile eşleştirmeye çalış
            if let app = runningApps.first(where: { $0.processIdentifier == entry.pid }) {
                accessibilityManager.setWindowFrame(
                    pid: app.processIdentifier,
                    title: entry.windowTitle.isEmpty ? nil : entry.windowTitle,
                    frame: entry.frame.cgRect
                )
                continue
            }
            // 2. PID uyuşmazsa bundleID ile eşleştir (uygulama yeniden başlatılmış olabilir)
            if !entry.bundleIdentifier.isEmpty,
               let app = runningApps.first(where: { $0.bundleIdentifier == entry.bundleIdentifier }) {
                accessibilityManager.setWindowFrame(
                    pid: app.processIdentifier,
                    title: entry.windowTitle.isEmpty ? nil : entry.windowTitle,
                    frame: entry.frame.cgRect
                )
            }
        }
    }

    // MARK: - Delete

    public func deleteSession(_ session: WindowSession) {
        sessions.removeAll { $0.id == session.id }
        persistSessions()
    }

    public func renameSession(_ session: WindowSession, to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let idx = sessions.firstIndex(where: { $0.id == session.id })
        else { return }
        sessions[idx].name = trimmed
        persistSessions()
    }
}
