//
//  TaskBoardView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import SwiftUI

struct CardBoardView: View {
    @Binding var project: Project
    @StateObject private var boardLogic: CardViewModel
    
    init(project: Binding<Project>) {
        self._project = project
        self._boardLogic = StateObject(wrappedValue: CardViewModel(project: project.wrappedValue))
    }
    @State private var currentMode: ViewMode = .byStatus
    @State private var selectedCardID: UUID?
    @State private var isTargetedForDeletion = false
    
    
    var body: some View {
        VStack(alignment: .leading){
            Toolbar(selectedMode: $currentMode, searchText: $boardLogic.searchText)
                .environmentObject(boardLogic)
            
            switch currentMode {
            case .byStatus:
                Picker("Group By", selection: $boardLogic.groupingFieldID.animation()) {
                    ForEach(boardLogic.groupableFields) { field in
                        Text(field.name).tag(field.id as UUID?)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom)
                boardView
            case .all:
                AllCardsView(viewModel: boardLogic) { card in
                    self.selectedCardID = card.id
                }
            case .myTasks:
                Text("My Tasks View").foregroundStyle(.white)
            case .checklist:
                Text("Checklist View").foregroundStyle(.white)
            }
            TrashView(isTargeted: $isTargetedForDeletion)
                .dropDestination(for: Card.self) { droppedCards, location in
                    if let card = droppedCards.first {
                        boardLogic.deleteCard(card)
                    }
                    return true
                } isTargeted: { isTargeting in
                    isTargetedForDeletion = isTargeting
                }
        }
        .padding(.horizontal, 10)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color("bg"))
        .sheet(item: $selectedCardID) { cardID in
            if let index = boardLogic.project.cards.firstIndex(where: { $0.id == cardID }) {
                CardDetailView(card: $boardLogic.project.cards[index])
            }
        }
        .environmentObject(boardLogic)
        .onChange(of: boardLogic.project) { _, newProjectState in
            self.project = newProjectState
        }
    }
    
    @ViewBuilder
    private var boardView: some View {
        VStack {
            ScrollView([.vertical, .horizontal], showsIndicators: false) {
                HStack(alignment: .top, spacing: 8) {
                    ForEach(boardLogic.currentGroupKeys, id: \.self) { groupKey in
                        ColumnView(
                            groupKey: groupKey,
                            cards: boardLogic.cards(for: groupKey),
                            projectDefinitions: boardLogic.projectDefinitions,
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
            return TaskStatus(rawValue: groupKey)?.colorTask ?? .gray
        case "Difficulty":
            return Difficulty(rawValue: groupKey)?.color ?? .gray
        default:
            return TaskStatus.notStarted.colorTask
        }
    }
}

//#Preview {
//    TaskBoardView()
//}
