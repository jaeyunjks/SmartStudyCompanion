import SwiftUI

struct CustomColorPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedColor: Color = CreateStudySpaceTheme.accent
    let onAddColor: (Color) -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Pick a custom accent color for this study space.")
                    .font(.subheadline)
                    .foregroundStyle(CreateStudySpaceTheme.mutedText)

                HStack(spacing: 14) {
                    Circle()
                        .fill(selectedColor)
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))

                    ColorPicker("Custom Color", selection: $selectedColor, supportsOpacity: false)
                        .labelsHidden()

                    Text("Custom Color")
                        .font(.subheadline.weight(.semibold))
                }
                .padding(14)
                .background(CreateStudySpaceTheme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Button {
                    onAddColor(selectedColor)
                    dismiss()
                } label: {
                    Text("Use Color")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(CreateStudySpaceTheme.accent)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(20)
            .navigationTitle("Custom Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .presentationDetents([.fraction(0.38)])
    }
}

#Preview {
    CustomColorPickerSheet(onAddColor: { _ in })
}
