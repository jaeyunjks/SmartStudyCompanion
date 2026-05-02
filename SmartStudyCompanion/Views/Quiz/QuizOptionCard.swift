import SwiftUI

struct QuizOptionCard: View {
    @Environment(\.quizPalette) private var palette

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
            .shadow(color: palette.shadow, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(hasCheckedAnswer)
    }

    private var backgroundColor: Color {
        if hasCheckedAnswer && isCorrectOption {
            return palette.accentSoft.opacity(0.55)
        }
        if hasCheckedAnswer && isSelected && !isCorrectOption {
            return palette.error.opacity(0.12)
        }
        if isSelected {
            return palette.accentSoft.opacity(0.42)
        }
        return palette.surface
    }

    private var borderColor: Color {
        if hasCheckedAnswer && isCorrectOption {
            return palette.accent
        }
        if hasCheckedAnswer && isSelected && !isCorrectOption {
            return palette.error
        }
        if isSelected {
            return palette.accent
        }
        return palette.border
    }

    private var borderWidth: CGFloat {
        isSelected || (hasCheckedAnswer && isCorrectOption) ? 2 : 1
    }

    private var badgeBackground: Color {
        if hasCheckedAnswer && isCorrectOption {
            return palette.accent
        }
        if hasCheckedAnswer && isSelected && !isCorrectOption {
            return palette.error.opacity(0.9)
        }
        if isSelected {
            return palette.accent
        }
        return palette.surfaceStrong
    }

    private var badgeForeground: Color {
        if isSelected || (hasCheckedAnswer && isCorrectOption) {
            return .white
        }
        return .secondary
    }

    private var textColor: Color {
        if hasCheckedAnswer && isCorrectOption {
            return palette.accent
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
            return palette.error
        }
        return palette.accent
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