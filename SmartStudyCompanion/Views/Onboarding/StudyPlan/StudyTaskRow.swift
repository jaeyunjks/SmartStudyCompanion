import SwiftUI

struct StudyTaskRow: View {
    let task: StudyTask
    let onToggle: () -> Void
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Button(action: onToggle) {
                    ZStack {
                        Circle()
                            .stroke(task.isCompleted ? StudyPlanTheme.accent : StudyPlanTheme.mutedText.opacity(0.5), lineWidth: 1.5)
                            .frame(width: 24, height: 24)

                        if task.isCompleted {
                            Circle()
                                .fill(StudyPlanTheme.accent)
                                .frame(width: 18, height: 18)
                                .overlay {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                        }
                    }
                }
                .buttonStyle(.plain)

                Text(task.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(task.isCompleted ? StudyPlanTheme.mutedText : .primary)
                    .strikethrough(task.isCompleted)
                    .opacity(task.isCompleted ? 0.68 : 1)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 8)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StudyTaskRow(
        task: StudyTask(title: "Summarize key topics", estimatedDurationMinutes: 10, recommendedOrder: 1),
        onToggle: {},
        onTap: {}
    )
    .padding()
}
