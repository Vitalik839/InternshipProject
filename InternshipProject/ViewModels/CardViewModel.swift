//
//  TaskBoardViewModel.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 12.07.2025.
//

import Foundation
import SwiftUI
import Combine
import SwiftData

@MainActor
final class CardViewModel: ObservableObject {
    private var modelContext: ModelContext

    @Published var searchText: String = ""
    @Published var activeFilters: [UUID: FilterType] = [:]
    @Published var activeSortRule: SortRule?
    @Published var visibleCardPropertyIDs: Set<UUID> = []
    
    @Published var selectedViewID: UUID? {
        didSet {
            applySelectedViewMode()
        }
    }
    @Published var groupingFieldID: UUID?
    
    init(project: Project, modelContext: ModelContext) {
        self.modelContext = modelContext
        
        if let firstView = project.views.first {
            self.selectedViewID = firstView.id
            applySelectedViewMode(from: firstView)
        } else {
            self.groupingFieldID = project.fieldDefinitions.first { $0.type == .selection }?.id
        }
        
        self.visibleCardPropertyIDs = Set(project.fieldDefinitions.map { $0.id })
    }
    
    private func applySelectedViewMode(from viewMode: ViewMode? = nil) {
        guard let viewID = selectedViewID,
              let config = viewMode ?? (try? modelContext.fetch(FetchDescriptor<ViewMode>(predicate: #Predicate { $0.id == viewID })).first)
        else { return }
        
        self.activeFilters = (try? JSONDecoder().decode([UUID: FilterType].self, from: config.filtersJSON)) ?? [:]
        self.activeSortRule = (try? JSONDecoder().decode(SortRule.self, from: config.sortRuleJSON))
        self.groupingFieldID = config.groupingFieldID
    }
    
    func saveCurrentStateToSelectedView() {
        guard let viewID = selectedViewID,
              let config = try? modelContext.fetch(FetchDescriptor<ViewMode>(predicate: #Predicate { $0.id == viewID })).first
        else { return }
        
        config.filtersJSON = (try? JSONEncoder().encode(activeFilters)) ?? Data()
        config.sortRuleJSON = (try? JSONEncoder().encode(activeSortRule)) ?? Data()
        config.groupingFieldID = self.groupingFieldID
    }
    
    func createNewView(name: String, displayType: ViewMode.DisplayType, groupingFieldID: UUID?, for project: Project) {
        let newView = ViewMode(name: name, displayType: displayType, groupingFieldID: groupingFieldID)
        newView.project = project
        modelContext.insert(newView)
        self.selectedViewID = newView.id
    }
    
    func deleteView(_ viewMode: ViewMode) {
        if selectedViewID == viewMode.id {
            selectedViewID = nil
        }
        modelContext.delete(viewMode)
    }
    
    func groupableFields(for project: Project) -> [FieldDefinition] {
        return project.fieldDefinitions.filter {
            $0.type == .selection || $0.type == .multiSelection
        }
    }
    
    func toggleCardPropertyVisibility(id: UUID) {
        if visibleCardPropertyIDs.contains(id) {
            visibleCardPropertyIDs.remove(id)
        } else {
            visibleCardPropertyIDs.insert(id)
        }
    }
    
    func toggleVisibility(for card: Card, definition: FieldDefinition) {
        card.toggleFieldVisibility(for: definition.id)
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
    
    func createQuickCard(in groupKey: String, for project: Project) {
        let newCard = Card(title: "New Task", project: project)
        
        if let fieldID = groupingFieldID,
           let definition = project.fieldDefinitions.first(where: { $0.id == fieldID }) {
            let property = PropertyValue(card: newCard, fieldDefinition: definition)
            property.selectionValue = groupKey
            newCard.properties.append(property)
        }
        
        modelContext.insert(newCard)
    }
    
    func addProperty(to card: Card, basedOn potentialDefinition: FieldDefinition, in project: Project) {
        let definition: FieldDefinition
        if let existingDef = project.fieldDefinitions.first(where: { $0.name.lowercased() == potentialDefinition.name.lowercased() }) {
            definition = existingDef
        } else {
            potentialDefinition.project = project
            modelContext.insert(potentialDefinition)
            definition = potentialDefinition
        }

        let hasPropertyAlready = card.properties.contains { $0.fieldDefinition?.id == definition.id }
        guard !hasPropertyAlready else { return }
        
        let newProperty = PropertyValue(card: card, fieldDefinition: definition)
    }

    func removeProperty(_ property: PropertyValue) {
        guard let definitionID = property.fieldDefinition?.id else {
            modelContext.delete(property)
            return
        }
        
        let projectID = property.card?.project?.id

        modelContext.delete(property)

        var descriptor = FetchDescriptor<PropertyValue>(
            predicate: #Predicate {
                $0.card?.project?.id == projectID &&
                $0.fieldDefinition?.id == definitionID
            }
        )
        descriptor.fetchLimit = 1

        do {
            let remainingProperties = try modelContext.fetch(descriptor)
            
            if remainingProperties.isEmpty {
                if let definitionToDelete = try? modelContext.fetch(FetchDescriptor<FieldDefinition>(predicate: #Predicate { $0.id == definitionID })).first {
                    modelContext.delete(definitionToDelete)
                }
            }
        } catch {
            print("Failed to check for orphaned FieldDefinitions: \(error)")
        }
    }
    
    func addOption(to definition: FieldDefinition, newOption: String) {
        let trimmedOption = newOption.trimmingCharacters(in: .whitespaces)
        guard !trimmedOption.isEmpty else { return }

        if definition.selectionOptions?.contains(trimmedOption) == true {
            return
        }
        definition.selectionOptions?.append(trimmedOption)
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
    
    func getGroupKeys(for project: Project) -> [String] {
        guard let fieldID = groupingFieldID,
              let definition = project.fieldDefinitions.first(where: { $0.id == fieldID })
        else { return [] }

        guard definition.type == .selection || definition.type == .multiSelection else {
            return []
        }

        return definition.selectionOptions ?? []
    }
    
    func colorForGroup(_ groupKey: String, in project: Project) -> Color {
        guard let fieldID = groupingFieldID,
              let definition = project.fieldDefinitions.first(where: { $0.id == fieldID })
        else {
            return .gray
        }
        
        switch definition.name {
        case "Status":
            return CardStatus(rawValue: groupKey)?.colorTask ?? .gray
            
        case "Difficulty":
            return CardDifficulty(rawValue: groupKey)?.color ?? .gray
            
        default:
            return .gray
        }
    }
    
    func handleDrop(of card: Card, on newGroupKey: String) {
        guard let fieldID = groupingFieldID else { return }
        
        if let propertyToUpdate = card.properties.first(where: { $0.fieldDefinition?.id == fieldID }) {
            propertyToUpdate.selectionValue = newGroupKey
        } else {
            if let definition = card.project?.fieldDefinitions.first(where: { $0.id == fieldID }) {
                let newProperty = PropertyValue(card: card, fieldDefinition: definition)
                newProperty.selectionValue = newGroupKey
                card.properties.append(newProperty)
            }
        }
    }
    
    func deleteCard(_ card: Card) {
        modelContext.delete(card)
    }
}
