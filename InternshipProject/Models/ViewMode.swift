//
//  ViewMode.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 31.07.2025.
//

import Foundation

struct ViewMode: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var displayType: DisplayType
    
    var groupingFieldID: UUID?
    
    var filters: [UUID: FilterType] = [:]
    var sortRule: SortRule?

    enum DisplayType: String, Codable, Hashable, CaseIterable {
        case board = "Board"
        case table = "Table"
    }
}

