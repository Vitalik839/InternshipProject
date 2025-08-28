//
//  BoardView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 30.07.2025.
//

import SwiftUI

struct BoardView: View {
    @EnvironmentObject var boardLogic: CardViewModel
    @Binding var selectedCard: Card?
    let project: Project
    let cards: [Card]
    
    private var groupedCards: [String: [Card]] {
        guard let groupFieldID = boardLogic.groupingFieldID else { return [:] }

        return Dictionary(grouping: cards) { card in
            if let property = card.properties.first(where: { $0.fieldDefinition?.id == groupFieldID }) {
                return property.selectionValue ?? "Uncategorized"
            }
            return "Uncategorized"
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 8) {
                    ForEach(boardLogic.getGroupKeys(for: project), id: \.self) { groupKey in
                        ColumnView(
                            groupKey: groupKey,
                            cards: groupedCards[groupKey] ?? [],
                            columnColor: boardLogic.colorForGroup(groupKey, in: project),
                            onCardTapped: { card in
                                self.selectedCard = card
                            }
                        ).frame(maxHeight: .infinity, alignment: .top)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}
