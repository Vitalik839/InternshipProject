//
//  TaskColumnView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftData

struct ColumnView: View {
    let groupKey: String
    let cards: [Card]
    let columnColor: Color
    let onCardTapped: (Card) -> Void
    
    @State private var isTargeted: Bool = false
    @EnvironmentObject var viewModel: CardViewModel
    @Environment(\.modelContext) private var modelContext

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
                    CardView(card: card, backgroundColor: columnColor.opacity(0.4))
                    .onTapGesture {
                        onCardTapped(card)
                    }
                    .draggable(card)
                }
            }
            .padding(.bottom)

            Button(action: {
                if let project = cards.first?.project {
                    viewModel.createQuickCard(in: groupKey, for: project)
                }
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
        .dropDestination(for: String.self) { droppedIDStrings, _ in
            guard let cardIDString = droppedIDStrings.first,
                  let cardID = UUID(uuidString: cardIDString) else {
                return false
            }

            let descriptor = FetchDescriptor<Card>(predicate: #Predicate { $0.id == cardID })
            
            do {
                if let droppedCard = try modelContext.fetch(descriptor).first {
                    viewModel.handleDrop(of: droppedCard, on: groupKey)
                    return true
                }
            } catch {
                print("Failed to fetch card to drop: \(error)")
            }
            return false
            
        } isTargeted: { isTargeting in
            self.isTargeted = isTargeting
        }
    }
}

//#Preview {
//    TaskColumnView(status: .notStarted, tasks:[TaskCard(title: "Premiere pro Caba Videos Edit", priority: .hard, tags: ["Polish", "Bug"], commentCount: 0, status: .notStarted)])
//}
