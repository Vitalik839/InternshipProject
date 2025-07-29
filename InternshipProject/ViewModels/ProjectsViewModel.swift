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
        let dateDef = FieldDefinition(name: "Due date", type: .date)
        let textDef = FieldDefinition(name: "Text", type: .text)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        let card1 = Card(
            id: UUID(),
            title: "Implement new login screen",
            properties: [
                statusDef.id: .selection(TaskStatus.inProgress.rawValue),
                difficultyDef.id: .selection(Difficulty.hard.rawValue),
                tagsDef.id: .multiSelection(["Feature Request"]),
                dateDef.id: .date(formatter.date(from: "2025/08/13")!),
                textDef.id: .text("Деякий текст")
            ]
        )
        let card2 = Card(
            id: UUID(),
            title: "Fix crash on main screen",
            properties: [
                statusDef.id: .selection(TaskStatus.notStarted.rawValue),
                difficultyDef.id: .selection(Difficulty.medium.rawValue),
                tagsDef.id: .multiSelection(["Bug", "Self"]),
                dateDef.id: .date(formatter.date(from: "2025/10/22")!),
                textDef.id: .text("Особливий текст")
            ]
        )
        
        let card3 = Card(
            id: UUID(),
            title: "Refactor networking layer",
            properties: [
                statusDef.id: .selection(TaskStatus.done.rawValue),
                difficultyDef.id: .selection(Difficulty.easy.rawValue),
                dateDef.id: .date(formatter.date(from: "2025/04/09")!),
                textDef.id: .text("Просто текст")
            ]
        )
        let project1 = Project(
            name: "Tasks Tracker",
            fieldDefinitions: [statusDef, difficultyDef, tagsDef, dateDef, textDef],
            cards: [card1, card2, card3]
        )
        
        self.projects = [project1]
    }
}
