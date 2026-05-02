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
                    isBookmarked: viewModel.summary?.isBookmarked ?? false,
                    shareText: viewModel.shareSummaryText(),
                    onBack: { dismiss() },
                    onToggleBookmark: viewModel.toggleBookmark,
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
        }
        .environment(\.summaryPalette, palette)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var controlBar: some View {
        HStack(spacing: 10) {
            Button {
                showSourcePicker = true
            } label: {
                Label("Sources", systemImage: "line.3.horizontal.decrease.circle")
                    .font(.subheadline.weight(.semibold))
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
                .font(.subheadline.weight(.semibold))
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

    private var sourcePickerSheet: some View {
        NavigationStack {
            List {
                ForEach(viewModel.availableSources) { source in
                    Button {
                        if viewModel.selectedSourceIDs.contains(source.id) {
                            viewModel.selectedSourceIDs.remove(source.id)
                        } else {
                            viewModel.selectedSourceIDs.insert(source.id)
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(source.name)
                                    .foregroundStyle(.primary)
                                Text(source.kind.rawValue.capitalized)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: viewModel.selectedSourceIDs.contains(source.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(viewModel.selectedSourceIDs.contains(source.id) ? palette.accent : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Select Sources")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showSourcePicker = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Generate") {
                        showSourcePicker = false
                        viewModel.generateSummaryFromSelectedSources()
                    }
                }
            }
        }
    }

    private var versionsSheet: some View {
        NavigationStack {
            List {
                ForEach(viewModel.versions) { version in
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(version.name)
                            Text(version.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if viewModel.selectedVersionID == version.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(palette.accent)
                        }

                        Menu {
                            Button("Rename") {
                                renameVersionID = version.id
                                renameText = version.name
                            }
                            Button("Delete", role: .destructive) {
                                viewModel.deleteVersion(version.id)
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .frame(width: 30, height: 30)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.selectVersion(version.id)
                    }
                }
            }
            .navigationTitle("Summary Versions")
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
