import SwiftUI

struct WorkspaceSectionLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption.weight(.bold))
            .textCase(.uppercase)
            .tracking(1.0)
            .foregroundStyle(WorkspaceTheme.mutedText)
            .padding(.horizontal, 2)
    }
}

#Preview {
    WorkspaceSectionLabel(title: "Workspace")
        .padding()
}
