import SwiftUI

struct HeroSectionView: View {
    let onCreateStudySpace: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Personal Learning")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(HomeTheme.accent)
                    .textCase(.uppercase)
                    .tracking(1.1)

                Text("Build Momentum In Today’s Study Session")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text("Create a focused workspace, collect your materials, and continue where you left off.")
                    .font(.subheadline.weight(.regular))
                    .foregroundStyle(HomeTheme.mutedText)
                    .lineSpacing(2)
            }

            Button(action: onCreateStudySpace) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                    Text("New Study Space")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [HomeTheme.accent, HomeTheme.accent.opacity(0.82)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: HomeTheme.accent.opacity(0.18), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            .scaleEffect(1)
        }
        .padding(18)
        .homeGlass(cornerRadius: HomeTheme.cardCornerRadius)
    }
}

#Preview {
    HeroSectionView(onCreateStudySpace: {})
        .padding()
        .background(HomeTheme.background)
}
