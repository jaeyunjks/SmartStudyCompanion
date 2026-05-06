import SwiftUI
import UIKit

struct ChatBubbleView: View {
    let message: ChatMessage
    let onRegenerate: (() -> Void)?
    @State private var feedbackState: FeedbackState = .none

    enum FeedbackState {
        case none
        case up
        case down
    }

    init(message: ChatMessage, onRegenerate: (() -> Void)? = nil) {
        self.message = message
        self.onRegenerate = onRegenerate
    }

    var body: some View {
        VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 6) {
            if message.role == .assistant {
                AssistantHeaderView()
                    .padding(.leading, 2)
            }

            bubble

            HStack(spacing: 8) {
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)

                if message.role == .assistant, !message.isTyping {
                    Button(action: { feedbackState = .up }) {
                        Image(systemName: feedbackState == .up ? "hand.thumbsup.fill" : "hand.thumbsup")
                    }
                    .buttonStyle(.plain)

                    Button(action: { feedbackState = .down }) {
                        Image(systemName: feedbackState == .down ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                    }
                    .buttonStyle(.plain)

                    Button(action: { onRegenerate?() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)

                    Button(action: { UIPasteboard.general.string = message.text }) {
                        Image(systemName: "doc.on.doc")
                    }
                    .buttonStyle(.plain)
                }
            }
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
    }

    @ViewBuilder
    private var bubble: some View {
        if message.isTyping {
            HStack(spacing: 8) {
                ProgressView()
                    .tint(AIChatTheme.accent)
                Text("Thinking...")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AIChatTheme.secondaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AIChatTheme.assistantBubble.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        } else {
            Text(message.text)
                .font(.body)
                .foregroundStyle(.primary)
                .lineSpacing(3)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(backgroundColor)
                .clipShape(bubbleShape)
                .overlay(
                    bubbleShape
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: AIChatTheme.shadow.opacity(0.45), radius: 8, x: 0, y: 4)
        }
    }

    private var backgroundColor: Color {
        switch message.role {
        case .user: return AIChatTheme.userBubble
        case .assistant: return AIChatTheme.assistantBubble
        }
    }

    private var bubbleShape: UnevenRoundedRectangle {
        if message.role == .user {
            return UnevenRoundedRectangle(cornerRadii: .init(topLeading: 16, bottomLeading: 16, bottomTrailing: 8, topTrailing: 16), style: .continuous)
        }

        return UnevenRoundedRectangle(cornerRadii: .init(topLeading: 16, bottomLeading: 8, bottomTrailing: 16, topTrailing: 16), style: .continuous)
    }
}

#Preview {
    VStack(spacing: 20) {
        ChatBubbleView(message: ChatMessage(role: .user, text: "Explain cloud cost tradeoffs."))
        ChatBubbleView(message: ChatMessage(role: .assistant, text: "Start by separating fixed and variable usage."))
    }
    .padding()
}
