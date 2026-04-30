import SwiftUI

struct StudyPlanFAB: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(StudyPlanTheme.accent)
                .clipShape(Circle())
                .shadow(color: StudyPlanTheme.accent.opacity(0.28), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StudyPlanFAB(action: {})
        .padding()
}
