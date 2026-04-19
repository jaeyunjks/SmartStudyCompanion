import SwiftUI

struct ContinueLearningSectionView: View {
    let spaces: [StudySpace]
    let onSelect: (StudySpace) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Continue Learning")
                    .font(.title3.weight(.bold))

                Spacer()

                Button("View all", action: {})
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(HomeTheme.accent)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 250), spacing: 14)], spacing: 14) {
                ForEach(spaces) { space in
                    Button(action: { onSelect(space) }) {
                        ContinueLearningCardView(space: space)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct ContinueLearningCardView: View {
    let space: StudySpace

    private var accent: Color {
        space.status == "Inactive" ? Color.gray : space.workspaceAccentColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(accent.opacity(0.10))
                    Image(systemName: space.iconName)
                        .foregroundStyle(accent)
                        .font(.system(size: 17, weight: .semibold))
                }
                .frame(width: 42, height: 42)

                Spacer()

                Text(space.status)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(accent.opacity(0.10))
                    .clipShape(Capsule())
                    .foregroundStyle(accent)
            }

            Text(space.title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Text(space.description)
                .font(.footnote)
                .foregroundStyle(HomeTheme.mutedText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Progress")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(accent)

                    Spacer()

                    Text("\(Int(space.progress * 100))%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(accent)
                }

                ProgressView(value: space.progress)
                    .tint(accent)
                    .background(accent.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .homeGlass(cornerRadius: HomeTheme.cardCornerRadius)
        .contentShape(RoundedRectangle(cornerRadius: HomeTheme.cardCornerRadius, style: .continuous))
    }
}

#Preview {
    ContinueLearningSectionView(spaces: Array(StudySpace.sampleData.prefix(2)), onSelect: { _ in })
        .padding()
        .background(HomeTheme.background)
}
