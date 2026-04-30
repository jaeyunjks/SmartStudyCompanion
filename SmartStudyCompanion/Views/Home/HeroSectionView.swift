import SwiftUI

struct HeroSectionView: View {
    let onCreateStudySpace: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Personal Learning")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(HomeTheme.accent)
                        .textCase(.uppercase)
                        .tracking(1.1)

                    Text("Build Momentum In Today’s Study Session")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Create a focused workspace, collect your materials, and continue where you left off.")
                        .font(.subheadline.weight(.regular))
                        .foregroundStyle(HomeTheme.mutedText)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button(action: onCreateStudySpace) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text("New Study Workspace")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 18)
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            HeroWorkspaceVisual()
                .frame(width: 88, height: 106)
                .padding(.top, 6)
                .accessibilityHidden(true)
        }
        .padding(18)
        .homeGlass(cornerRadius: HomeTheme.cardCornerRadius)
    }
}

private struct HeroWorkspaceVisual: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(HomeTheme.accentSoft.opacity(0.45))

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.95))
                .frame(width: 62, height: 72)
                .overlay(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: 5) {
                        Label("Summary", systemImage: "sparkles.rectangle.stack")
                            .font(.system(size: 7, weight: .semibold))
                            .foregroundStyle(HomeTheme.accent)

                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(HomeTheme.accent.opacity(0.14))
                            .frame(width: 44, height: 7)

                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(HomeTheme.accent.opacity(0.10))
                            .frame(width: 34, height: 7)

                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("3 notes")
                        }
                        .font(.system(size: 7, weight: .semibold))
                        .foregroundStyle(HomeTheme.accent.opacity(0.85))
                    }
                    .padding(7)
                }

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(HomeTheme.accent.opacity(0.2), lineWidth: 1)
                .frame(width: 62, height: 72)
                .offset(x: 8, y: 8)
        }
        .padding(8)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(HomeTheme.accent.opacity(0.13), lineWidth: 1)
        )
    }
}

#Preview {
    HeroSectionView(onCreateStudySpace: {})
        .padding()
        .background(HomeTheme.background)
}
