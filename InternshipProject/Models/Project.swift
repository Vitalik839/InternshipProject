//
//  Project.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 18.07.2025.
//

import Foundation

struct Project: Identifiable, Codable, Hashable {
    let id: UUID = UUID()
    var name: String
    var fieldDefinitions: [FieldDefinition]
    var cards: [Card] = []
    var views: [ViewMode] = []
}
