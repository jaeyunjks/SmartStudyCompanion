import SwiftUI
import PhotosUI
import UIKit

private enum NoteWritingMode: String, CaseIterable, Identifiable {
    case mobile = "Mobile View"
    case paper = "Paper View"

    var id: String { rawValue }
}

struct WorkspaceNoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.workspaceThemePalette) private var palette

    let note: WorkspaceNote
    let onSave: (WorkspaceNote) -> Void
    let onDelete: ((WorkspaceNote) -> Void)?

    @State private var title: String
    @State private var content: String
    @State private var isBoldEnabled: Bool
    @State private var textSize: Double
    @State private var textAlignment: WorkspaceNoteTextAlignment
    @State private var bulletListEnabled: Bool
    @State private var numberedListEnabled: Bool
    @State private var imagePaths: [String]
    @State private var mode: NoteWritingMode = .mobile

    @State private var isEditingTitle = false
    @State private var showParagraphSheet = false
    @State private var showDeleteConfirmation = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showPhotoPicker = false
    @State private var importError: String?

    init(
        note: WorkspaceNote,
        onSave: @escaping (WorkspaceNote) -> Void,
        onDelete: ((WorkspaceNote) -> Void)? = nil
    ) {
        self.note = note
        self.onSave = onSave
        self.onDelete = onDelete
        _title = State(initialValue: note.displayTitle)
        _content = State(initialValue: note.content)
        _isBoldEnabled = State(initialValue: note.isBoldEnabled)
        _textSize = State(initialValue: note.textSize)
        _textAlignment = State(initialValue: note.textAlignment)
        _bulletListEnabled = State(initialValue: note.bulletListEnabled)
        _numberedListEnabled = State(initialValue: note.numberedListEnabled)
        _imagePaths = State(initialValue: note.imagePaths)
    }

    private var wordCount: Int {
        content.split { $0.isWhitespace || $0.isNewline }.count
    }

    private var resolvedTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Untitled Note" : trimmed
    }

    private var textAlignmentValue: TextAlignment {
        switch textAlignment {
        case .left:
            return .leading
        case .center:
            return .center
        case .right:
            return .trailing
        }
    }

    var body: some View {
        ZStack {
            WorkspaceTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                modePicker

                Group {
                    if mode == .mobile {
                        editorSurface
                    } else {
                        ScrollView {
                            HStack {
                                Spacer(minLength: 0)
                                editorSurface
                                    .frame(maxWidth: 620)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                toolbar
                footer
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhotoItem,
            matching: .images,
            preferredItemEncoding: .automatic
        )
        .onChange(of: selectedPhotoItem) { _, item in
            guard let item else { return }
            Task {
                do {
                    guard let data = try await item.loadTransferable(type: Data.self) else {
                        importError = "Could not load selected image."
                        return
                    }
                    let path = try WorkspaceNoteStorageService.shared.persistNoteImage(
                        data: data,
                        workspaceID: note.workspaceID,
                        noteID: note.id
                    )
                    imagePaths.append(path)
                } catch {
                    importError = "Image import failed. Please try again."
                }
            }
        }
        .sheet(isPresented: $showParagraphSheet) {
            paragraphSettingsSheet
                .presentationDetents([.medium])
        }
        .alert("Delete Note?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                onDelete?(note)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This note will be removed from this workspace.")
        }
        .alert("Import Error", isPresented: Binding(
            get: { importError != nil },
            set: { if !$0 { importError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importError ?? "")
        }
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(palette.primaryStrong)
                    .frame(width: 36, height: 36)
                    .background(WorkspaceTheme.secondaryBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: 8)

            Group {
                if isEditingTitle {
                    TextField("Untitled Note", text: $title)
                        .font(.headline.weight(.bold))
                        .multilineTextAlignment(.center)
                        .submitLabel(.done)
                        .onSubmit { isEditingTitle = false }
                } else {
                    Button {
                        isEditingTitle = true
                    } label: {
                        Text(resolvedTitle)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: 220)

            Spacer(minLength: 8)

            if onDelete != nil {
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.red)
                        .frame(width: 36, height: 36)
                        .background(WorkspaceTheme.secondaryBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            Button {
                saveNoteAndDismiss()
            } label: {
                Text("Save")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(palette.primaryStrong)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private var modePicker: some View {
        Picker("Writing mode", selection: $mode) {
            ForEach(NoteWritingMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var editorSurface: some View {
        VStack(spacing: 12) {
            ZStack(alignment: alignmentForPlaceholder) {
                if content.isEmpty {
                    Text("Start writing your notes...")
                        .font(.system(size: textSize, weight: .regular, design: .rounded))
                        .foregroundStyle(WorkspaceTheme.mutedText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                }

                TextEditor(text: $content)
                    .scrollContentBackground(.hidden)
                    .font(.system(size: textSize, weight: isBoldEnabled ? .semibold : .regular, design: .rounded))
                    .multilineTextAlignment(textAlignmentValue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
            .frame(minHeight: mode == .paper ? 420 : 280)

            if !imagePaths.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(imagePaths, id: \.self) { path in
                            imagePreview(path: path)
                        }
                    }
                    .padding(.horizontal, 2)
                }
                .frame(height: 92)
            }
        }
        .padding(14)
        .background(mode == .paper ? Color(.systemBackground) : WorkspaceTheme.surfaceSecondary(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.primary.opacity(mode == .paper ? 0.16 : 0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(mode == .paper ? 0.12 : 0.05), radius: mode == .paper ? 16 : 8, x: 0, y: mode == .paper ? 8 : 4)
        .padding(.horizontal, mode == .paper ? 0 : 16)
        .padding(.top, 2)
    }

    private var toolbar: some View {
        HStack(spacing: 14) {
            toolbarIcon("bold", isActive: isBoldEnabled) {
                isBoldEnabled.toggle()
            }
            toolbarIcon("photo", isActive: false) {
                showPhotoPicker = true
            }
            toolbarIcon("tablecells", isActive: false) {
                insertTablePlaceholder()
            }
            toolbarIcon("paragraph", isActive: bulletListEnabled || numberedListEnabled) {
                showParagraphSheet = true
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .padding(.top, 10)
    }

    private var footer: some View {
        HStack {
            Text("\(wordCount) words")
            Spacer()
            Text(note.createdDisplayText)
        }
        .font(.caption)
        .foregroundStyle(WorkspaceTheme.mutedText)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var paragraphSettingsSheet: some View {
        NavigationStack {
            Form {
                Section("Text Size") {
                    Stepper(value: $textSize, in: 14...28, step: 1) {
                        Text("\(Int(textSize)) pt")
                    }
                }

                Section("Alignment") {
                    Picker("Alignment", selection: $textAlignment) {
                        Text("Left").tag(WorkspaceNoteTextAlignment.left)
                        Text("Center").tag(WorkspaceNoteTextAlignment.center)
                        Text("Right").tag(WorkspaceNoteTextAlignment.right)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Lists") {
                    Toggle("Bullet list", isOn: Binding(
                        get: { bulletListEnabled },
                        set: { newValue in
                            bulletListEnabled = newValue
                            if newValue {
                                numberedListEnabled = false
                                insertListPrefixIfNeeded(prefix: "• ")
                            }
                        }
                    ))
                    Toggle("Numbered list", isOn: Binding(
                        get: { numberedListEnabled },
                        set: { newValue in
                            numberedListEnabled = newValue
                            if newValue {
                                bulletListEnabled = false
                                insertListPrefixIfNeeded(prefix: "1. ")
                            }
                        }
                    ))
                }
            }
            .navigationTitle("Paragraph")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showParagraphSheet = false
                    }
                }
            }
        }
    }

    private func imagePreview(path: String) -> some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let image = UIImage(contentsOfFile: path) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(WorkspaceTheme.secondaryBackground)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundStyle(WorkspaceTheme.mutedText)
                        )
                }
            }
            .frame(width: 84, height: 84)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Button {
                imagePaths.removeAll { $0 == path }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.white, Color.black.opacity(0.7))
            }
            .offset(x: 4, y: -4)
        }
    }

    private func toolbarIcon(_ systemName: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isActive ? .white : palette.primaryStrong)
                .frame(width: 30, height: 30)
                .background(isActive ? palette.primaryStrong : palette.iconBackground)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var alignmentForPlaceholder: Alignment {
        switch textAlignment {
        case .left:
            return .topLeading
        case .center:
            return .top
        case .right:
            return .topTrailing
        }
    }

    private func insertTablePlaceholder() {
        let table = "\n\n| Column 1 | Column 2 |\n|---|---|\n| Value | Value |\n"
        content.append(table)
    }

    private func insertListPrefixIfNeeded(prefix: String) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            content = prefix
        }
    }

    private func saveNoteAndDismiss() {
        var updated = note
        updated.title = resolvedTitle
        updated.content = content
        updated.isBoldEnabled = isBoldEnabled
        updated.textSize = textSize
        updated.textAlignment = textAlignment
        updated.bulletListEnabled = bulletListEnabled
        updated.numberedListEnabled = numberedListEnabled
        updated.imagePaths = imagePaths
        updated.updatedAt = Date()
        onSave(updated)
        dismiss()
    }
}

#Preview {
    WorkspaceNoteEditorView(note: WorkspaceNote(workspaceID: UUID()), onSave: { _ in }, onDelete: { _ in })
}
