//
//  SortRule.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 29.07.2025.
//

import Foundation

struct SortRule: Equatable {
    var fieldID: UUID
    var direction: SortDirection = .ascending
}

enum SortDirection: String, CaseIterable {
    case ascending = "Ascending"
    case descending = "Descending"
}

