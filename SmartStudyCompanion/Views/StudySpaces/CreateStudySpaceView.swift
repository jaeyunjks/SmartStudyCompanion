import SwiftUI

enum CreateStudySpaceTheme {
    static let accent = Color(red: 0.22, green: 0.53, blue: 0.40)
    static let accentSoft = Color(red: 0.86, green: 0.94, blue: 0.89)
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let mutedText = Color(.secondaryLabel)
    static let cornerRadius: CGFloat = 26
    static let cardMaxWidth: CGFloat = 560
    static let cardPadding: CGFloat = 24
    static let sectionSpacing: CGFloat = 20
    static let fieldCornerRadius: CGFloat = 16
}

struct CreateStudySpaceView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var spaceName = ""
    @State private var selectedIconName = "cloud"
    @State private var selectedCategory = "IT"
    @State private var descriptionText = ""

    @State private var customIcons: [String] = []
    @State private var customCategories: [String] = []
    @State private var colorOptions: [StudySpaceColorOption] = [
        .init(id: "green", name: "Green", color: CreateStudySpaceTheme.accent),
        .init(id: "blue", name: "Blue", color: Color(red: 0.30, green: 0.52, blue: 0.92)),
        .init(id: "purple", name: "Purple", color: Color(red: 0.55, green: 0.42, blue: 0.85)),
        .init(id: "orange", name: "Orange", color: Color(red: 0.95, green: 0.58, blue: 0.22)),
        .init(id: "pink", name: "Pink", color: Color(red: 0.92, green: 0.44, blue: 0.66))
    ]
    @State private var selectedColorID = "green"

    @State private var showAddIconSheet = false
    @State private var showAddCategorySheet = false
    @State private var showCustomColorSheet = false

    @State private var iconToDelete: String?
    @State private var categoryToDelete: String?
    @State private var colorToDelete: StudySpaceColorOption?

    private let builtInIcons = ["cloud", "brain.head.profile", "book.closed", "sparkles", "leaf"]
    private let addableIconOptions = [
        "atom", "bolt", "cpu", "network", "chart.bar", "graduationcap", "lightbulb", "doc.text", "pencil", "target"
    ]
    private let builtInCategories = ["IT", "AI", "Math", "Design"]

    let onCreate: ((String, String, String, String) -> Void)?

    init(onCreate: ((String, String, String, String) -> Void)? = nil) {
        self.onCreate = onCreate
    }

    private var allIcons: [String] {
        builtInIcons + customIcons
    }

    private var allCategories: [String] {
        builtInCategories + customCategories
    }

    private var selectedColor: Color {
        colorOptions.first(where: { $0.id == selectedColorID })?.color ?? CreateStudySpaceTheme.accent
    }

    private var canCreate: Bool {
        !spaceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: CreateStudySpaceTheme.sectionSpacing) {
                CreateStudySpaceHeaderView(
                    title: "Create Study Space",
                    subtitle: "Design your digital sanctuary for focused learning.",
                    onClose: { dismiss() }
                )

                StudySpaceNameInputView(text: $spaceName)

                StudySpaceIconPickerView(
                    icons: allIcons,
                    selectedIconName: $selectedIconName,
                    selectedColor: selectedColor,
                    onAdd: { showAddIconSheet = true },
                    isCustomIcon: { customIcons.contains($0) },
                    onLongPressIcon: { iconToDelete = $0 }
                )

                StudySpaceCategoryPickerView(
                    categories: allCategories,
                    selectedCategory: $selectedCategory,
                    selectedColor: selectedColor,
                    onAddCategory: { showAddCategorySheet = true },
                    isCustomCategory: { customCategories.contains($0) },
                    onLongPressCategory: { categoryToDelete = $0 }
                )

                StudySpaceColorPickerView(
                    colors: colorOptions,
                    selectedColorID: $selectedColorID,
                    onAddCustomColor: { showCustomColorSheet = true },
                    onLongPressColor: { colorToDelete = $0 }
                )

                StudySpaceDescriptionInputView(text: $descriptionText)

                Button(action: handleCreate) {
                    Text("Create")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canCreate ? selectedColor : Color.gray.opacity(0.45))
                        .clipShape(Capsule())
                        .shadow(color: selectedColor.opacity(canCreate ? 0.24 : 0), radius: 14, x: 0, y: 8)
                }
                .buttonStyle(.plain)
                .disabled(!canCreate)
                .padding(.top, 2)
            }
            .padding(CreateStudySpaceTheme.cardPadding)
            .frame(maxWidth: CreateStudySpaceTheme.cardMaxWidth)
            .frame(maxWidth: .infinity)
        }
        .sheet(isPresented: $showAddIconSheet) {
            AddCustomIconSheet(
                availableIcons: addableIconOptions,
                alreadyAddedIcons: Set(customIcons),
                onSelect: { symbol in
                    guard !customIcons.contains(symbol) else {
                        selectedIconName = symbol
                        return
                    }
                    customIcons.append(symbol)
                    selectedIconName = symbol
                }
            )
        }
        .sheet(isPresented: $showAddCategorySheet) {
            AddCustomCategorySheet(
                existingCategories: Set(allCategories),
                onAdd: { category in
                    guard !customCategories.contains(category) else {
                        selectedCategory = category
                        return
                    }
                    customCategories.append(category)
                    selectedCategory = category
                }
            )
        }
        .sheet(isPresented: $showCustomColorSheet) {
            CustomColorPickerSheet { color in
                let id = "custom-\(UUID().uuidString)"
                colorOptions.append(.init(id: id, name: "Custom", color: color, isCustom: true))
                selectedColorID = id
            }
        }
        .confirmationDialog(
            "Remove custom icon?",
            isPresented: Binding(
                get: { iconToDelete != nil },
                set: { if !$0 { iconToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                guard let icon = iconToDelete else { return }
                customIcons.removeAll { $0 == icon }
                if selectedIconName == icon {
                    selectedIconName = builtInIcons.first ?? "cloud"
                }
                iconToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                iconToDelete = nil
            }
        }
        .confirmationDialog(
            "Remove custom category?",
            isPresented: Binding(
                get: { categoryToDelete != nil },
                set: { if !$0 { categoryToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                guard let category = categoryToDelete else { return }
                customCategories.removeAll { $0 == category }
                if selectedCategory == category {
                    selectedCategory = builtInCategories.first ?? "IT"
                }
                categoryToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                categoryToDelete = nil
            }
        }
        .confirmationDialog(
            "Remove custom color?",
            isPresented: Binding(
                get: { colorToDelete != nil },
                set: { if !$0 { colorToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                guard let color = colorToDelete else { return }
                colorOptions.removeAll { $0.id == color.id }
                if selectedColorID == color.id {
                    selectedColorID = "green"
                }
                colorToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                colorToDelete = nil
            }
        }
        .presentationDetents([.fraction(0.92), .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(34)
        .presentationBackground(.thinMaterial)
    }

    private func handleCreate() {
        onCreate?(spaceName, selectedIconName, selectedCategory, descriptionText)
        dismiss()
    }
}

#Preview {
    CreateStudySpaceView()
}
