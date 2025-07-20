//
//  TaskBoardViewModel.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 12.07.2025.
//

import Foundation
import SwiftUI

@MainActor
final class TaskBoardViewModel: ObservableObject {
    enum Grouping: String, CaseIterable {
        case byStatus = "Status"
        case byDifficulty = "Difficulty"
        case byTag = "Tags"
    }
    @Published private(set) var project: Project
    
    @Published var grouping: Grouping = .byStatus
    @Published var searchText: String = ""
    @Published var projectDefinitions: [FieldDefinition]
    //@Published var allCards: [TaskCard] = []
    @Published var visibleDefinitionIDs: Set<UUID> = []
    @Published var visibleCardPropertyIDs: Set<UUID> = []
    
    func toggleCardPropertyVisibility(id: UUID) {
        if visibleCardPropertyIDs.contains(id) {
            visibleCardPropertyIDs.remove(id)
        } else {
            visibleCardPropertyIDs.insert(id)
        }
    }
    
    func hideDefinition(id: UUID) {
        visibleDefinitionIDs.remove(id)
    }
    
    init(project: Project) {
        self.project = project
        self.visibleCardPropertyIDs = Set(project.fieldDefinitions.map { $0.id })
        self.projectDefinitions = project.fieldDefinitions
        self.visibleDefinitionIDs = Set(project.fieldDefinitions.map { $0.id })

        //self.setupMockData()
    }
    
//    private func setupMockData() {
//        let statusDef = FieldDefinition(name: "Status", type: .selection, selectionOptions: TaskStatus.allCases.map(\.rawValue))
//        let difficultyDef = FieldDefinition(name: "Difficulty", type: .selection, selectionOptions: Difficulty.allCases.map(\.rawValue))
//        let tagsDef = FieldDefinition(name: "Tags", type: .multiSelection,
//                                      selectionOptions: ["Polish", "Bug", "Feature Request", "Self", "Tech"])
//        let effortDef = FieldDefinition(name: "Effort", type: .number)
//        
//        // Зберігаємо шаблони у ViewModel
//        //self.projectDefinitions = [statusDef, difficultyDef, tagsDef, effortDef]
//        
//        let card1 = TaskCard(
//            id: UUID(),
//            title: "Implement new login screen",
//            properties: [
//                statusDef.id: .selection(TaskStatus.inProgress.rawValue),
//                difficultyDef.id: .selection("Hard"),
//                tagsDef.id: .multiSelection(["Feature Request"]),
//                effortDef.id: .number(8)
//            ]
//        )
//        
//        let card2 = TaskCard(
//            id: UUID(),
//            title: "Fix crash on main screen",
//            properties: [
//                statusDef.id: .selection(TaskStatus.notStarted.rawValue),
//                difficultyDef.id: .selection("Medium"),
//                tagsDef.id: .multiSelection(["Bug", "Self"]),
//                effortDef.id: .number(5)
//            ]
//        )
//        
//        let card3 = TaskCard(
//            id: UUID(),
//            title: "Refactor networking layer",
//            properties: [
//                statusDef.id: .selection(TaskStatus.done.rawValue),
//                difficultyDef.id: .selection("Hard"),
//                // Ця картка не має тегу, це нормально
//            ]
//        )
//        self.visibleDefinitionIDs = Set(self.projectDefinitions.map { $0.id })
//        self.visibleCardPropertyIDs = Set(self.projectDefinitions.map { $0.id })
//        self.allCards = [card1, card2, card3]
//        project.cards.append(card1)
//        project.cards.append(card2)
//        project.cards.append(card3)
//    }
    
    func addNewCard(_ card: TaskCard) {
        project.cards.append(card)
    }
    
    func updateProperty(for cardID: UUID, definitionID: UUID, newValue: FieldValue) {
        guard let cardIndex = project.cards.firstIndex(where: { $0.id == cardID }) else { return }
        project.cards[cardIndex].properties[definitionID] = newValue
    }
    
    func createNewFieldDefinition(name: String, type: FieldType) -> FieldDefinition {
        let newDefinition = FieldDefinition(name: name, type: type)
        projectDefinitions.append(newDefinition)
        return newDefinition
    }
    
    private var filteredCards: [TaskCard] {
        if searchText.isEmpty {
            return project.cards
        } else {
            return project.cards.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var currentGroupKeys: [any GroupableProperty] {
        guard let definition = project.fieldDefinitions.first(where: { $0.name == grouping.rawValue }) else {
            return []
        }
        switch grouping {
        case .byStatus:
            return TaskStatus.allCases
        case .byDifficulty:
            return Difficulty.allCases
        case .byTag:
            return definition.selectionOptions ?? []
        }
    }
    
    func cards(for group: any GroupableProperty) -> [TaskCard] {
        guard let definition = project.fieldDefinitions.first(where: { $0.name == grouping.rawValue }) else {
            return []
        }
        
        let groupKey = (group as? (any RawRepresentable))?.rawValue as? String ?? group.titleColumn
        
        return filteredCards.filter { card in
            if let fieldValue = card.properties[definition.id] {
                if case .selection(let option) = fieldValue, option == groupKey {
                    return true
                }
            }
            return false
        }
    }
    
    func handleDrop(of card: TaskCard, on group: any GroupableProperty) {
        guard let cardIndex = project.cards.firstIndex(where: { $0.id == card.id }) else { return }
        guard let definition = project.fieldDefinitions.first(where: { $0.name == grouping.rawValue }) else { return }
        
        let newGroupValue = (group as? (any RawRepresentable))?.rawValue as? String ?? group.titleColumn
        
        withAnimation {
            project.cards[cardIndex].properties[definition.id] = .selection(newGroupValue)
        }
    }
}
