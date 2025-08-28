//
//  Project.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 18.07.2025.
//

import Foundation
import SwiftData

@Model
final class Project {
    @Attribute(.unique) var id: UUID
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \Card.project)
    var cards: [Card] = []
    
    @Relationship(deleteRule: .cascade, inverse: \FieldDefinition.project)
    var fieldDefinitions: [FieldDefinition] = []
    
    @Relationship(deleteRule: .cascade, inverse: \ViewMode.project)
    var views: [ViewMode] = []

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
