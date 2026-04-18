import SwiftUI

struct WorkspaceFloatingAddButtonView: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(WorkspaceTheme.accent)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: WorkspaceTheme.accent.opacity(0.25), radius: 14, x: 0, y: 9)
        }
        .buttonStyle(.plain)
        .scaleEffect(1)
        .accessibilityLabel("Add to workspace")
    }
}

#Preview {
    WorkspaceFloatingAddButtonView(onTap: {})
        .padding()
}
