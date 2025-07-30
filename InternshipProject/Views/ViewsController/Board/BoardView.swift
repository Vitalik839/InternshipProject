//
//  BoardView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 30.07.2025.
//

import SwiftUI

struct BoardView: View {
    @EnvironmentObject var boardLogic: CardViewModel
    @Binding var selectedCardID: UUID?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 8) {
                    ForEach(boardLogic.currentGroupKeys, id: \.self) { groupKey in
                        ColumnView(
                            groupKey: groupKey,
                            cards: boardLogic.cards(for: groupKey),
                            projectDefinitions: boardLogic.project.fieldDefinitions,
                            visibleCardPropertyIDs: boardLogic.visibleCardPropertyIDs,
                            columnColor: color(for: groupKey),
                            onTaskDropped: { droppedCard, newGroup in
                                boardLogic.handleDrop(of: droppedCard, on: newGroup)
                            },
                            onCardTapped: { card in
                                self.selectedCardID = card.id
                            }
                        ).frame(maxHeight: .infinity, alignment: .top)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    private func color(for groupKey: String) -> Color {
        guard let fieldID = boardLogic.groupingFieldID,
              let definition = boardLogic.project.fieldDefinitions.first(where: { $0.id == fieldID })
        else { return .gray }
        
        switch definition.name {
        case "Status":
            return CardStatus(rawValue: groupKey)?.colorTask ?? .gray
        case "Difficulty":
            return CardDifficulty(rawValue: groupKey)?.color ?? .gray
        default:
            return CardStatus.notStarted.colorTask
        }
    }
}
