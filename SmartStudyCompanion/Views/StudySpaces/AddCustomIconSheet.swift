import SwiftUI

struct AddCustomIconSheet: View {
    @Environment(\.dismiss) private var dismiss

    let availableIcons: [String]
    let alreadyAddedIcons: Set<String>
    let onSelect: (String) -> Void

    @State private var selectedIcon: String?

    private let columns = [
        GridItem(.adaptive(minimum: 56), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Choose an icon")
                    .font(.subheadline)
                    .foregroundStyle(CreateStudySpaceTheme.mutedText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(availableIcons, id: \.self) { symbol in
                            let isSelected = selectedIcon == symbol
                            let isAdded = alreadyAddedIcons.contains(symbol)
                            Button {
                                selectedIcon = symbol
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: symbol)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(isSelected ? .white : CreateStudySpaceTheme.mutedText)
                                        .frame(width: 56, height: 56)
                                        .background(isSelected ? CreateStudySpaceTheme.accent : CreateStudySpaceTheme.secondaryBackground)
                                        .clipShape(Circle())

                                    if isAdded {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(CreateStudySpaceTheme.accent)
                                            .background(Color.white, in: Circle())
                                            .offset(x: 2, y: -2)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Button {
                    guard let selectedIcon else { return }
                    onSelect(selectedIcon)
                    dismiss()
                } label: {
                    Text("Add Icon")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(selectedIcon == nil ? Color.gray.opacity(0.4) : CreateStudySpaceTheme.accent)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(selectedIcon == nil)
            }
            .padding(20)
            .navigationTitle("Add Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .presentationDetents([.fraction(0.5), .medium])
    }
}

#Preview {
    AddCustomIconSheet(
        availableIcons: ["cloud", "atom", "bolt", "book", "chart.bar", "lock.shield"],
        alreadyAddedIcons: ["cloud"],
        onSelect: { _ in }
    )
}
