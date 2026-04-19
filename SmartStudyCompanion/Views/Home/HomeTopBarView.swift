import SwiftUI

struct HomeTopBarView: View {
    let greetingText: String
    let userInitials: String
    let animateGreeting: Bool
    let onSettingsTap: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                Text(greetingText)
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(HomeTheme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
            .opacity(animateGreeting ? 1 : 0)
            .offset(y: animateGreeting ? 0 : 6)

            Spacer()

            HStack(spacing: 8) {
                Circle()
                    .fill(HomeTheme.accentSoft)
                    .frame(width: 34, height: 34)
                    .overlay(
                        Text(userInitials)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(HomeTheme.accent)
                    )

                Button(action: onSettingsTap) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(HomeTheme.accent)
                        .frame(width: 34, height: 34)
                        .background(HomeTheme.secondaryBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, HomeTheme.horizontalPadding)
        .padding(.vertical, 10)
    }
}

#Preview {
    HomeTopBarView(
        greetingText: "Good afternoon, Yafie",
        userInitials: "YF",
        animateGreeting: true,
        onSettingsTap: {}
    )
}
