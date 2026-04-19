import SwiftUI

struct ChatInputBar: View {
    @Binding var text: String
    let isLoading: Bool
    let onAttach: () -> Void
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onAttach) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(.secondary)
                    .frame(width: 42, height: 42)
            }
            .buttonStyle(.plain)

            TextField("Ask anything about your study material", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.body)
                .lineLimit(1...4)
                .disabled(isLoading)

            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(AIChatTheme.accent)
                    .clipShape(Circle())
                    .shadow(color: AIChatTheme.accent.opacity(0.24), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .disabled(isLoading || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity((isLoading || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.45 : 1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .background(AIChatTheme.surface)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(AIChatTheme.accent.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: AIChatTheme.shadow, radius: 14, x: 0, y: 8)
    }
}

#Preview {
    ChatInputBar(text: .constant(""), isLoading: false, onAttach: {}, onSend: {})
        .padding()
}
