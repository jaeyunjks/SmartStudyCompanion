import SwiftUI

struct SuggestedPromptChips: View {
    let prompts: [SuggestedPrompt]
    let onTap: (SuggestedPrompt) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(prompts) { prompt in
                    Button(action: { onTap(prompt) }) {
                        Text(prompt.title)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AIChatTheme.accent)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(AIChatTheme.accentSoft.opacity(0.95))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

#Preview {
    SuggestedPromptChips(prompts: SuggestedPrompt.defaultPrompts, onTap: { _ in })
        .padding()
}
