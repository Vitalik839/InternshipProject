//
//  DataSeeder.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 16.08.2025.
//

import Foundation
import SwiftData

@MainActor
enum DataSeeder {
    static func seedSampleDataIfNeeded(modelContext: ModelContext) async {
        let projectDescriptor = FetchDescriptor<Project>()
        guard (try? modelContext.fetch(projectDescriptor).count) == 0 else {
            return
        }
        
        print("No projects found. Seeding sample data...")
        
        let project = Project(name: "Tasks Tracker")
        modelContext.insert(project)

        let statusDef = FieldDefinition(name: "Status", type: .selection, selectionOptions: CardStatus.allCases.map(\.rawValue))
        let difficultyDef = FieldDefinition(name: "Difficulty", type: .selection, selectionOptions: CardDifficulty.allCases.map(\.rawValue))

        let tagsDef = FieldDefinition(name: "Tags", type: .multiSelection, selectionOptions: ["Polish", "Bug", "Feature Request", "Self", "Tech"])
        let dateDef = FieldDefinition(name: "Due date", type: .date)
        let textDef = FieldDefinition(name: "Text", type: .text)
        
        statusDef.project = project
        difficultyDef.project = project
        tagsDef.project = project
        dateDef.project = project
        textDef.project = project
        
        let card1 = Card(title: "Implement new login screen", project: project)
        let card2 = Card(title: "Fix crash on main screen", project: project)
        let card3 = Card(title: "Refactor networking layer", project: project)

        // 4. Створюємо значення властивостей для карток
        let prop1_status = PropertyValue(card: card1, fieldDefinition: statusDef)
        prop1_status.selectionValue = CardStatus.inProgress.rawValue
        
        let prop1_difficulty = PropertyValue(card: card1, fieldDefinition: difficultyDef)
        prop1_difficulty.selectionValue = CardDifficulty.hard.rawValue
        
        let prop2_status = PropertyValue(card: card2, fieldDefinition: statusDef)
        prop2_status.selectionValue = CardStatus.notStarted.rawValue
        
        let prop3_tags = PropertyValue(card: card3, fieldDefinition: tagsDef)
        prop3_tags.multiSelectionValue = ["Tech", "Self"]
        

        do {
            try modelContext.save()
            print("Sample data seeded successfully.")
        } catch {
            print("Failed to seed data: \(error)")
        }
    }
}
