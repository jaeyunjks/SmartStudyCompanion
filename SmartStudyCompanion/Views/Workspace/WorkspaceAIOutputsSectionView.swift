import SwiftUI

struct WorkspaceAIOutputsSectionView: View {
    @Environment(\.colorScheme) private var colorScheme

    let versions: [SummaryVersion]
    let onOpenHistory: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI Outputs")
                    .font(.title3.weight(.bold))
                Spacer()
                Text("\(versions.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(Capsule())
            }

            if versions.isEmpty {
                Text("No summaries yet. Generate one to see it here.")
                    .font(.subheadline)
                    .foregroundStyle(WorkspaceTheme.mutedText)
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 8) {
                    ForEach(versions.prefix(3)) { version in
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(WorkspaceTheme.accentSoft)
                                .frame(width: 32, height: 32)
                                .overlay {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(WorkspaceTheme.accent)
                                }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(version.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text(version.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(WorkspaceTheme.surfaceTertiary(for: colorScheme).opacity(0.84))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
            }

            Button("Open Summary History") {
                onOpenHistory()
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.primary)
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
        .padding(16)
        .workspaceSurface(prominence: .secondary)
    }
}

#Preview {
    WorkspaceAIOutputsSectionView(versions: [], onOpenHistory: {})
        .padding()
}
