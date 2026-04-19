import SwiftUI

struct AssistantHeaderView: View {
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(AIChatTheme.accentSoft)
                .frame(width: 24, height: 24)
                .overlay {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AIChatTheme.accent)
                }

            Text("Assistant")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(AIChatTheme.accent)
        }
    }
}

#Preview {
    AssistantHeaderView()
}
