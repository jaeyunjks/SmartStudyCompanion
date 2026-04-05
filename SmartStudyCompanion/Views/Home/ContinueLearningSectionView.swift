import SwiftUI

struct ContinueLearningSectionView: View {
    let spaces: [StudySpace]
    let onSelect: (StudySpace) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Continue Learning")
                    .font(.title2.weight(.bold))

                Spacer()

                Button("View all", action: {})
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(HomeTheme.accent)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 16)], spacing: 16) {
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
        switch space.status {
        case "In Progress", "Active", "Priority":
            return HomeTheme.accent
        case "Review":
            return Color(red: 0.20, green: 0.53, blue: 0.56)
        case "Completed":
            return Color.gray
        default:
            return HomeTheme.accent
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(accent.opacity(0.12))
                    Image(systemName: space.iconName)
                        .foregroundStyle(accent)
                        .font(.system(size: 18, weight: .semibold))
                }
                .frame(width: 44, height: 44)

                Spacer()

                Text(space.status)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(accent.opacity(0.12))
                    .clipShape(Capsule())
                    .foregroundStyle(accent)
            }

            Text(space.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(space.description)
                .font(.footnote)
                .foregroundStyle(HomeTheme.mutedText)
                .lineLimit(3)

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
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HomeTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: HomeTheme.cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HomeTheme.cardCornerRadius, style: .continuous)
                .stroke(accent.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: accent.opacity(0.06), radius: 10, x: 0, y: 6)
    }
}

#Preview {
    ContinueLearningSectionView(spaces: Array(StudySpace.sampleData.prefix(2)), onSelect: { _ in })
        .padding()
        .background(HomeTheme.background)
}
