import SwiftUI

struct QuizOptionCard: View {
    let option: QuizOption
    let isSelected: Bool
    let hasCheckedAnswer: Bool
    let isCorrectOption: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(badgeBackground)
                        .frame(width: 44, height: 44)

                    Text(option.label)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(badgeForeground)
                }

                Text(option.text)
                    .font(.system(size: 18, weight: textWeight))
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 8)

                if trailingIconName != nil {
                    Image(systemName: trailingIconName ?? "")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(trailingIconColor)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: QuizTheme.shadow, radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .disabled(hasCheckedAnswer)
    }

    private var backgroundColor: Color {
        if hasCheckedAnswer && isCorrectOption {
            return QuizTheme.accentSoft.opacity(0.50)
        }
        if hasCheckedAnswer && isSelected && !isCorrectOption {
            return QuizTheme.error.opacity(0.10)
        }
        if isSelected {
            return QuizTheme.accentSoft.opacity(0.42)
        }
        return QuizTheme.surface
    }

    private var borderColor: Color {
        if hasCheckedAnswer && isCorrectOption {
            return QuizTheme.accent
        }
        if hasCheckedAnswer && isSelected && !isCorrectOption {
            return QuizTheme.error
        }
        if isSelected {
            return QuizTheme.accent
        }
        return .clear
    }

    private var borderWidth: CGFloat {
        isSelected || (hasCheckedAnswer && isCorrectOption) ? 2 : 1
    }

    private var badgeBackground: Color {
        if hasCheckedAnswer && isCorrectOption {
            return QuizTheme.accent
        }
        if hasCheckedAnswer && isSelected && !isCorrectOption {
            return QuizTheme.error.opacity(0.9)
        }
        if isSelected {
            return QuizTheme.accent
        }
        return QuizTheme.surfaceStrong
    }

    private var badgeForeground: Color {
        if isSelected || (hasCheckedAnswer && isCorrectOption) {
            return .white
        }
        return .secondary
    }

    private var textColor: Color {
        if hasCheckedAnswer && isCorrectOption {
            return QuizTheme.accent
        }
        return .primary
    }

    private var textWeight: Font.Weight {
        isSelected ? .semibold : .medium
    }

    private var trailingIconName: String? {
        if hasCheckedAnswer && isCorrectOption {
            return "checkmark.circle.fill"
        }
        if hasCheckedAnswer && isSelected && !isCorrectOption {
            return "xmark.circle.fill"
        }
        if isSelected {
            return "checkmark.circle"
        }
        return nil
    }

    private var trailingIconColor: Color {
        if hasCheckedAnswer && isSelected && !isCorrectOption {
            return QuizTheme.error
        }
        return QuizTheme.accent
    }
}

#Preview {
    QuizOptionCard(
        option: QuizOption(label: "A", text: "On-demand self-service"),
        isSelected: true,
        hasCheckedAnswer: false,
        isCorrectOption: true,
        onTap: {}
    )
    .padding()
}
