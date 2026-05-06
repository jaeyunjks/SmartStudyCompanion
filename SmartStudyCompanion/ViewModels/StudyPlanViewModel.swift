import Foundation
import SwiftUI
import Combine

@MainActor
final class StudyPlanViewModel: ObservableObject {
    @Published var studyPlan: StudyPlan?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var taskActionMessage: String?
    @Published var showTaskActionAlert = false
    @Published var showStartChat = false
    @Published var showFabMenu = false

    private let service: StudyPlanServiceProtocol
    private let request: StudyPlanGenerationRequest

    init(service: StudyPlanServiceProtocol, request: StudyPlanGenerationRequest) {
        self.service = service
        self.request = request
    }

    convenience init(workspaceTitle: String) {
        self.init(
            service: MockStudyPlanService(),
            request: StudyPlanGenerationRequest(
                workspaceTitle: workspaceTitle,
                sourceSummaryIDs: [],
                sourceQuizIDs: [],
                sourceFlashcardIDs: [],
                weaknessAreas: ["service models", "deployment patterns"]
            )
        )
    }

    var completionText: String {
        guard let studyPlan else { return "0% Complete" }
        return "\(Int((studyPlan.completionPercentage * 100).rounded()))% Complete"
    }

    var completionValue: Double {
        studyPlan?.completionPercentage ?? 0
    }

    var completedTaskCount: Int {
        studyPlan?.completedTaskCount ?? 0
    }

    var totalTaskCount: Int {
        studyPlan?.totalTaskCount ?? 0
    }

    func loadPlan() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await service.generateStudyPlan(request: request)
            withAnimation(.easeInOut(duration: 0.25)) {
                studyPlan = response.plan
            }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Could not load study plan."
        }

        isLoading = false
    }

    func toggleTask(sectionID: UUID, taskID: UUID) {
        guard var plan = studyPlan else { return }

        guard let sectionIndex = plan.sections.firstIndex(where: { $0.id == sectionID }),
              let taskIndex = plan.sections[sectionIndex].tasks.firstIndex(where: { $0.id == taskID })
        else { return }

        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            plan.sections[sectionIndex].tasks[taskIndex].status =
                plan.sections[sectionIndex].tasks[taskIndex].isCompleted ? .pending : .completed
            studyPlan = plan
        }
    }

    func startChatTapped() {
        showStartChat = true
    }

    func floatingActionTapped() {
        showFabMenu = true
    }

    func taskTapped(_ task: StudyTask) {
        taskActionMessage = destinationMessage(for: task.destination)
        showTaskActionAlert = true
    }

    private func destinationMessage(for destination: StudyTaskDestination) -> String {
        switch destination {
        case .summary: return "This task can open Summary in a future update."
        case .quiz: return "This task can open Quiz in a future update."
        case .flashcards: return "This task can open Flashcards in a future update."
        case .aiChat: return "This task can open AI Chat in a future update."
        case .none: return "No linked feature yet."
        }
    }
}
