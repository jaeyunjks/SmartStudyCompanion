import SwiftUI

struct LibraryTopBarView: View {
    var body: some View {
        HStack {
            Text("Library")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(LibraryTheme.accent)
            Spacer()
        }
        .padding(.horizontal, LibraryTheme.horizontalPadding)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }
}

#Preview {
    LibraryTopBarView()
}
