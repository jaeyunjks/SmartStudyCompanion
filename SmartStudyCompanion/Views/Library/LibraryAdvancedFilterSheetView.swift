import SwiftUI

struct LibraryAdvancedFilterSheetView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedStatus: StudySpaceFilterStatus
    @Binding var selectedSort: LibrarySortOption
    @Binding var selectedCategory: String

    let statuses: [StudySpaceFilterStatus]
    let sorts: [LibrarySortOption]
    let categories: [String]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                filterSection(
                    title: "Status",
                    options: statuses,
                    selection: $selectedStatus,
                    displayText: { $0.displayName }
                )
                filterSection(
                    title: "Sort",
                    options: sorts,
                    selection: $selectedSort,
                    displayText: { $0.displayName }
                )
                filterSection(
                    title: "Category",
                    options: categories,
                    selection: $selectedCategory,
                    displayText: { $0 }
                )
                Spacer()
            }
            .padding(20)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        selectedStatus = .all
                        selectedSort = .recentlyUpdated
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
    private func filterSection<Value: Hashable>(
        title: String,
        options: [Value],
        selection: Binding<Value>,
        displayText: @escaping (Value) -> String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(LibraryTheme.accent)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        Button(action: { selection.wrappedValue = option }) {
                            Text(displayText(option))
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
        selectedStatus: .constant(.all),
        selectedSort: .constant(.recentlyUpdated),
        selectedCategory: .constant("All"),
        statuses: StudySpaceFilterStatus.allCases,
        sorts: LibrarySortOption.allCases,
        categories: ["All", "Cloud", "AI", "Data"]
    )
}
