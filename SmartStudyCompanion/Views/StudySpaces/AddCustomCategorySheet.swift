import SwiftUI

struct AddCustomCategorySheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    let existingCategories: Set<String>
    let onAdd: (String) -> Void

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canAdd: Bool {
        !trimmedText.isEmpty && !existingCategories.contains(trimmedText)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Create a category to organise this workspace.")
                    .font(.subheadline)
                    .foregroundStyle(CreateStudySpaceTheme.mutedText)

                TextField("e.g., Biology", text: $text)
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, 16)
                    .frame(height: 50)
                    .background(CreateStudySpaceTheme.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Button {
                    onAdd(trimmedText)
                    dismiss()
                } label: {
                    Text("Add Category")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(canAdd ? CreateStudySpaceTheme.accent : Color.gray.opacity(0.4))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(!canAdd)

                if !trimmedText.isEmpty, existingCategories.contains(trimmedText) {
                    Text("This category already exists.")
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }

                Spacer()
            }
            .padding(20)
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .presentationDetents([.fraction(0.34)])
    }
}

#Preview {
    AddCustomCategorySheet(existingCategories: ["IT", "AI"], onAdd: { _ in })
}
