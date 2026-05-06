import SwiftUI

struct StudyPlanSectionView: View {
    let section: StudyPlanSection
    let onToggleTask: (UUID) -> Void
    let onTapTask: (StudyTask) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(section.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(StudyPlanTheme.accent)

                Text("\(section.tasks.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(StudyPlanTheme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(StudyPlanTheme.accentSoft.opacity(0.75))
                    .clipShape(Capsule())

                Spacer()
            }

            VStack(spacing: 4) {
                ForEach(section.tasks) { task in
                    StudyTaskRow(
                        task: task,
                        onToggle: { onToggleTask(task.id) },
                        onTap: { onTapTask(task) }
                    )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(StudyPlanTheme.surface)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(StudyPlanTheme.accent.opacity(0.10), lineWidth: 1)
            )
            .shadow(color: StudyPlanTheme.shadow, radius: 10, x: 0, y: 6)
        }
    }
}

#Preview {
    StudyPlanSectionView(
        section: StudyPlanSection(
            title: "Understand",
            tasks: [
                StudyTask(title: "Summarize notes", estimatedDurationMinutes: 10, recommendedOrder: 1),
                StudyTask(title: "Review diagrams", estimatedDurationMinutes: 12, recommendedOrder: 2)
            ]
        ),
        onToggleTask: { _ in },
        onTapTask: { _ in }
    )
    .padding()
}
