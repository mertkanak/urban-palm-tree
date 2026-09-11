import SwiftUI

/// Kaydedilmiş pencere düzenlerini yöneten, kaydeden ve geri yükleyen görünüm
public struct SessionManagerView: View {
    @ObservedObject var sessionManager: SessionManager = .shared
    @ObservedObject var windowManager: WindowManager = .shared

    @State private var newSessionName: String = ""
    @State private var showingSaveField: Bool = false
    @State private var restoringSessionID: UUID? = nil
    @State private var editingSession: WindowSession? = nil
    @State private var editName: String = ""

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            // MARK: Üst Başlık
            headerView

            Divider().opacity(0.3)

            if sessionManager.sessions.isEmpty {
                emptyState
            } else {
                sessionList
            }
        }
        .frame(width: 420)
        .background(
            VisualEffectBackground(material: .hudWindow, blendingMode: .behindWindow)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 10) {
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(LinearGradient(
                                colors: [.purple, .indigo],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 28, height: 28)
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text("Kaydedilmiş Düzenler")
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
                            newSessionName = "Düzen \(fmt.string(from: Date()))"
                        }
                    }
                }) {
                    Label(showingSaveField ? "İptal" : "Düzeni Kaydet",
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

                    TextField("Düzen adı...", text: $newSessionName)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13))
                        .onSubmit { saveCurrentSession() }

                    Button(action: saveCurrentSession) {
                        Text("Kaydet")
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
            Text("Henüz kayıtlı düzen yok")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
            Text("\"Düzeni Kaydet\" ile mevcut pencere\nkonumlarını isimle kaydedebilirsiniz.")
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
                    .help("Yeniden Adlandır")

                    // Sil
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red.opacity(0.8))
                    .help("Düzeni Sil")
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
                        Label("Yükle", systemImage: "arrow.counterclockwise")
                            .font(.system(size: 11, weight: .semibold))
                    }
                }
                .frame(width: 68, height: 22)
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
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Düzeni Yeniden Adlandır")
                .font(.system(size: 14, weight: .bold))

            TextField("Düzen adı", text: $currentName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 280)
                .onSubmit { save() }

            HStack(spacing: 10) {
                Button("İptal") { dismiss() }
                    .buttonStyle(.bordered)
                Button("Kaydet") { save() }
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
