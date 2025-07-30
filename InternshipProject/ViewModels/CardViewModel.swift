//
//  TaskBoardViewModel.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 12.07.2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class CardViewModel: ObservableObject {
    @Published var project: Project
    
    @Published var filteredCards: [Card] = []
    @Published var searchText: String = ""
    @Published var projectDefinitions: [FieldDefinition]
    @Published var visibleCardPropertyIDs: Set<UUID> = []
    @Published var groupingFieldID: UUID?
    @Published var activeFilters: [UUID: FilterType] = [:]
    @Published var activeSortRule: SortRule?

    private let dataProcessor = CardDataProcessor()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()
    
    init(project: Project) {
        self.project = project
        self.filteredCards = project.cards
        self.visibleCardPropertyIDs = Set(project.fieldDefinitions.map { $0.id })
        self.projectDefinitions = project.fieldDefinitions
        
        self.groupingFieldID = project.fieldDefinitions.first(where: {
            $0.type == .selection || $0.type == .multiSelection || $0.type == .date
                })?.id
        
        setupBindings()
    }
    
    var groupableFields: [FieldDefinition] {
        project.fieldDefinitions.filter {
            $0.type == .selection || $0.type == .multiSelection  || $0.type == .date
        }
    }
    
    private func setupBindings() {
        Publishers.CombineLatest4($project, $searchText, $activeFilters, $activeSortRule)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] (project, search, filters, sortRule) in
                self?.reloadDisplayedCards()
            }
            .store(in: &cancellables)
    }
    
    private func reloadDisplayedCards() {
        Task {
            let processedCards = await dataProcessor.processCards(
                project.cards,
                searchText: searchText,
                filters: activeFilters,
                sortRule: activeSortRule,
                definitions: projectDefinitions
            )

            DispatchQueue.main.async {
                self.filteredCards = processedCards
            }
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
        if !projectDefinitions.contains(where: { $0.id == definition.id }) {
            projectDefinitions.append(definition)
        }

        guard let cardIndex = project.cards.firstIndex(where: { $0.id == cardID }) else { return }
        project.cards[cardIndex].properties[definition.id] = getDefaultValue(for: definition.type)
    }
    
    func addOption(to definitionID: UUID, newOption: String) {
        guard let definitionIndex = project.fieldDefinitions.firstIndex(where: { $0.id == definitionID }) else { return }
        
        let currentOptions = project.fieldDefinitions[definitionIndex].selectionOptions ?? []
        guard !currentOptions.contains(newOption) else { return }
        
        project.fieldDefinitions[definitionIndex].selectionOptions?.append(newOption)
    }
    
    func removeProperty(from cardID: UUID, with definitionID: UUID) {
        guard let cardIndex = project.cards.firstIndex(where: { $0.id == cardID }) else { return }
        
        project.cards[cardIndex].properties.removeValue(forKey: definitionID)
        
        let isPropertyUsedElsewhere = project.cards.contains { card in
            card.id != cardID && card.properties.keys.contains(definitionID)
        }
        
        if !isPropertyUsedElsewhere {
            projectDefinitions.removeAll { $0.id == definitionID }
        }
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
        
        else if definition.type == .date {
            let dates = project.cards.compactMap { card -> Date? in
                if case .date(let date) = card.properties[fieldID] {
                    return date
                }
                return nil
            }
            
            let calendar = Calendar.current
            let uniqueMonthYearComponents = Set(dates.map {
                calendar.dateComponents([.year, .month], from: $0)
            })
            
            let sortedComponents = uniqueMonthYearComponents.sorted {
                let date1 = calendar.date(from: $0)!
                let date2 = calendar.date(from: $1)!
                return date1 < date2
            }
            
            return sortedComponents.map { monthYearFormatter.string(from: calendar.date(from: $0)!) }
        }
        
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
                    let formattedDate = monthYearFormatter.string(from: date)
                    return formattedDate == groupKey
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
