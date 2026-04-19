import SwiftUI

struct WorkspaceFloatingAddButtonView: View {
    @Environment(\.workspaceThemePalette) private var palette
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(palette.primaryStrong)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: palette.primaryStrong.opacity(0.28), radius: 14, x: 0, y: 9)
        }
        .buttonStyle(WorkspacePressableButtonStyle())
        .scaleEffect(1)
        .accessibilityLabel("Add to workspace")
    }
}

#Preview {
    WorkspaceFloatingAddButtonView(onTap: {})
        .padding()
}
