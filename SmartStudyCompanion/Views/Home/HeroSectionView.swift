import SwiftUI

struct HeroSectionView: View {
    let onCreateStudySpace: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Personal Learning")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(HomeTheme.accent)
                    .textCase(.uppercase)

                Text("Good afternoon, Yafie")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.85)
            }

            Spacer(minLength: 8)

            Button(action: onCreateStudySpace) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("New Study Space")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [HomeTheme.accent, HomeTheme.accent.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: HomeTheme.accent.opacity(0.18), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(HomeTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: HomeTheme.cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HomeTheme.cardCornerRadius, style: .continuous)
                .stroke(HomeTheme.accent.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    HeroSectionView(onCreateStudySpace: {})
        .padding()
        .background(HomeTheme.background)
}
