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
    
    
    init(project: Project) {
        self.project = project
        self.visibleCardPropertyIDs = Set(project.fieldDefinitions.map { $0.id })
        self.projectDefinitions = project.fieldDefinitions
    }
    
    func addNewCard(_ card: Card) {
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
