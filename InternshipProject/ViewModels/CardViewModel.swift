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
    @Published var project: Project
    
    @Published var searchText: String = ""
    @Published var projectDefinitions: [FieldDefinition]
    @Published var visibleCardPropertyIDs: Set<UUID> = []
    @Published var groupingFieldID: UUID?
    @Published var activeFilters: [UUID: FilterType] = [:]
    @Published var activeSortRule: SortRule?

    var groupableFields: [FieldDefinition] {
        project.fieldDefinitions.filter {
            $0.type == .selection || $0.type == .multiSelection  || $0.type == .date
        }
    }
    
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
        
        self.groupingFieldID = project.fieldDefinitions.first(where: {
            $0.type == .selection || $0.type == .multiSelection || $0.type == .date
                })?.id
    }
    
    public var filteredCards: [Card] {
        var cards = project.cards
        
        if !searchText.isEmpty {
            cards = cards.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        guard !activeFilters.isEmpty else { return cards }
        
        cards = cards.filter { card in
            for (fieldID, filter) in activeFilters {
                let propertyValue = card.properties[fieldID]
                guard let propertyValue = card.properties[fieldID] else {
                    return false
                }
                if !isCardSatisfyingRule(propertyValue: propertyValue, filter: filter) {
                    return false
                }
            }
            return true
        }
        guard let sortRule = activeSortRule,
              let sortField = project.fieldDefinitions.first(where: { $0.id == sortRule.fieldID })
        else {
            return cards
        }
        
        cards.sort { card1, card2 in
            let value1 = card1.properties[sortRule.fieldID]
            let value2 = card2.properties[sortRule.fieldID]
            
            let result = compare(value1, and: value2, for: sortField.type)
            
            return sortRule.direction == .ascending ? result : !result
        }
        
        return cards
    }
    
    private func isCardSatisfyingRule(propertyValue: FieldValue?, filter: FilterType) -> Bool {
        if filter == .isNotEmpty {
            return propertyValue != nil
        }
        guard let propertyValue = propertyValue else {
            return false
        }
        
        switch (filter, propertyValue) {
            
        case (.textContains(let searchText), .text(let cardText)):
            if searchText.isEmpty { return false }
            return cardText.localizedCaseInsensitiveContains(searchText)
            
        case (.numberRange(let start, let end), .number(let cardNum)):
            let isAfterStart = (start == nil) || (cardNum >= start!)
            let isBeforeEnd = (end == nil) || (cardNum <= end!)
            return isAfterStart && isBeforeEnd
            
        case (.dateRange(let start, let end), .date(let optionalCardDate)):
            
            let isAfterStart = (start == nil) || (Calendar.current.compare(optionalCardDate, to: start!, toGranularity: .day) != .orderedAscending)
            let isBeforeEnd = (end == nil) || (Calendar.current.compare(optionalCardDate, to: end!, toGranularity: .day) != .orderedDescending)
            
            return isAfterStart && isBeforeEnd
            
        case (.selectionContains(let selectedOptions), .selection(let cardOption)):
            guard let cardOption = cardOption else { return false }
            return selectedOptions.contains(cardOption)
            
        case (.selectionContains(let selectedOptions), .multiSelection(let cardTags)):
            return !Set(cardTags).isDisjoint(with: selectedOptions)
            
        case (.isNotEmpty, .url(let url)):
            return url != nil
            
        default:
            return false
        }
    }
    
    func setFilter(_ filter: FilterType?, for fieldID: UUID) {
        if filter == nil {
            activeFilters.removeValue(forKey: fieldID)
        } else {
            activeFilters[fieldID] = filter
        }
    }
    
    func clearAllFilters() {
        activeFilters.removeAll()
    }
    
    private func compare(_ v1: FieldValue?, and v2: FieldValue?, for type: FieldType) -> Bool {
        if v1 == nil && v2 != nil { return false }
        if v1 != nil && v2 == nil { return true }
        guard let v1 = v1, let v2 = v2 else { return false }
        
        switch (v1, v2) {
        case (.text(let t1), .text(let t2)):
            return t1 < t2
        case (.number(let n1), .number(let n2)):
            return n1 < n2
        case (.date(let d1), .date(let d2)):
            return d1 < d2
        case (.selection(let .some(s1)), .selection(let .some(s2))):
            return s1 < s2
        case (.url(let .some(url1)), .url(let .some(url2))):
            return url1.absoluteString < url2.absoluteString
        case (.boolean(let b1), .boolean(let b2)):
            return b1 == false && b2 == true
            
        default: return false
            
        }
    }
    
    func setSort(by fieldID: UUID) {
        if activeSortRule?.fieldID == fieldID {
            activeSortRule?.direction = (activeSortRule?.direction == .ascending) ? .descending : .ascending
        } else {
            activeSortRule = SortRule(fieldID: fieldID, direction: .ascending)
        }
    }

    func clearSort() {
        activeSortRule = nil
    }
    
    func addNewCard(_ card: Card) {
        project.cards.append(card)
    }
    func deleteCard(_ cardToDelete: Card) {
        project.cards.removeAll { $0.id == cardToDelete.id }
    }
    
    func createQuickCard(in groupKey: String) {
        guard let fieldID = groupingFieldID else { return }
        
        var newCard = Card(id: UUID(), title: "New Task", properties: [:])
        newCard.properties[fieldID] = .selection(groupKey)
        
        project.cards.append(newCard)
    }

    func updateProperty(for cardID: UUID, definitionID: UUID, newValue: FieldValue) {
        guard let cardIndex = project.cards.firstIndex(where: { $0.id == cardID }) else { return }
        project.cards[cardIndex].properties[definitionID] = newValue
    }
    
    func findOrCreateDefinition(from potentialDefinition: FieldDefinition) -> FieldDefinition {
        if let existingDefinition = project.fieldDefinitions.first(where: { $0.name == potentialDefinition.name }) {
            return existingDefinition
        } else {
            project.fieldDefinitions.append(potentialDefinition)
            return potentialDefinition
        }
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
    
    var currentGroupKeys: [String] {
        guard let fieldID = groupingFieldID,
              let definition = project.fieldDefinitions.first(where: { $0.id == fieldID })
        else { return [] }
        
        if definition.type == .selection || definition.type == .multiSelection {
            return definition.selectionOptions ?? []
        }
        
        // групування за датою)
        
        return []
    }
    
    func cards(for groupKey: String) -> [Card] {
        guard let fieldID = groupingFieldID,
              let definition = project.fieldDefinitions.first(where: { $0.id == fieldID })
        else { return [] }
        
        return filteredCards.filter { card in
            if let fieldValue = card.properties[definition.id] {
                switch fieldValue {
                case .selection(let option):
                    return option == groupKey
                case .multiSelection(let tags):
                    return tags.contains(groupKey)
                case .date(let date):
                    let calendar = Calendar.current
                    let year = calendar.component(.year, from: date)
                    return String(year) == groupKey
                default:
                    return false
                }
            }
            return false
        }
    }
    
    func handleDrop(of card: Card, on groupKey: String) {
        guard let cardIndex = project.cards.firstIndex(where: { $0.id == card.id }),
              let fieldID = groupingFieldID
        else { return }
        
        withAnimation {
            project.cards[cardIndex].properties[fieldID] = .selection(groupKey)
        }
    }
}
