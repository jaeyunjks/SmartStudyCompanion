import SwiftUI
import UIKit
import ImageIO

struct WorkspaceNoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.workspaceThemePalette) private var palette
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase

    let note: WorkspaceNote
    let onSave: (WorkspaceNote) -> Void
    let onDelete: ((WorkspaceNote) -> Void)?

    @StateObject private var richTextController = WorkspaceRichTextController()

    @State private var title: String
    @State private var blocks: [WorkspaceNoteBlock]
    @State private var activeBlockID: UUID?
    @State private var selectedImageBlockID: UUID?
    @State private var selectedTableBlockID: UUID?
    @State private var focusedTextBlockID: UUID?
    @State private var imageActionBlockID: UUID?
    @State private var tableActionBlockID: UUID?
    @State private var textBlockHeights: [UUID: CGFloat] = [:]

    @State private var textSize: Double
    @State private var textAlignment: WorkspaceNoteTextAlignment
    @FocusState private var isTitleFocused: Bool

    @State private var showFormatSheet = false
    @State private var showDeleteConfirmation = false
    @State private var autoSaveTask: Task<Void, Never>?
    @State private var hasLoaded = false
    @State private var isDeletingNote = false

    init(
        note: WorkspaceNote,
        onSave: @escaping (WorkspaceNote) -> Void,
        onDelete: ((WorkspaceNote) -> Void)? = nil
    ) {
        self.note = note
        self.onSave = onSave
        self.onDelete = onDelete

        _title = State(initialValue: note.displayTitle)
        _blocks = State(initialValue: note.blocks.isEmpty ? [WorkspaceNoteBlock.text(note.content)] : note.blocks)
        _textSize = State(initialValue: note.textSize)
        _textAlignment = State(initialValue: note.textAlignment)
    }

    private var resolvedTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Untitled Note" : trimmed
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                ScrollView {
                    mobileCanvas
                }
                .scrollDismissesKeyboard(.interactively)
                .contentShape(Rectangle())
                .onTapGesture {
                    if !isTitleFocused {
                        focusTrailingTextBlock()
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            contextualToolbar
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showFormatSheet) {
            formatSheet
                .presentationDetents([.medium])
        }
        .alert("Delete Note?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                isDeletingNote = true
                autoSaveTask?.cancel()
                onDelete?(note)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This note will be removed from this workspace.")
        }
        .confirmationDialog("Image Options", isPresented: Binding(
            get: { imageActionBlockID != nil },
            set: { if !$0 { imageActionBlockID = nil } }
        )) {
            Button("Small") { setImageSize(.small) }
            Button("Medium") { setImageSize(.medium) }
            Button("Full Width") { setImageSize(.full) }
            Button("Delete Image", role: .destructive) {
                guard let id = imageActionBlockID else { return }
                removeBlock(id)
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Table Options", isPresented: Binding(
            get: { tableActionBlockID != nil },
            set: { if !$0 { tableActionBlockID = nil } }
        )) {
            Button("Add Row") {
                guard let id = tableActionBlockID else { return }
                addTableRow(for: id)
            }
            Button("Add Column") {
                guard let id = tableActionBlockID else { return }
                addTableColumn(for: id)
            }
            Button("Delete Table", role: .destructive) {
                guard let id = tableActionBlockID else { return }
                removeBlock(id)
            }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            if let firstText = blocks.first(where: { $0.kind == .text }) {
                activeBlockID = firstText.id
                focusedTextBlockID = firstText.id
            }
            richTextController.currentFontSize = CGFloat(textSize)
            applyAlignmentToController(textAlignment)
            hasLoaded = true
        }
        .onChange(of: title) { _, _ in
            scheduleAutoSave()
        }
        .onChange(of: blocks) { _, _ in
            scheduleAutoSave()
        }
        .onChange(of: textSize) { _, _ in
            scheduleAutoSave()
        }
        .onChange(of: textAlignment) { _, _ in
            scheduleAutoSave()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active {
                autoSaveTask?.cancel()
                saveNoteSilently()
            }
        }
        .onDisappear {
            autoSaveTask?.cancel()
            if !isDeletingNote {
                saveNoteSilently()
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            Button {
                saveNoteSilently()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            TextField("Untitled Note", text: $title, axis: .vertical)
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(1...2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
                .focused($isTitleFocused)
                .onChange(of: isTitleFocused) { _, focused in
                    if focused {
                        focusedTextBlockID = nil
                        activeBlockID = nil
                    }
                }

            Menu {
                Button {
                    focusTitleForRename()
                } label: {
                    Label("Rename Note", systemImage: "pencil")
                }

                if onDelete != nil {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Note", systemImage: "trash")
                    }
                }

                Button {
                    insertChecklistBlock()
                } label: {
                    Label("Insert Checklist", systemImage: "checklist")
                }

                Button {
                    showFormatSheet = true
                } label: {
                    Label("Format", systemImage: "textformat")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(WorkspaceTheme.mutedText)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(uiColor: .systemBackground).opacity(0.94))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.06))
                .frame(height: 0.5)
        }
    }

    private var mobileCanvas: some View {
        LazyVStack(alignment: .leading, spacing: 4) {
            ForEach($blocks) { $block in
                blockView(block: $block)
            }

            Color.clear
                .frame(height: 80)
                .contentShape(Rectangle())
                .onTapGesture {
                    focusTrailingTextBlock()
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 26)
    }

    @ViewBuilder
    private func blockView(block: Binding<WorkspaceNoteBlock>) -> some View {
        switch block.wrappedValue.kind {
        case .text:
            textBlockView(block: block)
        case .image:
            imageBlockView(block: block)
        case .table:
            tableBlockView(block: block)
        case .checklist:
            checklistBlockView(block: block)
        }
    }

    private func textBlockView(block: Binding<WorkspaceNoteBlock>) -> some View {
        WorkspaceRichTextView(
            textDataBase64: Binding(
                get: { block.wrappedValue.textDataBase64 ?? "" },
                set: { block.wrappedValue.textDataBase64 = $0 }
            ),
            measuredHeight: Binding(
                get: { heightForTextBlock(block.wrappedValue.id) },
                set: { setHeight($0, forTextBlock: block.wrappedValue.id) }
            ),
            focusedBlockID: $focusedTextBlockID,
            blockID: block.wrappedValue.id,
            textSize: textSize,
            alignment: textAlignment,
            isActive: activeBlockID == block.wrappedValue.id,
            controller: richTextController,
            onTextChange: {
                activeBlockID = block.wrappedValue.id
                if block.wrappedValue.kind == .text {
                    var normalized = block.wrappedValue
                    let text = normalized.attributedText().string
                    if !text.isEmpty {
                        normalized.storeAttributedText(normalized.attributedText())
                        block.wrappedValue = normalized
                    }
                }
            },
            onFocus: {
                activeBlockID = block.wrappedValue.id
                isTitleFocused = false
            }
        )
        .frame(height: heightForTextBlock(block.wrappedValue.id))
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture {
            activeBlockID = block.wrappedValue.id
            focusedTextBlockID = block.wrappedValue.id
            selectedImageBlockID = nil
            selectedTableBlockID = nil
        }
    }

    private func imageBlockView(block: Binding<WorkspaceNoteBlock>) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let path = block.wrappedValue.imagePath {
                WorkspaceNoteImageView(
                    path: path,
                    maxWidth: imageWidth(for: block.wrappedValue.imageDisplaySize ?? .medium)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    selectedImageBlockID = block.wrappedValue.id
                    selectedTableBlockID = nil
                    activeBlockID = block.wrappedValue.id
                    imageActionBlockID = block.wrappedValue.id
                }
            }
        }
        .padding(.vertical, 1)
    }

    private func tableBlockView(block: Binding<WorkspaceNoteBlock>) -> some View {
        VStack(spacing: 6) {
            if let table = normalizedTable(block.wrappedValue.table) {
                let rowCount = table.cells.count
                let colCount = table.cells.first?.count ?? 0
                Grid(horizontalSpacing: 6, verticalSpacing: 6) {
                    ForEach(0..<rowCount, id: \.self) { row in
                        GridRow {
                            ForEach(0..<colCount, id: \.self) { col in
                                TextField(
                                    "",
                                    text: Binding(
                                        get: {
                                            guard let current = normalizedTable(block.wrappedValue.table),
                                                  row < current.cells.count,
                                                  col < current.cells[row].count else { return "" }
                                            return current.cells[row][col]
                                        },
                                        set: { newValue in
                                            guard var current = normalizedTable(block.wrappedValue.table),
                                                  row < current.cells.count,
                                                  col < current.cells[row].count else { return }
                                            current.cells[row][col] = newValue
                                            current.rows = current.cells.count
                                            current.columns = current.cells.first?.count ?? 0
                                            block.wrappedValue.table = current
                                        }
                                    )
                                )
                                .textFieldStyle(.roundedBorder)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 1)
        .onTapGesture {
            selectedTableBlockID = block.wrappedValue.id
            selectedImageBlockID = nil
            activeBlockID = block.wrappedValue.id
            tableActionBlockID = block.wrappedValue.id
        }
    }

    private func checklistBlockView(block: Binding<WorkspaceNoteBlock>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let items = block.wrappedValue.checklist?.items {
                ForEach(Array(items.enumerated()), id: \.offset) { index, _ in
                    HStack(spacing: 8) {
                        Button {
                            guard block.wrappedValue.checklist?.items.indices.contains(index) == true else { return }
                            block.wrappedValue.checklist?.items[index].isChecked.toggle()
                        } label: {
                            Image(systemName: (block.wrappedValue.checklist?.items.indices.contains(index) == true && (block.wrappedValue.checklist?.items[index].isChecked == true)) ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 18))
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)

                        TextField(
                            "List item",
                            text: Binding(
                                get: {
                                    guard block.wrappedValue.checklist?.items.indices.contains(index) == true else { return "" }
                                    return block.wrappedValue.checklist?.items[index].text ?? ""
                                },
                                set: {
                                    guard block.wrappedValue.checklist?.items.indices.contains(index) == true else { return }
                                    block.wrappedValue.checklist?.items[index].text = $0
                                }
                            )
                        )
                        .font(.body)
                        .onSubmit {
                            if index == (block.wrappedValue.checklist?.items.count ?? 1) - 1 {
                                block.wrappedValue.checklist?.items.append(WorkspaceChecklistItem(text: ""))
                            }
                        }
                    }
                }
            }

            HStack {
                Button("Add item") {
                    block.wrappedValue.checklist?.items.append(WorkspaceChecklistItem(text: ""))
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .buttonStyle(.plain)

                Spacer()

                Button("Remove checklist") {
                    removeBlock(block.wrappedValue.id)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.red)
                .buttonStyle(.plain)
            }
            .padding(.leading, 26)
            .padding(.top, 2)
        }
        .padding(.vertical, 1)
    }

    private var contextualToolbar: some View {
        Group {
            if richTextController.selectedRange.length > 0, richTextController.isEditing, !isTitleFocused {
                HStack(spacing: 10) {
                    toolbarIcon("bold", isActive: richTextController.isBold) { richTextController.toggleBold() }
                    toolbarIcon("italic", isActive: richTextController.isItalic) { richTextController.toggleItalic() }
                    toolbarIcon("underline", isActive: richTextController.isUnderline) { richTextController.toggleUnderline() }
                    toolbarIcon("list.bullet", isActive: false) { richTextController.applyListStyle(.bullet) }
                    toolbarIcon("list.number", isActive: false) { richTextController.applyListStyle(.numbered) }
                    toolbarIcon("checklist", isActive: false) { insertChecklistBlock() }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Color.clear.frame(height: 0)
            }
        }
    }

    private var formatSheet: some View {
        NavigationStack {
            Form {
                Section("Text Style") {
                    styleToggleButton(title: "Bold", isActive: richTextController.isBold) {
                        richTextController.toggleBold()
                    }
                    styleToggleButton(title: "Italic", isActive: richTextController.isItalic) {
                        richTextController.toggleItalic()
                    }
                    styleToggleButton(title: "Underline", isActive: richTextController.isUnderline) {
                        richTextController.toggleUnderline()
                    }
                }

                Section("Text Type") {
                    Button("Heading") {
                        textSize = 24
                        richTextController.setFontSize(24)
                    }
                    Button("Body") {
                        textSize = 18
                        richTextController.setFontSize(18)
                    }
                }

                Section("Alignment") {
                    Picker("Alignment", selection: $textAlignment) {
                        Text("Left").tag(WorkspaceNoteTextAlignment.left)
                        Text("Center").tag(WorkspaceNoteTextAlignment.center)
                        Text("Right").tag(WorkspaceNoteTextAlignment.right)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: textAlignment) { _, newValue in
                        applyAlignmentToController(newValue)
                    }
                }

                Section("Lists") {
                    Button("Normal paragraph") {
                        richTextController.applyListStyle(.paragraph)
                    }
                    Button("Bullet list") {
                        richTextController.applyListStyle(.bullet)
                    }
                    Button("Numbered list") {
                        richTextController.applyListStyle(.numbered)
                    }
                    Button("Checklist") {
                        insertChecklistBlock()
                    }
                }
            }
            .navigationTitle("Format")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showFormatSheet = false }
                }
            }
        }
    }

    private func toolbarIcon(_ icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isActive ? .white : .primary)
                .frame(width: 32, height: 32)
                .background(isActive ? palette.primary : Color.clear)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private func styleToggleButton(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isActive {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    private func applyAlignmentToController(_ alignment: WorkspaceNoteTextAlignment) {
        switch alignment {
        case .left:
            richTextController.setAlignment(.left)
        case .center:
            richTextController.setAlignment(.center)
        case .right:
            richTextController.setAlignment(.right)
        }
    }

    private func insertChecklistBlock() {
        insertInlineBlockAtCursor(.checklist())
    }

    private func insertInlineBlockAtCursor(_ block: WorkspaceNoteBlock) {
        var trailingTextToFocusID: UUID?
        if let activeID = activeBlockID,
           let index = blocks.firstIndex(where: { $0.id == activeID }) {
            if blocks[index].kind == .text {
                let attributed = blocks[index].attributedText()
                let (start, end) = clampedSelectionRange(
                    richTextController.selectedRange,
                    in: attributed.length
                )

                var replacements: [WorkspaceNoteBlock] = []
                if start > 0 {
                    let before = attributed.attributedSubstring(from: NSRange(location: 0, length: start))
                    var beforeBlock = WorkspaceNoteBlock.text()
                    beforeBlock.storeAttributedText(before)
                    replacements.append(beforeBlock)
                }

                replacements.append(block)

                if end < attributed.length {
                    let after = attributed.attributedSubstring(from: NSRange(location: end, length: attributed.length - end))
                    var afterBlock = WorkspaceNoteBlock.text()
                    afterBlock.storeAttributedText(after)
                    trailingTextToFocusID = afterBlock.id
                    replacements.append(afterBlock)
                } else {
                    let trailing = WorkspaceNoteBlock.text()
                    trailingTextToFocusID = trailing.id
                    replacements.append(trailing)
                }

                blocks.replaceSubrange(index...index, with: replacements)
            } else {
                blocks.insert(block, at: index + 1)
                let trailing = WorkspaceNoteBlock.text()
                blocks.insert(trailing, at: index + 2)
                trailingTextToFocusID = trailing.id
            }
        } else {
            blocks.append(block)
            let trailing = WorkspaceNoteBlock.text()
            blocks.append(trailing)
            trailingTextToFocusID = trailing.id
        }
        if let trailingTextToFocusID {
            activeBlockID = trailingTextToFocusID
            focusedTextBlockID = trailingTextToFocusID
        } else {
            activeBlockID = block.id
        }
        selectedImageBlockID = nil
        selectedTableBlockID = nil
    }

    private func removeBlock(_ id: UUID) {
        if let block = blocks.first(where: { $0.id == id }),
           block.kind == .image,
           let path = block.imagePath {
            let isUsedElsewhere = blocks.contains { candidate in
                candidate.id != id && candidate.kind == .image && candidate.imagePath == path
            }
            if !isUsedElsewhere {
                WorkspaceNoteStorageService.shared.deleteNoteImageIfExists(path: path)
                WorkspaceNoteImageCache.shared.remove(path: path)
            }
        }

        blocks.removeAll { $0.id == id }
        if blocks.isEmpty {
            let fallback = WorkspaceNoteBlock.text()
            blocks = [fallback]
            activeBlockID = fallback.id
        }
        if selectedImageBlockID == id { selectedImageBlockID = nil }
        if selectedTableBlockID == id { selectedTableBlockID = nil }
    }

    private func imageWidth(for size: WorkspaceImageDisplaySize) -> CGFloat? {
        switch size {
        case .small:
            return 180
        case .medium:
            return 280
        case .full:
            return nil
        }
    }

    private func setImageSize(_ size: WorkspaceImageDisplaySize) {
        guard let id = imageActionBlockID,
              let index = blocks.firstIndex(where: { $0.id == id }) else { return }
        blocks[index].imageDisplaySize = size
    }

    private func addTableRow(for id: UUID) {
        guard let index = blocks.firstIndex(where: { $0.id == id }),
              var table = normalizedTable(blocks[index].table) else { return }
        let columnCount = max(1, table.cells.first?.count ?? table.columns)
        table.cells.append(Array(repeating: "", count: columnCount))
        table.rows = table.cells.count
        table.columns = columnCount
        blocks[index].table = table
    }

    private func addTableColumn(for id: UUID) {
        guard let index = blocks.firstIndex(where: { $0.id == id }),
              var table = normalizedTable(blocks[index].table) else { return }
        table.cells = table.cells.map { row in
            var updated = row
            updated.append("")
            return updated
        }
        table.rows = table.cells.count
        table.columns = table.cells.first?.count ?? max(1, table.columns + 1)
        blocks[index].table = table
    }

    private func focusTrailingTextBlock() {
        if let lastTextIndex = blocks.lastIndex(where: { $0.kind == .text }) {
            activeBlockID = blocks[lastTextIndex].id
            focusedTextBlockID = blocks[lastTextIndex].id
            selectedImageBlockID = nil
            selectedTableBlockID = nil
            return
        }

        let trailing = WorkspaceNoteBlock.text()
        blocks.append(trailing)
        activeBlockID = trailing.id
        focusedTextBlockID = trailing.id
        selectedImageBlockID = nil
        selectedTableBlockID = nil
    }

    private func focusTitleForRename() {
        activeBlockID = nil
        focusedTextBlockID = nil
        richTextController.textView?.resignFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            isTitleFocused = true
        }
    }

    private func heightForTextBlock(_ id: UUID) -> CGFloat {
        textBlockHeights[id] ?? 56
    }

    private func setHeight(_ height: CGFloat, forTextBlock id: UUID) {
        let normalized = max(56, height)
        guard textBlockHeights[id] != normalized else { return }
        var next = textBlockHeights
        next[id] = normalized
        textBlockHeights = next
    }

    private func normalizedTable(_ table: WorkspaceTableBlock?) -> WorkspaceTableBlock? {
        guard var table else { return nil }
        let expectedRows = max(1, table.rows)
        let expectedColumns = max(1, table.columns)

        if table.cells.isEmpty {
            table.cells = Array(repeating: Array(repeating: "", count: expectedColumns), count: expectedRows)
        }

        table.cells = table.cells.map { row in
            if row.count >= expectedColumns { return Array(row.prefix(expectedColumns)) }
            return row + Array(repeating: "", count: expectedColumns - row.count)
        }

        if table.cells.count < expectedRows {
            table.cells.append(contentsOf: Array(
                repeating: Array(repeating: "", count: expectedColumns),
                count: expectedRows - table.cells.count
            ))
        } else if table.cells.count > expectedRows {
            table.cells = Array(table.cells.prefix(expectedRows))
        }

        table.rows = table.cells.count
        table.columns = table.cells.first?.count ?? expectedColumns
        return table
    }

    private func clampedSelectionRange(_ selection: NSRange, in textLength: Int) -> (Int, Int) {
        guard textLength > 0 else { return (0, 0) }

        // NSNotFound / invalid selection can appear when editor focus changes.
        let rawLocation = selection.location == NSNotFound ? textLength : selection.location
        let start = max(0, min(rawLocation, textLength))

        // Prevent overflow from `location + length` on invalid ranges.
        let safeLength: Int
        if selection.length == NSNotFound {
            safeLength = 0
        } else {
            safeLength = max(0, selection.length)
        }

        let maxTail = max(0, textLength - start)
        let clampedLength = min(safeLength, maxTail)
        let end = start + clampedLength
        return (start, end)
    }

    private func buildUpdatedNote() -> WorkspaceNote {
        let plain = blocks.map { $0.plainTextSummary }
            .joined(separator: "\n\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        var updated = note
        updated.title = resolvedTitle
        updated.blocks = blocks
        updated.content = plain
        updated.textSize = textSize
        updated.textAlignment = textAlignment
        updated.isBoldEnabled = richTextController.isBold
        updated.updatedAt = Date()
        return updated
    }

    private func scheduleAutoSave() {
        guard hasLoaded, !isDeletingNote else { return }
        autoSaveTask?.cancel()
        autoSaveTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 450_000_000)
            guard !Task.isCancelled, !isDeletingNote else { return }
            saveNoteSilently()
        }
    }

    private func saveNoteSilently() {
        guard !isDeletingNote else { return }
        onSave(buildUpdatedNote())
    }

}

#Preview {
    WorkspaceNoteEditorView(note: WorkspaceNote(workspaceID: UUID()), onSave: { _ in }, onDelete: { _ in })
}

private struct WorkspaceNoteImageView: View {
    let path: String
    let maxWidth: CGFloat?

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.secondary.opacity(0.12))
                    .overlay {
                        ProgressView()
                    }
                    .frame(height: 140)
            }
        }
        .frame(maxWidth: maxWidth, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .task(id: path) {
            image = await WorkspaceNoteImageCache.shared.image(for: path, maxPixelSize: 1600)
        }
    }
}

private final class WorkspaceNoteImageCache {
    static let shared = WorkspaceNoteImageCache()

    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 40
        cache.totalCostLimit = 64 * 1024 * 1024
    }

    func image(for path: String, maxPixelSize: CGFloat) async -> UIImage? {
        if let cached = cache.object(forKey: path as NSString) {
            return cached
        }

        return await Task.detached(priority: .utility) { [cache] in
            guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil) else {
                return nil
            }
            let options: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceShouldCache: false,
                kCGImageSourceThumbnailMaxPixelSize: Int(maxPixelSize)
            ]
            guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
                return nil
            }
            let decoded = UIImage(cgImage: cgImage)
            let bytesPerRow = cgImage.bytesPerRow
            let cost = max(1, bytesPerRow * cgImage.height)
            cache.setObject(decoded, forKey: path as NSString, cost: cost)
            return decoded
        }.value
    }

    func remove(path: String) {
        cache.removeObject(forKey: path as NSString)
    }
}
