import SwiftUI

struct WorkspaceSectionLabel: View {
    @Environment(\.workspaceThemePalette) private var palette
    let title: String

    var body: some View {
        Text(title)
            .font(.caption.weight(.bold))
            .textCase(.uppercase)
            .tracking(1.0)
            .foregroundStyle(palette.primaryStrong.opacity(0.86))
            .padding(.horizontal, 2)
    }
}

#Preview {
    WorkspaceSectionLabel(title: "Workspace")
        .padding()
}
