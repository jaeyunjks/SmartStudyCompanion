import SwiftUI

struct StudyPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: StudyPlanViewModel

    @MainActor
    init(viewModel: StudyPlanViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    @MainActor
    init(workspaceTitle: String) {
        _viewModel = StateObject(wrappedValue: StudyPlanViewModel(workspaceTitle: workspaceTitle))
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            StudyPlanTheme.background
                .ignoresSafeArea()

            decorativeBackground

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if viewModel.isLoading {
                        ProgressView("Building your plan...")
                            .tint(StudyPlanTheme.accent)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if let plan = viewModel.studyPlan {
                        StudyPlanHeader(
                            workspaceName: plan.workspaceName,
                            completionText: viewModel.completionText,
                            topicBadge: plan.topicBadge,
                            supportiveMessage: plan.supportiveMessage,
                            progress: viewModel.completionValue
                        )

                        ForEach(plan.sections) { section in
                            StudyPlanSectionView(
                                section: section,
                                onToggleTask: { taskID in
                                    viewModel.toggleTask(sectionID: section.id, taskID: taskID)
                                },
                                onTapTask: { task in
                                    viewModel.taskTapped(task)
                                }
                            )
                        }

                        AITutorCard(onStartChat: {
                            viewModel.startChatTapped()
                        })
                        .padding(.top, 6)
                    } else {
                        Text(viewModel.errorMessage ?? "Unable to load study plan.")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 120)
            }
            .safeAreaInset(edge: .top) {
                StudyPlanTopBar(onBack: { dismiss() })
                    .padding(.top, 4)
            }

            StudyPlanFAB(action: {
                viewModel.floatingActionTapped()
            })
            .padding(.trailing, 22)
            .padding(.bottom, 28)
        }
        .task {
            if viewModel.studyPlan == nil {
                await viewModel.loadPlan()
            }
        }
        .confirmationDialog("Plan Actions", isPresented: $viewModel.showFabMenu) {
            Button("Add Task") {
                viewModel.taskActionMessage = "Add Task flow will be added in a future update."
                viewModel.showTaskActionAlert = true
            }
            Button("Regenerate Plan") {
                Task { await viewModel.loadPlan() }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Task Action", isPresented: $viewModel.showTaskActionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.taskActionMessage ?? "")
        }
        .alert("AI Tutor", isPresented: $viewModel.showStartChat) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Start Chat can navigate to AI Study Assistant in a future update.")
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var decorativeBackground: some View {
        GeometryReader { proxy in
            ZStack {
                Circle()
                    .fill(StudyPlanTheme.accentSoft.opacity(0.28))
                    .frame(width: 280)
                    .blur(radius: 80)
                    .position(x: -20, y: 90)

                Circle()
                    .fill(StudyPlanTheme.accent.opacity(0.08))
                    .frame(width: 340)
                    .blur(radius: 100)
                    .position(x: proxy.size.width + 30, y: proxy.size.height - 120)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}

#Preview {
    NavigationStack {
        StudyPlanView(workspaceTitle: "Linen & Moss")
    }
}
