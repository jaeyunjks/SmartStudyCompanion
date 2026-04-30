import SwiftUI

struct StudyPlanTopBar: View {
    let onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(StudyPlanTheme.accent)
                    .frame(width: 40, height: 40)
                    .background(StudyPlanTheme.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Study Plan")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(StudyPlanTheme.accent)

            Spacer()

            Circle()
                .fill(StudyPlanTheme.accentSoft)
                .frame(width: 34, height: 34)
                .overlay {
                    Text("SC")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(StudyPlanTheme.accent)
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(StudyPlanTheme.accentSoft.opacity(0.42))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.horizontal, 12)
        .shadow(color: StudyPlanTheme.shadow, radius: 12, x: 0, y: 8)
    }
}

#Preview {
    StudyPlanTopBar(onBack: {})
        .padding()
}
