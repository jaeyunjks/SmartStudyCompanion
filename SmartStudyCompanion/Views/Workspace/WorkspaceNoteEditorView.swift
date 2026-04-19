import SwiftUI

struct WorkspaceNoteEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let note: WorkspaceNote
    let onSave: (WorkspaceNote) -> Void

    @State private var content: String
    @State private var lastSavedAt: Date?

    init(note: WorkspaceNote, onSave: @escaping (WorkspaceNote) -> Void) {
        self.note = note
        self.onSave = onSave
        _content = State(initialValue: note.content)
    }

    private var wordCount: Int {
        content.split { $0.isWhitespace || $0.isNewline }.count
    }

    private var statusText: String {
        if let lastSavedAt {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            return "Saved " + formatter.localizedString(for: lastSavedAt, relativeTo: Date())
        }
        return "Not saved"
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    WorkspaceTheme.background,
                    WorkspaceTheme.mintTint.opacity(0.32)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(WorkspaceTheme.accentSoft.opacity(0.45))
                .frame(width: 220, height: 220)
                .blur(radius: 58)
                .offset(x: 140, y: -220)

            VStack(spacing: 0) {
                topBar

                ZStack(alignment: .topLeading) {
                    if content.isEmpty {
                        Text("Start writing your notes...")
                            .foregroundStyle(WorkspaceTheme.mutedText.opacity(0.7))
                            .padding(.horizontal, 22)
                            .padding(.vertical, 18)
                    }

                    TextEditor(text: $content)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 84)
            }

            VStack {
                Spacer()
                toolbar
                footer
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WorkspaceTheme.accent)
                    .frame(width: 36, height: 36)
                    .background(WorkspaceTheme.secondaryBackground.opacity(0.9))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text("New Note")
                .font(.headline.weight(.bold))
                .foregroundStyle(WorkspaceTheme.deepAccent)

            Spacer()

            Button {
                var updated = note
                updated.content = content
                onSave(updated)
                lastSavedAt = Date()
                dismiss()
            } label: {
                Text("Save")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(WorkspaceTheme.accent)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial.opacity(0.85))
    }

    private var toolbar: some View {
        HStack(spacing: 14) {
            toolbarIcon("paperclip")
            toolbarIcon("bold")
            toolbarIcon("photo")
            toolbarIcon("checklist")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(WorkspaceTheme.accent.opacity(0.12), lineWidth: 1)
        )
        .padding(.bottom, 10)
    }

    private var footer: some View {
        HStack {
            Text("\(wordCount) words")
            Spacer()
            Text(statusText)
        }
        .font(.caption)
        .foregroundStyle(WorkspaceTheme.mutedText)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    private func toolbarIcon(_ systemName: String) -> some View {
        Button(action: {}) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(WorkspaceTheme.accent)
                .frame(width: 30, height: 30)
                .background(WorkspaceTheme.accentSoft.opacity(0.9))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WorkspaceNoteEditorView(note: WorkspaceNote(workspaceID: UUID()), onSave: { _ in })
}
