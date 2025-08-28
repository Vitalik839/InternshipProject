//
//  ViewMode.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 31.07.2025.
//

import Foundation
import SwiftData

@Model
final class ViewMode {
    @Attribute(.unique) var id: UUID
    var name: String
    var displayType: DisplayType
    var groupingFieldID: UUID?
    
    var filtersJSON: Data = Data()
    var sortRuleJSON: Data = Data()

    var project: Project?
    
    init(name: String, displayType: DisplayType, groupingFieldID: UUID? = nil) {
        self.id = UUID()
        self.name = name
        self.displayType = displayType
        self.groupingFieldID = groupingFieldID
    }
    
    enum DisplayType: String, Codable, Hashable, CaseIterable {
        case board = "Board"
        case table = "Table"
    }
}
