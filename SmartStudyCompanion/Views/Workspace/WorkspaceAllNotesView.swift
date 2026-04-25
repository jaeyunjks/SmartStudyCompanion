import SwiftUI

struct WorkspaceAllNotesView: View {
    @Environment(\.dismiss) private var dismiss
    let notes: [WorkspaceNote]
    let onOpen: (WorkspaceNote) -> Void
    let onDelete: (WorkspaceNote) -> Void

    @State private var searchText = ""

    private var filteredNotes: [WorkspaceNote] {
        let sorted = notes.sorted { $0.updatedAt > $1.updatedAt }
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return sorted
        }
        return sorted.filter {
            $0.displayTitle.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredNotes.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "note.text")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(WorkspaceTheme.mutedText)
                        Text("No notes found")
                            .font(.headline)
                        Text("Try a different search or create a new note.")
                            .font(.footnote)
                            .foregroundStyle(WorkspaceTheme.mutedText)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List {
                        ForEach(filteredNotes) { note in
                            Button {
                                onOpen(note)
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(note.displayTitle)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                    Text(note.createdDisplayText)
                                        .font(.caption)
                                        .foregroundStyle(WorkspaceTheme.mutedText)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    onDelete(note)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("All Notes")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search notes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    WorkspaceAllNotesView(
        notes: [WorkspaceNote(workspaceID: UUID(), title: "Demo", content: "Hello")],
        onOpen: { _ in },
        onDelete: { _ in }
    )
}
