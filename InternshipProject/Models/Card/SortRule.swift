//
//  SortRule.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 29.07.2025.
//

import Foundation

struct SortRule: Codable, Hashable {
    var fieldID: UUID
    var direction: SortDirection = .ascending
}

enum SortDirection: String, Codable, CaseIterable {
    case ascending = "Ascending"
    case descending = "Descending"
}

