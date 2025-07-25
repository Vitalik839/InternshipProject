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
    @State private var showCreateCardSheet = false
    @State private var isTargetedForDeletion = false
    
    
    var body: some View {
        VStack(alignment: .leading){
            Toolbar(selectedMode: $currentMode, searchText: $boardLogic.searchText, showCreateCardSheet: $showCreateCardSheet)
                .environmentObject(boardLogic)
            Picker("Group By", selection: $boardLogic.grouping.animation()) {
                ForEach(CardViewModel.Grouping.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom)
            .padding(.trailing, 10)
            
            switch currentMode {
            case .byStatus:
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
        .padding(.leading, 10)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color("bg"))
        .environmentObject(boardLogic)
        .sheet(isPresented: $showCreateCardSheet) {
            CreateCard(
                viewModel: boardLogic,
                onSave: { newCard in
                    boardLogic.addNewCard(newCard)
                    showCreateCardSheet = false
                }
            )
        }
        .sheet(item: $selectedCardID) { cardID in
            if let index = boardLogic.project.cards.firstIndex(where: { $0.id == cardID }) {
                CardDetailView(card: $boardLogic.project.cards[index])
                    .environmentObject(boardLogic)
            }
        }
        .onChange(of: boardLogic.project) { _, newProjectState in
            self.project = newProjectState
        }
    }
    
    @ViewBuilder
    private var boardView: some View {
        VStack {
            ScrollView([.vertical, .horizontal], showsIndicators: false) {
                HStack(alignment: .top, spacing: 8) {
                    ForEach(TaskStatus.allCases, id: \.self) { status in
                        ColumnView(
                            group: status,
                            cards: boardLogic.cards(for: status),
                            projectDefinitions: boardLogic.projectDefinitions,
                            visibleCardPropertyIDs: boardLogic.visibleCardPropertyIDs,
                            columnColor: color(for: status),
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
    
    private func color(for group: any GroupableProperty) -> Color {
        guard let groupKey = group as? String else { return .gray }
        
        // Використовуємо енуми зі старих моделей для отримання кольорів
        switch boardLogic.grouping {
        case .byStatus:
            return TaskStatus(rawValue: groupKey)?.colorTask ?? .gray
        case .byDifficulty:
            return Difficulty(rawValue: groupKey)?.color ?? .gray
        case .byTag:
            // Можна додати логіку для різних кольорів тегів
            return .blue
        }
    }
}

//#Preview {
//    TaskBoardView()
//}
