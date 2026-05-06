import SwiftUI

struct HomeTopBarView: View {
    let appName: String
    let userInitials: String
    let animateGreeting: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                Text(appName)
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [HomeTheme.accent.opacity(0.95), HomeTheme.accent.opacity(0.72)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .tracking(0.3)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
            .opacity(animateGreeting ? 1 : 0)
            .offset(y: animateGreeting ? 0 : 6)

            Spacer()

            Circle()
                .fill(HomeTheme.accentSoft)
                .frame(width: 36, height: 36)
                .overlay(
                    Text(userInitials)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(HomeTheme.accent)
                )
        }
        .padding(.horizontal, HomeTheme.horizontalPadding)
        .padding(.vertical, 10)
    }
}

#Preview {
    HomeTopBarView(
        appName: "Lumora",
        userInitials: "Y",
        animateGreeting: true
    )
}
