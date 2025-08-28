//
//  CardQueryBuilder.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 16.08.2025.
//

import Foundation
import SwiftData

enum CardQueryBuilder {

    static func buildPredicate(
        for project: Project,
        searchText: String,
        activeFilters: [UUID: FilterType] // Ваш enum з типами фільтрів
    ) -> Predicate<Card> {
        
        var predicates: [Predicate<Card>] = []
        let projectID = project.id

        // 1. Базовий фільтр за проєктом
        predicates.append(#Predicate<Card> { $0.project?.id == projectID })

        // 2. Фільтр по тексту пошуку
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            predicates.append(#Predicate<Card> { $0.title.localizedStandardContains(searchText) })
        }

        // 3. Динамічні фільтри, які тепер працюють!
        for (fieldID, filter) in activeFilters {
            switch filter {
                
            case .selectionContains(let selectedOptions):
                predicates.append(#Predicate<Card> { card in
                    card.properties.contains { prop in
                        prop.fieldDefinition?.id == fieldID &&
                        (
                            (prop.selectionValue != nil && selectedOptions.contains(prop.selectionValue!)) ||
                            (prop.multiSelectionValue != nil && prop.multiSelectionValue!.contains { option in
                                selectedOptions.contains(option)
                            })
                        )
                    }
                })

            case .numberRange(let start, let end):
                predicates.append(#Predicate<Card> { card in
                    card.properties.contains { prop in
                        prop.fieldDefinition?.id == fieldID &&
                        (start == nil || (prop.numberValue != nil && prop.numberValue! >= start!)) &&
                        (end == nil || (prop.numberValue != nil && prop.numberValue! <= end!))
                    }
                })

            case .dateRange(let start, let end):
                predicates.append(#Predicate<Card> { card in
                    card.properties.contains { prop in
                        prop.fieldDefinition?.id == fieldID &&
                        (start == nil || (prop.dateValue != nil && prop.dateValue! >= start!)) &&
                        (end == nil || (prop.dateValue != nil && prop.dateValue! <= end!))
                    }
                })

            default:
                break
            }
        }
        
        // Комбінуємо всі предикати в один через "AND"
        return predicates.reduce(#Predicate<Card> { _ in true }) { combined, new in
            #Predicate<Card> { card in
                combined.evaluate(card) && new.evaluate(card)
            }
        }
    }

    // Сортування поки залишаємо простим, його можна буде ускладнити пізніше
    static func buildSortDescriptors(from rule: SortRule?) -> [SortDescriptor<Card>] {
        return [SortDescriptor(\Card.title)]
    }
}
