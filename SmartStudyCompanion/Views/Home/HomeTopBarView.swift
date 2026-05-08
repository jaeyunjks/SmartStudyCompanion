import SwiftUI

struct HomeTopBarView: View {
    let appName: String
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

            Image("LumoraHomeIcon")
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 36)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(HomeTheme.accent.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: HomeTheme.glassShadow.opacity(0.9), radius: 6, x: 0, y: 3)
        }
        .padding(.horizontal, HomeTheme.horizontalPadding)
        .padding(.vertical, 10)
    }
}

#Preview {
    HomeTopBarView(
        appName: "Lumora",
        animateGreeting: true
    )
}
