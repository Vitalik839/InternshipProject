//
//  CardDataProcessor.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 29.07.2025.
//

import Foundation

actor CardDataProcessor {

    private var cachedCards: [Card] = []

    func processCards(
        _ cards: [Card],
        searchText: String,
        filters: [UUID: FilterType],
        sortRule: SortRule?,
        definitions: [FieldDefinition]
    ) -> [Card] {
        
        var processedCards = cards
        if !searchText.isEmpty {
            processedCards = processedCards.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }

        if !filters.isEmpty {
            processedCards = filterCards(processedCards, with: filters)
        }
        
        if let sortRule = sortRule {
            processedCards = sortCards(processedCards, with: sortRule, definitions: definitions)
        }
        
        self.cachedCards = processedCards
        return processedCards
    }

    private func filterCards(_ cards: [Card], with filters: [UUID: FilterType]) -> [Card] {
         cards.filter { card in
            for (fieldID, filter) in filters {
                guard let propertyValue = card.properties[fieldID] else {
                    return false
                }
                if !isCardSatisfyingRule(propertyValue: propertyValue, filter: filter) {
                    return false
                }
            }
            return true
        }
    }

    private func sortCards(_ cards: [Card], with sortRule: SortRule, definitions: [FieldDefinition]) -> [Card] {
        guard let sortField = definitions.first(where: { $0.id == sortRule.fieldID }) else {
            return cards
        }

        return cards.sorted { card1, card2 in
            let value1 = card1.properties[sortRule.fieldID]
            let value2 = card2.properties[sortRule.fieldID]
            let result = compare(value1, and: value2, for: sortField.type)
            return sortRule.direction == .ascending ? result : !result
        }
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
}
