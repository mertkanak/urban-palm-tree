import SwiftUI

/// Kaydedilmiş pencere düzenlerini yöneten, kaydeden ve geri yükleyen görünüm
public struct SessionManagerView: View {
    @ObservedObject var sessionManager: SessionManager = .shared
    @ObservedObject var windowManager: WindowManager = .shared
    @ObservedObject var l10n: LocalizationManager = .shared

    @State private var showingSaveField: Bool = false
    @State private var newSessionName: String = ""
    @State private var restoringSessionID: UUID? = nil
    @State private var editingSession: WindowSession? = nil
    @State private var editName: String = ""

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
                .opacity(0.3)

            if sessionManager.sessions.isEmpty {
                emptyState
            } else {
                sessionList
            }
        }
        .frame(width: 440)
        .background(VisualEffectBackground(material: .popover, blendingMode: .behindWindow))
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 10) {
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 26, height: 26)
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text(L10n.sessionsTitle)
                        .font(.system(size: 14, weight: .bold))
                }
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        showingSaveField.toggle()
                        if showingSaveField {
                            // Otomatik isim öner
                            let fmt = DateFormatter()
                            fmt.dateFormat = "dd.MM HH:mm"
                            let prefix = L10n.layoutDefaultPrefix
                            newSessionName = "\(prefix) \(fmt.string(from: Date()))"
                        }
                    }
                }) {
                    Label(showingSaveField ? L10n.cancel : L10n.saveCurrentSession,
                          systemImage: showingSaveField ? "xmark" : "plus.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(showingSaveField ? .secondary : .purple)
                .controlSize(.small)
            }

            // Kaydetme Alanı
            if showingSaveField {
                HStack(spacing: 8) {
                    Image(systemName: "bookmark")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))

                    TextField(L10n.sessionNamePlaceholder, text: $newSessionName)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13))
                        .onSubmit { saveCurrentSession() }

                    Button(action: saveCurrentSession) {
                        Text(L10n.save)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                    .controlSize(.small)
                    .disabled(newSessionName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(Color.purple.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .strokeBorder(Color.purple.opacity(0.3), lineWidth: 1)
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(14)
        .animation(.spring(response: 0.3), value: showingSaveField)
    }

    // MARK: - Session List

    private var sessionList: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 8) {
                ForEach(sessionManager.sessions) { session in
                    SessionRowView(
                        session: session,
                        isRestoring: restoringSessionID == session.id,
                        onRestore: {
                            restoreWithFeedback(session)
                        },
                        onDelete: {
                            withAnimation(.spring()) {
                                sessionManager.deleteSession(session)
                            }
                        },
                        onRename: {
                            editingSession = session
                            editName = session.name
                        }
                    )
                }
            }
            .padding(12)
        }
        .frame(maxHeight: 380)
        // Düzenleme sheet'i
        .sheet(item: $editingSession) { session in
            RenameSessionSheet(session: session, currentName: $editName) { newName in
                sessionManager.renameSession(session, to: newName)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.5))
            Text(L10n.noSessionsYet)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
            Text(L10n.sessionsEmptyDescription)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }

    // MARK: - Actions

    private func saveCurrentSession() {
        let name = newSessionName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        sessionManager.saveSession(name: name, windows: windowManager.windows)
        withAnimation(.spring(response: 0.3)) {
            showingSaveField = false
            newSessionName = ""
        }
    }

    private func restoreWithFeedback(_ session: WindowSession) {
        restoringSessionID = session.id
        sessionManager.restoreSession(session)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { restoringSessionID = nil }
        }
    }
}

// MARK: - Session Row

private struct SessionRowView: View {
    let session: WindowSession
    let isRestoring: Bool
    let onRestore: () -> Void
    let onDelete: () -> Void
    let onRename: () -> Void

    @ObservedObject var l10n: LocalizationManager = .shared
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            // Sol renk çubuğu
            RoundedRectangle(cornerRadius: 3)
                .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .top, endPoint: .bottom))
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 3) {
                Text(session.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(session.summary)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isHovered || isRestoring {
                HStack(spacing: 6) {
                    // Yeniden adlandır
                    Button(action: onRename) {
                        Image(systemName: "pencil")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    .help(L10n.rename)

                    // Sil
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red.opacity(0.8))
                    .help(L10n.deleteSession)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.85)))
            }

            // Geri yükle butonu
            Button(action: onRestore) {
                Group {
                    if isRestoring {
                        ProgressView()
                            .controlSize(.small)
                            .scaleEffect(0.7)
                    } else {
                        Label(L10n.restoreSession, systemImage: "arrow.counterclockwise")
                            .font(.system(size: 11, weight: .semibold))
                    }
                }
                .frame(width: l10n.currentLanguage == .turkish ? 76 : 94, height: 22)
            }
            .buttonStyle(.borderedProminent)
            .tint(isRestoring ? .gray : .purple)
            .controlSize(.small)
            .disabled(isRestoring)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isHovered ? Color.purple.opacity(0.08) : Color(nsColor: .controlBackgroundColor).opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(isHovered ? Color.purple.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1)
        )
        .animation(.spring(response: 0.22, dampingFraction: 0.78), value: isHovered)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Rename Sheet

private struct RenameSessionSheet: View {
    let session: WindowSession
    @Binding var currentName: String
    let onSave: (String) -> Void
    @ObservedObject var l10n: LocalizationManager = .shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text(L10n.renameLayoutTitle)
                .font(.system(size: 14, weight: .bold))

            TextField(L10n.layoutNamePlaceholder, text: $currentName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 280)
                .onSubmit { save() }

            HStack(spacing: 10) {
                Button(L10n.cancel) { dismiss() }
                    .buttonStyle(.bordered)
                Button(L10n.save) { save() }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                    .disabled(currentName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 340)
    }

    private func save() {
        onSave(currentName)
        dismiss()
    }
}
