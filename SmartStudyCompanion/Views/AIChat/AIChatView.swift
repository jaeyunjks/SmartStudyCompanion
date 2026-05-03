import SwiftUI

struct AIChatView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel: AIChatViewModel
    @State private var showConversations = false
    @State private var renameConversationID: UUID?
    @State private var renameDraft = ""

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
                    VStack(spacing: 14) {
                        if viewModel.messages.isEmpty {
                            VStack {
                                Spacer(minLength: 0)
                                Text("Hey! how can i help you?")
                                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.primary)
                                Spacer(minLength: 0)
                            }
                            .frame(maxWidth: .infinity, minHeight: 520)
                            .transition(.opacity)
                        }

                        ForEach(viewModel.messages) { message in
                            ChatBubbleView(
                                message: message,
                                onRegenerate: {
                                    viewModel.regenerateFromAssistantMessage(message.id)
                                }
                            )
                                .id(message.id)
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(.red)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.red.opacity(0.10))
                                .clipShape(Capsule())
                        }

                        Color.clear
                            .frame(height: 8)
                            .id("bottom-anchor")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 90)
                    .id(viewModel.activeConversationID)
                    .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .trailing)), removal: .opacity))
                    .animation(.easeInOut(duration: 0.22), value: viewModel.activeConversationID)
                }
                .safeAreaInset(edge: .top) {
                    topBar
                }
                .safeAreaInset(edge: .bottom) {
                    bottomInput
                }
                .onAppear {
                    viewModel.ensureCleanLandingIfNeeded()
                    scrollToBottom(proxy)
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    scrollToBottom(proxy)
                }
            }
        }
        .sheet(isPresented: $showConversations) {
            conversationsSheet
        }
        .alert("Rename Conversation", isPresented: Binding(
            get: { renameConversationID != nil },
            set: { newValue in
                if !newValue { renameConversationID = nil }
            }
        )) {
            TextField("Conversation title", text: $renameDraft)
            Button("Save") {
                if let id = renameConversationID {
                    viewModel.renameConversation(id, title: renameDraft)
                }
                renameConversationID = nil
            }
            Button("Cancel", role: .cancel) {
                renameConversationID = nil
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 34, height: 34)
                    .background(AIChatTheme.surfaceSecondary)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Text(viewModel.messages.isEmpty ? "Lumora AI" : currentConversationTitle)
                .font(.system(size: 17, weight: .semibold))
                .lineLimit(1)

            Spacer()

            Button(action: {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
                    viewModel.startNewConversation()
                }
            }) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 34, height: 34)
                    .background(AIChatTheme.surfaceSecondary)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Button(action: { showConversations = true }) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 34, height: 34)
                    .background(AIChatTheme.surfaceSecondary)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(AIChatTheme.background.opacity(colorScheme == .dark ? 0.95 : 0.90))
        .overlay(alignment: .bottom) {
            Divider().opacity(0.2)
        }
    }

    private var bottomInput: some View {
        VStack(spacing: 10) {
            let mentions = viewModel.filteredMentionSuggestions()
            if !mentions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(mentions, id: \.materialID) { material in
                            Button {
                                viewModel.insertMention(material)
                            } label: {
                                Text("@\(material.title)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AIChatTheme.accent)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(AIChatTheme.accentSoft.opacity(0.9))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }

            ChatInputBar(
                text: $viewModel.inputText,
                isLoading: viewModel.isLoading,
                onMentionTap: {
                    if viewModel.inputText.isEmpty {
                        viewModel.inputText = "@"
                    } else if viewModel.inputText.hasSuffix("@") {
                        return
                    } else if viewModel.inputText.hasSuffix(" ") {
                        viewModel.inputText += "@"
                    } else {
                        viewModel.inputText += " @"
                    }
                },
                onSend: viewModel.sendCurrentMessage
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(
            LinearGradient(
                colors: [AIChatTheme.background.opacity(0), AIChatTheme.background],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var conversationsSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent chats")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)

                    ForEach(viewModel.conversations) { conversation in
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(AIChatTheme.surfaceSecondary)
                                .frame(width: 34, height: 34)
                                .overlay {
                                    Image(systemName: "message")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(AIChatTheme.accent)
                                }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(conversation.title)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text(conversation.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Menu {
                                Button("Rename") {
                                    renameConversationID = conversation.id
                                    renameDraft = conversation.title
                                }

                                Button("Delete", role: .destructive) {
                                    viewModel.deleteConversation(conversation.id)
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 28, height: 28)
                                    .background(AIChatTheme.surfaceSecondary)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(12)
                        .background(AIChatTheme.surfaceSecondary.opacity(0.72))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.22)) {
                                viewModel.selectConversation(conversation.id)
                            }
                            showConversations = false
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(AIChatTheme.background)
            .navigationTitle("Recents")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New") {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
                            viewModel.startNewConversation()
                        }
                        showConversations = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var currentConversationTitle: String {
        viewModel.conversations.first(where: { $0.id == viewModel.activeConversationID })?.title ?? "Conversation"
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
