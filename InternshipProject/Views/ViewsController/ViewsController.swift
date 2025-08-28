//
//  TaskBoardView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import SwiftUI
import SwiftData

struct ViewsController: View {
    @Bindable var project: Project
    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel: CardViewModel

    @State private var selectedCard: Card?
    @State private var isTargetedForDeletion = false

    // Ініціалізатор для налаштування ViewModel
    init(project: Project) {
        self.project = project
        let modelContext = project.modelContext!
        let viewModel = CardViewModel(project: project, modelContext: modelContext)
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private var currentDisplayType: ViewMode.DisplayType? {
        project.views.first { $0.id == viewModel.selectedViewID }?.displayType
    }
    
    var body: some View {
        FilteredCardsView(
            project: project,
            searchText: viewModel.searchText,
            activeFilters: viewModel.activeFilters,
            sortRule: viewModel.activeSortRule
        ) { cards in
            VStack(alignment: .leading) {
                Toolbar(project: project)
                    .padding(.bottom, 10)
                
                VStack {
                    if let displayType = currentDisplayType {
                        switch displayType {
                        case .board:
                            Picker("Group By", selection: $viewModel.groupingFieldID.animation()) {
                                ForEach(viewModel.groupableFields(for: project)) { field in
                                    Text(field.name).tag(field.id as UUID?)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.bottom)
                            
                            BoardView(selectedCard: $selectedCard,
                                      project: project,
                                      cards: cards
                            )
                            
                        case .table:
                            AllCardsView(project: project, cards: cards) { card in
                                self.selectedCard = card
                            }
                        }
                    } else {
                         Text("Select or create a view to start")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    TrashView(isTargeted: $isTargetedForDeletion)
                        .dropDestination(for: String.self) { droppedIDStrings, _ in
                            guard let cardIDString = droppedIDStrings.first,
                                  let cardID = UUID(uuidString: cardIDString) else { return false }
                            
                            if let cardToDelete = cards.first(where: { $0.id == cardID }) {
                                viewModel.deleteCard(cardToDelete)
                                return true
                            }
                            return false
                        } isTargeted: { isTargeting in
                            isTargetedForDeletion = isTargeting
                        }
                }
                .sheet(item: $selectedCard) { card in
                    CardDetailView(card: card)
                }
            }
        }
        .padding(.horizontal, 10)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color("bg"))
        .environmentObject(viewModel)
    }
}

private struct FilteredCardsView<Content: View>: View {
    @Query var cards: [Card]
    let content: ([Card]) -> Content

    init(
        project: Project,
        searchText: String,
        activeFilters: [UUID: FilterType],
        sortRule: SortRule?,
        @ViewBuilder content: @escaping ([Card]) -> Content
    ) {
        // Тепер тут знову один виклик, як і повинно бути!
        let predicate = CardQueryBuilder.buildPredicate(
            for: project,
            searchText: searchText,
            activeFilters: activeFilters
        )
        let sortDescriptors = CardQueryBuilder.buildSortDescriptors(from: sortRule)
        
        self._cards = Query(filter: predicate, sort: sortDescriptors, animation: .default)
        self.content = content
    }

    var body: some View {
        content(cards)
    }
}

//#Preview {
//    TaskBoardView()
//}
