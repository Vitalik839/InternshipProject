//
//  TaskCardView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 03.07.2025.
//

import SwiftUI

struct TaskCardView: View {
    let card: TaskCard
    let projectDefinitions: [FieldDefinition] // Шаблони полів з проекту
    let visiblePropertyIDs: Set<UUID>
    @EnvironmentObject var viewModel: TaskBoardViewModel
    
    //  визначення поля "Status" для кольору картки
    private var statusValue: FieldValue? {
        // Знаходимо ID поля "Status" у визначеннях проекту
        guard let statusDefinitionID = projectDefinitions.first(where: { $0.name == "Status" })?.id else {
            return nil
        }
        // Повертаємо значення з картки для цього ID
        return card.properties[statusDefinitionID]
    }
    
    // Визначаємо колір фону на основі статусу
    private var backgroundColor: Color {
        guard let status = statusValue, case .selection(let option) = status else {
            return .gray.opacity(0.2) // Колір за замовчуванням
        }
        
        switch option {
        case "Not started":
            return Color("taskNotStarted")
        case "In progress":
            return Color("taskInProgress")
        case "Done":
            return Color("taskDone")
        default:
            return .gray.opacity(0.2)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(card.title)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 6)
            
            // Динамічно відображаємо всі інші властивості
            ForEach(projectDefinitions.filter { visiblePropertyIDs.contains($0.id) }) { definition in
                if definition.name != "Status", let value = card.properties[definition.id] {
                    PropertyDisplayView(cardID: card.id,
                                        definition: definition,
                                        value: value)
                    .environmentObject(viewModel)
                }
            }
        }
        .padding()
        .frame(width: 280, alignment: .leading)
        .background(backgroundColor) // Використовуємо динамічний колір
        .cornerRadius(16)
    }
}

#Preview {
    let statusDef = FieldDefinition(name: "Status", type: .selection, selectionOptions: TaskStatus.allCases.map(\.rawValue))
    let priorityDef = FieldDefinition(name: "Difficulty", type: .selection, selectionOptions: Difficulty.allCases.map(\.rawValue))
    let tags = FieldDefinition(name: "Tags", type: .selection, selectionOptions: ["Tech", "Polish", "Self"])
    let effortDef = FieldDefinition(name: "Effort", type: .number)
    
    TaskCardView(card: TaskCard(
        id: UUID(),
        title: "Design new login screen",
        properties: [
            statusDef.id: .selection("Done"),
            priorityDef.id: .selection("Medium"),
            tags.id: .selection("Polish"),
            effortDef.id: .number(8)
        ]),
                 projectDefinitions: [statusDef, priorityDef, tags, effortDef],
                 visiblePropertyIDs: Set())
}


