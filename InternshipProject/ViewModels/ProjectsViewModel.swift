//
//  ProjectViewModel.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 18.07.2025.
//

import Foundation

@MainActor
class ProjectsViewModel: ObservableObject {
    @Published var projects: [Project] = []

    init() {
        loadMockProjects()
    }

    func addProject(_ project: Project) {
        projects.append(project)
    }

    func deleteProject(at offsets: IndexSet) {
        projects.remove(atOffsets: offsets)
    }

    private func loadMockProjects() {
        let statusDef = FieldDefinition(name: "Status", type: .selection, selectionOptions: TaskStatus.allCases.map(\.rawValue))
        let difficultyDef = FieldDefinition(name: "Difficulty", type: .selection, selectionOptions: Difficulty.allCases.map(\.rawValue))
        let tagsDef = FieldDefinition(name: "Tags", type: .multiSelection,
                                      selectionOptions: ["Polish", "Bug", "Feature Request", "Self", "Tech"])
        let effortDef = FieldDefinition(name: "Effort", type: .number)
        
        let card1 = TaskCard(
            id: UUID(),
            title: "Implement new login screen",
            properties: [
                statusDef.id: .selection(TaskStatus.inProgress.rawValue),
                difficultyDef.id: .selection(Difficulty.hard.rawValue),
                tagsDef.id: .multiSelection(["Feature Request"]),
                effortDef.id: .number(8)
            ]
        )
        let card2 = TaskCard(
            id: UUID(),
            title: "Fix crash on main screen",
            properties: [
                statusDef.id: .selection(TaskStatus.notStarted.rawValue),
                difficultyDef.id: .selection(Difficulty.medium.rawValue),
                tagsDef.id: .multiSelection(["Bug", "Self"]),
                effortDef.id: .number(5)
            ]
        )
        
        let card3 = TaskCard(
            id: UUID(),
            title: "Refactor networking layer",
            properties: [
                statusDef.id: .selection(TaskStatus.done.rawValue),
                difficultyDef.id: .selection(Difficulty.easy.rawValue)
            ]
        )
        let project1 = Project(
            name: "Tasks Tracker",
            fieldDefinitions: [statusDef, difficultyDef, tagsDef],
            cards: [card1, card2, card3]
        )
        
        self.projects = [project1]
    }
}
