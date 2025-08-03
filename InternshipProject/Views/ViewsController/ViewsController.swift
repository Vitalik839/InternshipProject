//
//  TaskBoardView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import SwiftUI

struct ViewsController: View {
    @Binding var project: Project
    @StateObject private var boardLogic: CardViewModel
    
    init(project: Binding<Project>) {
        self._project = project
        self._boardLogic = StateObject(wrappedValue: CardViewModel(project: project.wrappedValue))
    }
    @State private var selectedCardID: UUID?
    @State private var isTargetedForDeletion = false
    
    private var currentDisplayType: ViewMode.DisplayType? {
        boardLogic.project.views.first { $0.id == boardLogic.selectedViewID }?.displayType
    }
    
    var body: some View {
        VStack(alignment: .leading){
            Toolbar(searchText: $boardLogic.searchText)
                .padding(.bottom, 10)
            
            if let displayType = currentDisplayType {
                switch displayType {
                case .board:
                    Picker("Group By", selection: $boardLogic.groupingFieldID.animation()) {
                        ForEach(boardLogic.groupableFields) { field in
                            Text(field.name).tag(field.id as UUID?)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom)
                    BoardView(selectedCardID: $selectedCardID)
                case .table:
                    AllCardsView(viewModel: boardLogic) { card in
                        self.selectedCardID = card.id
                    }
                }
            } else {
                Text("Select a view to start")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
}

//#Preview {
//    TaskBoardView()
//}
