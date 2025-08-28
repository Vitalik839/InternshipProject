//
//  TaskCardView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 03.07.2025.
//

import SwiftUI

struct CardView: View {
    let card: Card
    let backgroundColor: Color
    
    @EnvironmentObject var viewModel: CardViewModel
    
    private var sortedProperties: [PropertyValue] {
        card.properties.sorted {
            ($0.fieldDefinition?.name ?? "") < ($1.fieldDefinition?.name ?? "")
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
            
            ForEach(sortedProperties) { property in
                if let definition = property.fieldDefinition {
                    let isVisible = viewModel.visibleCardPropertyIDs.contains(definition.id)
                    let isHiddenOnCard = card.isFieldHidden(with: definition.id)
                    let isGroupingField = (definition.id == viewModel.groupingFieldID)
                    
                    if isVisible && !isHiddenOnCard && !isGroupingField {
                        PropertyDisplayView(property: property)
                    }
                }
            }
        }
        .padding()
        .frame(width: 280, alignment: .leading)
        .background(backgroundColor)
        .cornerRadius(16)
    }
}

//#Preview {
//    let statusDef = FieldDefinition(name: "Status", type: .selection, selectionOptions: TaskStatus.allCases.map(\.rawValue))
//    let priorityDef = FieldDefinition(name: "Difficulty", type: .selection, selectionOptions: Difficulty.allCases.map(\.rawValue))
//    let tags = FieldDefinition(name: "Tags", type: .selection, selectionOptions: ["Tech", "Polish", "Self"])
//    let effortDef = FieldDefinition(name: "Effort", type: .number)
//    
//    CardView(card: Card(
//        id: UUID(),
//        title: "Design new login screen",
//        properties: [
//            statusDef.id: .selection("Done"),
//            priorityDef.id: .selection("Medium"),
//            tags.id: .selection("Polish"),
//            effortDef.id: .number(8)
//        ]),
//                 projectDefinitions: [statusDef, priorityDef, tags, effortDef],
//                 visiblePropertyIDs: Set())
//}


