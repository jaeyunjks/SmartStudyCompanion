import SwiftUI

struct WorkspaceFloatingAddButtonView: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(WorkspaceTheme.accent)
                .clipShape(Circle())
                .shadow(color: WorkspaceTheme.accent.opacity(0.25), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add to workspace")
    }
}

#Preview {
    WorkspaceFloatingAddButtonView(onTap: {})
        .padding()
}