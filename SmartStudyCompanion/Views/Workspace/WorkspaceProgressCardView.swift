import SwiftUI

struct WorkspaceProgressCardView: View {
    let progress: Double
    let accent: Color

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Course Progress")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(accent)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(accent)
            }

            ProgressView(value: progress)
                .tint(accent)
                .background(accent.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(16)
        .background(WorkspaceTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: WorkspaceTheme.cornerRadius, style: .continuous))
    }
}

#Preview {
    WorkspaceProgressCardView(progress: 0.74, accent: WorkspaceTheme.accent)
        .padding()
}
