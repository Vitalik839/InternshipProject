//
//  InternshipProjectApp.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 03.07.2025.
//

import SwiftUI
import SwiftData

@main
struct InternshipProjectApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Project.self,
            Card.self,
            FieldDefinition.self,
            PropertyValue.self,
            ViewMode.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            Task { @MainActor in
                await DataSeeder.seedSampleDataIfNeeded(modelContext: container.mainContext)
            }
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
