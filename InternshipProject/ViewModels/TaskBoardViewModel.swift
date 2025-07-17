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
    @Published var grouping: Grouping = .byStatus
    @Published var searchText: String = ""
    @Published var projectDefinitions: [FieldDefinition] = []
    @Published var allCards: [TaskCard] = []
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
    
    init() {
        setupMockData()
    }
    
    private func setupMockData() {
        // Створюємо шаблони для полів, які будуть у всіх карток
        let statusDef = FieldDefinition(name: "Status", type: .selection, selectionOptions: TaskStatus.allCases.map(\.rawValue))
        let difficultyDef = FieldDefinition(name: "Difficulty", type: .selection, selectionOptions: Difficulty.allCases.map(\.rawValue))
        let tagsDef = FieldDefinition(name: "Tags", type: .multiSelection,
                                      selectionOptions: ["Polish", "Bug", "Feature Request", "Self", "Tech"])
        let effortDef = FieldDefinition(name: "Effort", type: .number)
        
        // Зберігаємо шаблони у ViewModel
        self.projectDefinitions = [statusDef, difficultyDef, tagsDef, effortDef]
        
        let card1 = TaskCard(
            id: UUID(),
            title: "Implement new login screen",
            properties: [
                statusDef.id: .selection(TaskStatus.inProgress.rawValue),
                difficultyDef.id: .selection("Hard"),
                tagsDef.id: .multiSelection(["Feature Request"]),
                effortDef.id: .number(8)
            ]
        )
        
        let card2 = TaskCard(
            id: UUID(),
            title: "Fix crash on main screen",
            properties: [
                statusDef.id: .selection(TaskStatus.notStarted.rawValue),
                difficultyDef.id: .selection("Medium"),
                tagsDef.id: .multiSelection(["Bug", "Self"]),
                effortDef.id: .number(5)
            ]
        )
        
        let card3 = TaskCard(
            id: UUID(),
            title: "Refactor networking layer",
            properties: [
                statusDef.id: .selection(TaskStatus.done.rawValue),
                difficultyDef.id: .selection("Hard"),
                // Ця картка не має тегу, це нормально
            ]
        )
        self.visibleDefinitionIDs = Set(self.projectDefinitions.map { $0.id })
        self.visibleCardPropertyIDs = Set(self.projectDefinitions.map { $0.id })
        self.allCards = [card1, card2, card3]
    }
    
    func addNewCard(_ card: TaskCard) {
        allCards.append(card)
    }
    
    func updateProperty(for cardID: UUID, definitionID: UUID, newValue: FieldValue) {
        guard let cardIndex = allCards.firstIndex(where: { $0.id == cardID }) else { return }

        allCards[cardIndex].properties[definitionID] = newValue
    }
    
    func createNewFieldDefinition(name: String, type: FieldType) -> FieldDefinition {
        let newDefinition = FieldDefinition(name: name, type: type)
        projectDefinitions.append(newDefinition)
        return newDefinition
    }
    
    private var filteredCards: [TaskCard] {
        if searchText.isEmpty {
            return allCards
        } else {
            return allCards.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var currentGroupKeys: [any GroupableProperty] {
        // 1. Знаходимо визначення для поточного групування (напр., FieldDefinition з ім'ям "Status")
        guard let definition = projectDefinitions.first(where: { $0.name == grouping.rawValue }) else {
            return []
        }
        
        return definition.selectionOptions ?? []
    }
    
    func cards(for group: any GroupableProperty) -> [TaskCard] {
        if let status = group as? TaskStatus {
            // Знаходимо визначення поля "Status"
            guard let statusDef = projectDefinitions.first(where: { $0.name == "Status" }) else { return [] }

            return filteredCards.filter { card in
                if case .selection(let option) = card.properties[statusDef.id] {
                    return option == status.rawValue
                }
                return false
            }
        }
        guard let definition = projectDefinitions.first(where: { $0.name == grouping.rawValue }),
              let groupKey = group as? String else {
            return []
        }

        return filteredCards.filter { card in
            // Знаходимо значення для нашого поля у властивостях картки
            if let fieldValue = card.properties[definition.id] {
                // Перевіряємо, чи збігається значення з ключем групи
                if case .selection(let option) = fieldValue, option == groupKey {
                    return true
                }
            }
            return false
        }
    }
    
    func handleDrop(of card: TaskCard, on group: any GroupableProperty) {
        guard let cardIndex = allCards.firstIndex(where: { $0.id == card.id }) else { return }
        
        // Перевіряємо, чи передали нам конкретний енум TaskStatus
        if let newStatus = group as? TaskStatus {
            guard let statusDef = projectDefinitions.first(where: { $0.name == "Status" }) else { return }
            withAnimation {
                // Оновлюємо значення у словнику properties
                allCards[cardIndex].properties[statusDef.id] = .selection(newStatus.rawValue)
            }
        }
    }
}
