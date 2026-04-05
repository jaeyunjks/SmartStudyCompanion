import SwiftUI

enum CreateStudySpaceTheme {
    static let accent = Color(red: 0.22, green: 0.53, blue: 0.40)
    static let accentSoft = Color(red: 0.86, green: 0.94, blue: 0.89)
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let mutedText = Color(.secondaryLabel)
    static let cornerRadius: CGFloat = 24
    static let cardMaxWidth: CGFloat = 560
    static let cardPadding: CGFloat = 28
    static let sectionSpacing: CGFloat = 22
    static let fieldCornerRadius: CGFloat = 16
}

struct CreateStudySpaceView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var spaceName = ""
    @State private var selectedIconName = "cloud"
    @State private var selectedCategory = "IT"
    @State private var descriptionText = ""
    @State private var selectedColor = CreateStudySpaceTheme.accent
    @State private var showMoreIconsSheet = false
    @State private var showAddCategorySheet = false
    @State private var customCategoryText = ""
    @State private var categoryOptions = ["IT", "AI", "Math", "Design"]

    private let iconOptions = ["cloud", "brain.head.profile", "book.closed", "sparkles", "leaf"]
    private let colorOptions: [StudySpaceColorOption] = [
        .init(name: "Green", color: CreateStudySpaceTheme.accent),
        .init(name: "Blue", color: Color(red: 0.30, green: 0.52, blue: 0.92)),
        .init(name: "Purple", color: Color(red: 0.55, green: 0.42, blue: 0.85)),
        .init(name: "Orange", color: Color(red: 0.95, green: 0.58, blue: 0.22)),
        .init(name: "Pink", color: Color(red: 0.92, green: 0.44, blue: 0.66))
    ]

    let onCreate: ((String, String, String, String) -> Void)?

    init(onCreate: ((String, String, String, String) -> Void)? = nil) {
        self.onCreate = onCreate
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.22).ignoresSafeArea()

            ScrollView {
                VStack(spacing: CreateStudySpaceTheme.sectionSpacing) {
                    VStack(spacing: CreateStudySpaceTheme.sectionSpacing) {
                        CreateStudySpaceHeaderView(
                            title: "Create Study Space",
                            subtitle: "Design your digital sanctuary for focused learning.",
                            onClose: { dismiss() }
                        )

                        StudySpaceNameInputView(text: $spaceName)

                        StudySpaceIconPickerView(
                            icons: iconOptions,
                            selectedIconName: $selectedIconName,
                            selectedColor: selectedColor,
                            onAdd: { showMoreIconsSheet = true }
                        )

                        StudySpaceCategoryPickerView(
                            categories: categoryOptions,
                            selectedCategory: $selectedCategory,
                            selectedColor: selectedColor,
                            onAddCategory: { showAddCategorySheet = true }
                        )

                        StudySpaceColorPickerView(
                            colors: colorOptions,
                            selectedColor: $selectedColor
                        )

                        StudySpaceDescriptionInputView(text: $descriptionText)

                        Button(action: handleCreate) {
                            Text("Create")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(selectedColor)
                                .clipShape(Capsule())
                                .shadow(color: selectedColor.opacity(0.25), radius: 14, x: 0, y: 8)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                    }
                    .padding(CreateStudySpaceTheme.cardPadding)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: CreateStudySpaceTheme.cornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: CreateStudySpaceTheme.cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 24, x: 0, y: 16)
                    .overlay(
                        Circle()
                            .fill(CreateStudySpaceTheme.accentSoft.opacity(0.5))
                            .frame(width: 140, height: 140)
                            .blur(radius: 44)
                            .offset(x: 130, y: -130),
                        alignment: .topTrailing
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .frame(maxWidth: CreateStudySpaceTheme.cardMaxWidth)
                .frame(maxWidth: .infinity)
            }
        }
        .sheet(isPresented: $showMoreIconsSheet) {
            CreateStudySpacePlaceholderSheetView(title: "More Icons")
        }
        .sheet(isPresented: $showAddCategorySheet) {
            CreateStudySpaceAddCategorySheetView(
                text: $customCategoryText,
                onAdd: {
                    let trimmed = customCategoryText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        categoryOptions.append(trimmed)
                        selectedCategory = trimmed
                    }
                    customCategoryText = ""
                    showAddCategorySheet = false
                }
            )
        }
    }

    private func handleCreate() {
        onCreate?(spaceName, selectedIconName, selectedCategory, descriptionText)
        dismiss()
    }
}

private struct CreateStudySpacePlaceholderSheetView: View {
    let title: String

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title2.weight(.bold))
            Text("This is a placeholder screen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

private struct CreateStudySpaceAddCategorySheetView: View {
    @Binding var text: String
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Add Category")
                .font(.title2.weight(.bold))

            TextField("e.g., Biology", text: $text)
                .textInputAutocapitalization(.words)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(CreateStudySpaceTheme.secondaryBackground)
                .clipShape(Capsule())

            Button("Add", action: onAdd)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(CreateStudySpaceTheme.accent)
                .foregroundStyle(.white)
                .clipShape(Capsule())
        }
        .padding()
    }
}

#Preview {
    CreateStudySpaceView()
}
