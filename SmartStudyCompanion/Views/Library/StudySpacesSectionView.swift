import SwiftUI

struct StudySpacesSectionView: View {
    let spaces: [StudySpace]
    let onSelect: (StudySpace) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My Study Workspaces")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(LibraryTheme.accent)

            VStack(spacing: 14) {
                ForEach(spaces) { space in
                    Button(action: { onSelect(space) }) {
                        StudySpaceCardView(space: space)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    StudySpacesSectionView(spaces: StudySpace.sampleData, onSelect: { _ in })
        .padding()
        .background(LibraryTheme.background)
}
