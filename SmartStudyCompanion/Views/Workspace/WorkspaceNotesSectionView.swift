import SwiftUI

struct WorkspaceNotesSectionView: View {
    let notes: [WorkspaceNote]
    let onCreateNote: () -> Void
    let onSelectNote: (WorkspaceNote) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Notes")
                    .font(.title3.weight(.bold))
                Spacer()
                Text("\(notes.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(WorkspaceTheme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(WorkspaceTheme.accentSoft)
                    .clipShape(Capsule())
            }

            if notes.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("No notes yet")
                        .font(.headline.weight(.semibold))
                    Text("Capture your first idea, summary, or quick study insight.")
                        .font(.subheadline)
                        .foregroundStyle(WorkspaceTheme.mutedText)

                    Button("Create your first note") {
                        onCreateNote()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(WorkspaceTheme.accent)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(WorkspaceTheme.secondaryBackground.opacity(0.72))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                VStack(spacing: 8) {
                    ForEach(notes.prefix(3)) { note in
                        Button {
                            onSelectNote(note)
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(note.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text(note.updatedAt, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(WorkspaceTheme.mutedText)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(WorkspaceTheme.secondaryBackground.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous)
                .stroke(WorkspaceTheme.accent.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    WorkspaceNotesSectionView(notes: [], onCreateNote: {}, onSelectNote: { _ in })
        .padding()
}
