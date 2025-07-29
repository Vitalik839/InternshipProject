//
//  TaskCardView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 03.07.2025.
//

import SwiftUI

struct CardView: View {
    let card: Card
    let projectDefinitions: [FieldDefinition]
    let visiblePropertyIDs: Set<UUID>
    let backgroundColor: Color
    @EnvironmentObject var viewModel: CardViewModel
    
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
            
            ForEach(projectDefinitions.filter { visiblePropertyIDs.contains($0.id) && !card.hiddenFieldIDs.contains($0.id) &&
                $0.id != viewModel.groupingFieldID}) { definition in
                    if let value = card.properties[definition.id] {
                        PropertyDisplayView(cardID: card.id,
                                            definition: definition,
                                            value: value)
                        .environmentObject(viewModel)
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


