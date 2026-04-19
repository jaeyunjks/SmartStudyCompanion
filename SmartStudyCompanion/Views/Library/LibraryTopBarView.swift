import SwiftUI

struct LibraryTopBarView: View {
    var body: some View {
        HStack {
            Text("Library")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(LibraryTheme.accent)
            Spacer()
        }
        .padding(.horizontal, LibraryTheme.horizontalPadding)
        .padding(.vertical, 10)
    }
}

#Preview {
    LibraryTopBarView()
}
