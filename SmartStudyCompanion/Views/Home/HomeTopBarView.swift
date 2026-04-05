import SwiftUI

struct HomeTopBarView: View {
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Circle()
                    .fill(HomeTheme.accentSoft)
                    .overlay(
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundStyle(HomeTheme.accent)
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle().stroke(HomeTheme.accent.opacity(0.2), lineWidth: 1)
                    )

                Text("Welcome back")
                    .font(.headline)
                    .foregroundStyle(HomeTheme.accent)
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(HomeTheme.accent)
                    .frame(width: 40, height: 40)
                    .background(HomeTheme.secondaryBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, HomeTheme.horizontalPadding)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(HomeTheme.accent.opacity(0.08))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

#Preview {
    HomeTopBarView()
}
