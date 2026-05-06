import SwiftUI

struct SummaryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @StateObject private var viewModel: SummaryDetailViewModel
    @State private var showFallbackShareSheet = false
    @State private var showSourcePicker = false
    @State private var showVersionsSheet = false
    @State private var renameVersionID: UUID?
    @State private var renameText = ""

    private let workspaceColorHex: String?

    @MainActor
    private var palette: SummaryPalette {
        let accentBase = workspaceColorHex.flatMap(Color.init(hex:)) ?? WorkspaceTheme.accent
        return SummaryPalette(base: accentBase, colorScheme: colorScheme)
    }

    private var currentVersionName: String {
        guard
            let selectedID = viewModel.selectedVersionID,
            let current = viewModel.versions.first(where: { $0.id == selectedID })
        else {
            return "Latest"
        }
        return current.name
    }

    init(
        workspaceId: String,
        workspaceTitle: String,
        workspaceContent: String,
        workspaceColorHex: String? = nil,
        sourceItems: [SummarySourceItem] = [],
        onSummarySaved: @escaping () -> Void = {}
    ) {
        self.workspaceColorHex = workspaceColorHex
        _viewModel = StateObject(
            wrappedValue: SummaryDetailViewModel(
                workspaceId: workspaceId,
                workspaceTitle: workspaceTitle,
                workspaceContent: workspaceContent,
                sourceItems: sourceItems,
                onSummarySaved: onSummarySaved
            )
        )
    }

#if DEBUG
    init(previewSummary: StudySummary) {
        self.workspaceColorHex = nil
        _viewModel = StateObject(
            wrappedValue: SummaryDetailViewModel(
                workspaceId: UUID().uuidString,
                workspaceTitle: previewSummary.title,
                workspaceContent: "Preview-only workspace content.",
                initialSummary: previewSummary,
                shouldAutoRequestOnLoad: false
            )
        )
    }
#endif

    var body: some View {
        ZStack {
            palette.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    controlBar

                    if let summary = viewModel.summary {
                        summaryContent(summary)
                    } else {
                        emptyState
                    }

                    if !viewModel.versions.isEmpty {
                        historySection
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.red)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 120)
            }
            .safeAreaInset(edge: .top) {
                SummaryTopBar(
                    shareText: viewModel.shareSummaryText(),
                    onBack: { dismiss() },
                    onFallbackShare: { showFallbackShareSheet = true }
                )
            }
            .safeAreaInset(edge: .bottom) {
                if viewModel.summary != nil {
                    SummaryActionButtons(
                        isLoading: viewModel.isLoading,
                        onRegenerate: viewModel.regenerateSummary,
                        onSimplify: viewModel.simplifySummary
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                    .background(
                        LinearGradient(
                            colors: [palette.background.opacity(0), palette.background],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }

            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .sheet(isPresented: $showFallbackShareSheet) {
            SummaryShareSheet(activityItems: [viewModel.shareSummaryText()])
        }
        .sheet(isPresented: $showSourcePicker) {
            sourcePickerSheet
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showVersionsSheet) {
            versionsSheet
        }
        .alert("Rename Version", isPresented: Binding(get: {
            renameVersionID != nil
        }, set: { newValue in
            if !newValue { renameVersionID = nil }
        })) {
            TextField("Version name", text: $renameText)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                if let id = renameVersionID {
                    viewModel.renameVersion(id, to: renameText)
                }
            }
        }
        .task {
            viewModel.loadIfNeeded()
            if !viewModel.availableSources.isEmpty {
                showSourcePicker = true
            }
        }
        .environment(\.summaryPalette, palette)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var controlBar: some View {
        HStack(spacing: 10) {
            Button {
                showSourcePicker = true
            } label: {
                Label("Select Sources", systemImage: "line.3.horizontal.decrease.circle.fill")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(palette.accentSoft)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Button {
                showVersionsSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                    Text(currentVersionName)
                        .lineLimit(1)
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(palette.surface)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(palette.accent.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    private func summaryContent(_ summary: StudySummary) -> some View {
        VStack(alignment: .leading, spacing: 30) {
            Text(summary.title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Overview")
                Text(summary.overview)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(6)
                    .padding(16)
                    .background(palette.accentSoft.opacity(0.45))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Key Points")
                bulletList(summary.mainIdeas.map(\.text), emphasizeFirstWord: true)
                    .padding(16)
                    .background(palette.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(palette.accent.opacity(0.14), lineWidth: 1)
                    )
                    .shadow(color: palette.cardShadow.opacity(0.6), radius: 10, x: 0, y: 4)
            }

            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Key Concepts")
                VStack(spacing: 14) {
                    ForEach(summary.keyConcepts.indices, id: \.self) { index in
                        let concept = summary.keyConcepts[index]
                        VStack(alignment: .leading, spacing: 5) {
                            Text(concept.term)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Text(concept.definition)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineSpacing(3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        if index < summary.keyConcepts.count - 1 {
                            Divider().opacity(0.6)
                        }
                    }
                }
            }

            if !summary.examples.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    sectionTitle("Examples")
                    bulletList(summary.examples, emphasizeFirstWord: false)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Quick Takeaways")
                bulletList(summary.quickTakeaways, emphasizeFirstWord: false)
            }

            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Suggested Next Actions")
                bulletList(summary.suggestedNextActions, emphasizeFirstWord: false)
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.secondary)
    }

    private func bulletList(_ items: [String], emphasizeFirstWord: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(palette.accent.opacity(0.75))
                        .frame(width: 5, height: 5)
                        .padding(.top, 8)

                    if emphasizeFirstWord {
                        Text(emphasized(item))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    } else {
                        Text(item)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                }
            }
        }
    }

    private func emphasized(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        let words = text.split(separator: " ")
        guard let first = words.first,
              let range = attributed.range(of: String(first)) else { return attributed }
        attributed[range].font = .subheadline.weight(.semibold)
        attributed[range].foregroundColor = .primary
        return attributed
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.isLoading ? "Generating summary..." : "No summary yet")
                .font(.title3.weight(.bold))
            Text("Select notes, files, or photos, then generate a concise summary.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !viewModel.isLoading {
                Button("Generate Summary") {
                    viewModel.generateSummaryFromSelectedSources()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.accent)
                .buttonStyle(.plain)
            }

        }
        .padding(20)
        .summaryGlassCard()
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Summary History")
                .font(.headline.weight(.semibold))

            VStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.versions.prefix(5)) { version in
                    Button {
                        viewModel.selectVersion(version.id)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(version.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                                Text(version.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if viewModel.selectedVersionID == version.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(palette.accent)
                            } else {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .summaryGlassCard()
    }

    private var sourcePickerSheet: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    Section {
                        ForEach(viewModel.availableSources) { source in
                            Button {
                                guard source.isReadable else { return }
                                if viewModel.selectedSourceIDs.contains(source.id) {
                                    viewModel.selectedSourceIDs.remove(source.id)
                                } else {
                                    viewModel.selectedSourceIDs.insert(source.id)
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(source.name)
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                            .foregroundStyle(.primary)
                                            .lineLimit(nil)
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Text(source.kind.rawValue.capitalized)
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundStyle(.secondary)
                                        if !source.isReadable {
                                            Text("No readable text found in this source yet")
                                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                                .foregroundStyle(.orange)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    Spacer()
                                    Image(systemName: viewModel.selectedSourceIDs.contains(source.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(source.isReadable ? (viewModel.selectedSourceIDs.contains(source.id) ? palette.accent : .secondary) : .secondary.opacity(0.45))
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .padding(.vertical, 4)
                                .opacity(source.isReadable ? 1 : 0.65)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .listStyle(.insetGrouped)

                VStack(spacing: 10) {
                    Button {
                        showSourcePicker = false
                        viewModel.generateSummaryFromSelectedSources()
                    } label: {
                        Text("Generate Summary")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(palette.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.selectedSourceIDs.isEmpty || viewModel.isLoading)
                    .opacity((viewModel.selectedSourceIDs.isEmpty || viewModel.isLoading) ? 0.55 : 1)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 14)
                .background(.ultraThinMaterial)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        showSourcePicker = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Select Sources")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Select All") { viewModel.selectAllSources() }
                        Button("Clear All") { viewModel.clearAllSources() }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
        }
    }

    private var versionsSheet: some View {
        NavigationStack {
            List {
                ForEach(viewModel.versions) { version in
                    Button {
                        viewModel.selectVersion(version.id)
                    } label: {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(palette.accentSoft)
                                .frame(width: 36, height: 36)
                                .overlay {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(palette.accent)
                                }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(version.name)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text(version.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if viewModel.selectedVersionID == version.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(palette.accent)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Rename") {
                            renameVersionID = version.id
                            renameText = version.name
                        }
                        .tint(.blue)

                        Button("Delete", role: .destructive) {
                            viewModel.deleteVersion(version.id)
                        }
                    }
                }
            }
            .navigationTitle("Versions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showVersionsSheet = false }
                }
            }
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.08)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                ProgressView()
                    .tint(palette.accent)
                Text("Generating updated summary...")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(palette.accent)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .transition(.opacity)
    }
}

#Preview {
    NavigationStack {
        SummaryDetailView(previewSummary: StudySummary.previewSummaries[0])
    }
}
