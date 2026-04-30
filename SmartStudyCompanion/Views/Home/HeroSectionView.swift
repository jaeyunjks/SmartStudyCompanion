import SwiftUI

struct HeroSectionView: View {
    let onCreateStudySpace: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 9) {
                    Text("PERSONAL LEARNING")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(HomeTheme.accent)
                        .tracking(1.2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Build Momentum In Today’s Study Session")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.trailing, 110)

                    Text("Create a focused workspace, collect your materials, and continue where you left off.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(HomeTheme.mutedText)
                        .lineSpacing(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: onCreateStudySpace) {
                    HStack(spacing: 9) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text("New Study Workspace")
                            .font(.system(size: 14, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 13)
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
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            Image("study_illustration")
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 130, height: 130)
                .opacity(0.88)
                .padding(.top, 16)
                .padding(.trailing, 16)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .padding(24)
        .homeGlass(cornerRadius: HomeTheme.cardCornerRadius)
    }
}

#Preview {
    HeroSectionView(onCreateStudySpace: {})
        .padding()
        .background(HomeTheme.background)
}
