import SwiftUI

struct LibraryAdvancedFilterSheetView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedStatus: String
    @Binding var selectedSort: String
    @Binding var selectedCategory: String

    let statuses: [String]
    let sorts: [String]
    let categories: [String]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                filterSection(title: "Status", options: statuses, selection: $selectedStatus)
                filterSection(title: "Sort", options: sorts, selection: $selectedSort)
                filterSection(title: "Category", options: categories, selection: $selectedCategory)
                Spacer()
            }
            .padding(20)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        selectedStatus = "All"
                        selectedSort = "Recently Updated"
                        selectedCategory = "All"
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func filterSection(title: String, options: [String], selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(LibraryTheme.accent)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        Button(action: { selection.wrappedValue = option }) {
                            Text(option)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(selection.wrappedValue == option ? .white : LibraryTheme.accent)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selection.wrappedValue == option ? LibraryTheme.accent : LibraryTheme.accentSoft.opacity(0.8))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(14)
        .libraryGlass(cornerRadius: LibraryTheme.smallCornerRadius)
    }
}

#Preview {
    LibraryAdvancedFilterSheetView(
        selectedStatus: .constant("All"),
        selectedSort: .constant("Recently Updated"),
        selectedCategory: .constant("All"),
        statuses: ["All", "Active", "Review", "Completed"],
        sorts: ["Recently Updated", "Alphabetical"],
        categories: ["All", "Cloud", "AI", "Data"]
    )
}
