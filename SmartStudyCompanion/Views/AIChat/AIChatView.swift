import SwiftUI

struct AIChatView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AIChatViewModel

    @MainActor
    init(viewModel: AIChatViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    @MainActor
    init() {
        _viewModel = StateObject(wrappedValue: AIChatViewModel())
    }

    var body: some View {
        ZStack {
            AIChatTheme.background.ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        dayDivider

                        modeBadge

                        ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                            ChatBubbleView(message: message)
                                .id(message.id)

                            if index == 1 {
                                ContextCardView(context: viewModel.selectedContext)
                                    .padding(.vertical, 6)
                            }
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(.red)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.red.opacity(0.08))
                                .clipShape(Capsule())
                                .frame(maxWidth: .infinity, alignment: .center)
                        }

                        Color.clear
                            .frame(height: 8)
                            .id("bottom-anchor")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 90)
                }
                .safeAreaInset(edge: .top) {
                    topBar
                }
                .safeAreaInset(edge: .bottom) {
                    bottomInput
                }
                .onAppear {
                    scrollToBottom(proxy)
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    scrollToBottom(proxy)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var topBar: some View {
        HStack {
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AIChatTheme.accent)
                        .frame(width: 36, height: 36)
                        .background(AIChatTheme.accentSoft.opacity(0.8))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Text("AI Study Assistant")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(AIChatTheme.accent)
            }

            Spacer()

            Circle()
                .fill(AIChatTheme.accentSoft)
                .frame(width: 30, height: 30)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AIChatTheme.accent)
                }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(AIChatTheme.background.opacity(0.85))
        .background(.ultraThinMaterial)
    }

    private var dayDivider: some View {
        HStack {
            Text("Today")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AIChatTheme.secondaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(AIChatTheme.accentSoft.opacity(0.55))
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
    }

    private var modeBadge: some View {
        Text("Mode: \(viewModel.selectedMode.displayName)")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(AIChatTheme.accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(AIChatTheme.accentSoft.opacity(0.6))
            .clipShape(Capsule())
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var bottomInput: some View {
        VStack(spacing: 10) {
            ChatInputBar(
                text: $viewModel.inputText,
                isLoading: viewModel.isLoading,
                onAttach: {
                    viewModel.errorMessage = "Attachment support can be added next."
                },
                onSend: viewModel.sendCurrentMessage
            )

            SuggestedPromptChips(prompts: viewModel.suggestedPrompts) { prompt in
                viewModel.sendSuggestedPrompt(prompt)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(
            LinearGradient(
                colors: [AIChatTheme.background.opacity(0), AIChatTheme.background],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.25)) {
            proxy.scrollTo("bottom-anchor", anchor: .bottom)
        }
    }
}

#Preview {
    NavigationStack {
        AIChatView()
    }
}
