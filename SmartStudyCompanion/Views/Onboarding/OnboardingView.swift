import SwiftUI

struct OnboardingPageModel: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    let backgroundColor: Color
}

private enum OnboardingTheme {
    static let outline = Color(red: 0.17, green: 0.19, blue: 0.22)
    static let ctaGradient = LinearGradient(
        colors: [Color(red: 0.44, green: 0.80, blue: 0.74), Color(red: 0.43, green: 0.71, blue: 0.92)],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let card = Color.white.opacity(0.92)

    static let backgrounds: [Color] = [
        Color(red: 0.92, green: 0.96, blue: 0.99),
        Color(red: 0.90, green: 0.97, blue: 0.95),
        Color(red: 0.96, green: 0.97, blue: 0.94)
    ]
}

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var selectedPage = 0

    private let pages: [OnboardingPageModel] = [
        .init(
            title: "Build Better Study Habits",
            subtitle: "Organise notes, tasks, and ideas in one playful workspace.",
            imageName: "onboard1",
            backgroundColor: OnboardingTheme.backgrounds[0]
        ),
        .init(
            title: "Ask Anything, Learn Faster",
            subtitle: "Get quick AI-powered help when your lessons feel tricky.",
            imageName: "onboard2",
            backgroundColor: OnboardingTheme.backgrounds[1]
        ),
        .init(
            title: "Stay Focused, Finish Strong",
            subtitle: "Track your wins and keep momentum every single day.",
            imageName: "onboard3",
            backgroundColor: OnboardingTheme.backgrounds[2]
        )
    ]

    var body: some View {
        ZStack {
            pages[selectedPage].backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.35), value: selectedPage)

            VStack(spacing: 18) {
                ProgressHeaderView(
                    currentPage: selectedPage,
                    pageCount: pages.count,
                    onSkip: completeOnboarding
                )

                TabView(selection: $selectedPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingCardView(page: page)
                            .tag(index)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.28), value: selectedPage)

                Button(action: nextOrFinish) {
                    HStack(spacing: 10) {
                        Text(selectedPage == pages.count - 1 ? "Get Started" : "Next")
                            .font(.system(size: 19, weight: .semibold, design: .default))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                    .background(OnboardingTheme.ctaGradient)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(OnboardingTheme.outline.opacity(0.18), lineWidth: 1.3)
                    )
                    .shadow(color: Color(red: 0.60, green: 0.74, blue: 0.88).opacity(0.25), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
            }
            .padding(.top, 12)
        }
    }

    private func nextOrFinish() {
        if selectedPage < pages.count - 1 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                selectedPage += 1
            }
        } else {
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        hasSeenOnboarding = true
    }
}

struct ProgressHeaderView: View {
    let currentPage: Int
    let pageCount: Int
    let onSkip: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            HStack(spacing: 8) {
                ForEach(0..<pageCount, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentPage ? OnboardingTheme.outline : OnboardingTheme.outline.opacity(0.18))
                        .frame(width: index == currentPage ? 36 : 24, height: 8)
                        .animation(.easeInOut(duration: 0.25), value: currentPage)
                }
            }

            Spacer()

            Button("Skip", action: onSkip)
                .font(.system(size: 14, weight: .semibold, design: .default))
                .foregroundStyle(OnboardingTheme.outline.opacity(0.75))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.56))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(OnboardingTheme.outline, lineWidth: 2))
        }
        .padding(.horizontal, 24)
    }
}

struct OnboardingCardView: View {
    let page: OnboardingPageModel

    var body: some View {
        VStack(spacing: 22) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.72))
                .overlay(
                    Image(page.imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(24)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(OnboardingTheme.outline, lineWidth: 4)
                )
                .frame(maxWidth: .infinity)
                .frame(height: 340)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)

            VStack(spacing: 10) {
                Text(page.title)
                    .font(.system(size: 33, weight: .bold, design: .default))
                    .foregroundStyle(OnboardingTheme.outline)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.system(size: 17, weight: .regular, design: .default))
                    .foregroundStyle(OnboardingTheme.outline.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(.horizontal, 10)

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(OnboardingTheme.outline, lineWidth: 4)
        )
    }
}

#Preview {
    @Previewable @State var hasSeenOnboarding = false
    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
}
