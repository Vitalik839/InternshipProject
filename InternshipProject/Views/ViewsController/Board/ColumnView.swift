//
//  TaskColumnView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct ColumnView: View {
    let groupKey: String
    let cards: [Card]
    let projectDefinitions: [FieldDefinition]
    let visibleCardPropertyIDs: Set<UUID>
    let columnColor: Color
    let onTaskDropped: (Card, String) -> Void
    let onCardTapped: (Card) -> Void

    @State private var selectedCardID: UUID?
    @State private var isTargeted: Bool = false
    @EnvironmentObject var viewModel: CardViewModel

    var body: some View {
        VStack (alignment: .leading, spacing: 0){
            HStack {
                LabelTitleColumn(title: groupKey, colorBg: columnColor.opacity(0.4))
                Spacer()
                Text("\(cards.count)")
            }
            .padding(.bottom, 8)
            VStack(spacing: 8) {
                ForEach(cards) { card in
                    CardView(card: card,
                             projectDefinitions: projectDefinitions,
                             visiblePropertyIDs: visibleCardPropertyIDs,
                             backgroundColor: columnColor.opacity(0.4)
                    )
                    .onTapGesture {
                        onCardTapped(card)
                    }
                    .draggable(card)
                    .environmentObject(viewModel)
                }
            }
            .padding(.bottom)

            Button(action: {
                viewModel.createQuickCard(in: groupKey)
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("New Task")
                    Spacer()
                }
                .padding()
                .frame(width: 280)
                .fontWeight(.bold)
                .foregroundColor(columnColor.opacity(0.8))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(columnColor.opacity(0.8), style: StrokeStyle(lineWidth: 2))
            )
        }
        .padding(10)
        .frame(width: 300)
        .background(isTargeted ? columnColor.opacity(0.5) : columnColor.opacity(0.25))
        .cornerRadius(12)
        .dropDestination(for: Card.self) { droppedTasks, location in
            guard let droppedTask = droppedTasks.first else { return false }
            onTaskDropped(droppedTask, groupKey)
            return true
        } isTargeted: { isTargeting in
            self.isTargeted = isTargeting
        }
        .sheet(item: $selectedCardID) { cardID in
            if let index = viewModel.project.cards.firstIndex(where: { $0.id == cardID }) {
                CardDetailView(card: $viewModel.project.cards[index])
                    .environmentObject(viewModel)
            }
        }
    }
}

//#Preview {
//    TaskColumnView(status: .notStarted, tasks:[TaskCard(title: "Premiere pro Caba Videos Edit", priority: .hard, tags: ["Polish", "Bug"], commentCount: 0, status: .notStarted)])
//}
