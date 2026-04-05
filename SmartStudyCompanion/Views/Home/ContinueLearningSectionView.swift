import SwiftUI

struct ContinueLearningSectionView: View {
    private let items: [ContinueLearningItem] = [
        .init(
            title: "41001 Cloud Computing",
            subtitle: "Infrastructure, Serverless Architectures, and Security Protocols.",
            progress: 0.74,
            status: "In Progress",
            icon: "cloud",
            accent: HomeTheme.accent
        ),
        .init(
            title: "Advanced AI Ethics",
            subtitle: "Algorithmic Bias, Regulatory Frameworks, and Future Safety.",
            progress: 0.42,
            status: "Priority",
            icon: "brain.head.profile",
            accent: Color(red: 0.20, green: 0.53, blue: 0.56)
        )
    ]

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
                ForEach(items) { item in
                    ContinueLearningCardView(item: item)
                }
            }
        }
    }
}

private struct ContinueLearningItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let progress: Double
    let status: String
    let icon: String
    let accent: Color
}

private struct ContinueLearningCardView: View {
    let item: ContinueLearningItem

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(item.accent.opacity(0.12))
                    Image(systemName: item.icon)
                        .foregroundStyle(item.accent)
                        .font(.system(size: 18, weight: .semibold))
                }
                .frame(width: 44, height: 44)

                Spacer()

                Text(item.status)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.accent.opacity(0.12))
                    .clipShape(Capsule())
                    .foregroundStyle(item.accent)
            }

            Text(item.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(item.subtitle)
                .font(.footnote)
                .foregroundStyle(HomeTheme.mutedText)
                .lineLimit(3)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Progress")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(item.accent)

                    Spacer()

                    Text("\(Int(item.progress * 100))%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(item.accent)
                }

                ProgressView(value: item.progress)
                    .tint(item.accent)
                    .background(item.accent.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HomeTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: HomeTheme.cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HomeTheme.cardCornerRadius, style: .continuous)
                .stroke(item.accent.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: item.accent.opacity(0.06), radius: 10, x: 0, y: 6)
    }
}

#Preview {
    ContinueLearningSectionView()
        .padding()
        .background(HomeTheme.background)
}
