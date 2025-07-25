//
//  TaskBoardViewModel.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 12.07.2025.
//

import Foundation
import SwiftUI

@MainActor
final class CardViewModel: ObservableObject {
    enum Grouping: String, CaseIterable {
        case byStatus = "Status"
        case byDifficulty = "Difficulty"
        case byTag = "Tags"
    }
    @Published var project: Project
    
    @Published var grouping: Grouping = .byStatus
    @Published var searchText: String = ""
    @Published var projectDefinitions: [FieldDefinition]
    @Published var visibleCardPropertyIDs: Set<UUID> = []
    
    func toggleCardPropertyVisibility(id: UUID) {
        if visibleCardPropertyIDs.contains(id) {
            visibleCardPropertyIDs.remove(id)
        } else {
            visibleCardPropertyIDs.insert(id)
        }
    }
    func toggleVisibility(for cardID: UUID, definitionID: UUID) {
        guard let cardIndex = project.cards.firstIndex(where: { $0.id == cardID }) else {
            return
        }
        
        if project.cards[cardIndex].hiddenFieldIDs.contains(definitionID) {
            project.cards[cardIndex].hiddenFieldIDs.remove(definitionID)
        } else {
            project.cards[cardIndex].hiddenFieldIDs.insert(definitionID)
        }
    }
    
    init(project: Project) {
        self.project = project
        self.visibleCardPropertyIDs = Set(project.fieldDefinitions.map { $0.id })
        self.projectDefinitions = project.fieldDefinitions
    }
    
    func addNewCard(_ card: Card) {
        project.cards.append(card)
    }
    func deleteCard(_ cardToDelete: Card) {
        project.cards.removeAll { $0.id == cardToDelete.id }
    }
    
    func updateProperty(for cardID: UUID, definitionID: UUID, newValue: FieldValue) {
        guard let cardIndex = project.cards.firstIndex(where: { $0.id == cardID }) else { return }
        project.cards[cardIndex].properties[definitionID] = newValue
    }
    
    func addProperty(to cardID: UUID, with definition: FieldDefinition) {
        if !project.fieldDefinitions.contains(where: { $0.id == definition.id }) {
            project.fieldDefinitions.append(definition)
        }
        
        guard let cardIndex = project.cards.firstIndex(where: { $0.id == cardID }) else { return }
        project.cards[cardIndex].properties[definition.id] = getDefaultValue(for: definition.type)
    }
    
    func removeProperty(from cardID: UUID, with definitionID: UUID) {
        guard let cardIndex = project.cards.firstIndex(where: { $0.id == cardID }) else { return }
        
        project.cards[cardIndex].properties.removeValue(forKey: definitionID)
    }
    
    func getDefaultValue(for type: FieldType) -> FieldValue {
        switch type {
        case .text: return .text("")
        case .number: return .number(0)
        case .boolean: return .boolean(false)
        case .date: return .date(Date())
        case .selection: return .selection(nil)
        case .multiSelection: return .multiSelection([])
        case .url: return .url(nil)
        }
    }
    
    private var filteredCards: [Card] {
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
    
    func cards(for group: any GroupableProperty) -> [Card] {
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
    
    func handleDrop(of card: Card, on group: any GroupableProperty) {
        guard let cardIndex = project.cards.firstIndex(where: { $0.id == card.id }) else { return }
        guard let definition = project.fieldDefinitions.first(where: { $0.name == grouping.rawValue }) else { return }
        
        let newGroupValue = (group as? (any RawRepresentable))?.rawValue as? String ?? group.titleColumn
        
        withAnimation {
            project.cards[cardIndex].properties[definition.id] = .selection(newGroupValue)
        }
    }
}
