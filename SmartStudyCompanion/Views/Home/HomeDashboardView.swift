import SwiftUI

enum HomeTheme {
    static let accent = Color(red: 0.22, green: 0.53, blue: 0.40)
    static let accentSoft = Color(red: 0.86, green: 0.94, blue: 0.89)
    static let background = Color(red: 0.97, green: 0.98, blue: 0.97)
    static let cardBackground = Color(.systemBackground)
    static let mutedText = Color(.secondaryLabel)
    static let secondaryBackground = Color(.secondarySystemBackground)

    static let horizontalPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 22
    static let cardCornerRadius: CGFloat = 20
    static let chipCornerRadius: CGFloat = 18
    static let smallCornerRadius: CGFloat = 14
}

struct HomeDashboardView: View {
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: HomeTheme.sectionSpacing) {
                HeroSectionView()
                QuickActionsChipsView()
                ContinueLearningSectionView()
                RecentStudySpacesSectionView()
            }
            .padding(.horizontal, HomeTheme.horizontalPadding)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .background(HomeTheme.background.ignoresSafeArea())
        .safeAreaInset(edge: .top) {
            HomeTopBarView()
        }
        .safeAreaInset(edge: .bottom) {
            HomeBottomNavBarView(selected: .home)
        }
    }
}

#Preview {
    HomeDashboardView()
}
