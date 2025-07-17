//
//  TaskBoardView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import SwiftUI

struct TaskBoardView: View {
    @StateObject private var viewModel = TaskBoardViewModel()

    // Цей State керує перемиканням між режимами (дошка, список і т.д.)
    @State private var currentMode: ViewMode = .byStatus
    
    var body: some View {
        VStack(alignment: .leading){
            Toolbar(selectedMode: $currentMode, searchText: $viewModel.searchText)
            
            Picker("Group By", selection: $viewModel.grouping.animation()) {
                ForEach(TaskBoardViewModel.Grouping.allCases, id: \.self) { mode in
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
                AllTasksView(viewModel: viewModel)
            case .myTasks:
                Text("My Tasks View").foregroundStyle(.white)
            case .checklist:
                Text("Checklist View").foregroundStyle(.white)
            }
        }
        .padding(.leading, 10)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color("bg"))
        .environmentObject(viewModel)
    }
    
    @ViewBuilder
    private var boardView: some View {
        VStack {
            ScrollView([.vertical, .horizontal], showsIndicators: false) {
                HStack(alignment: .top, spacing: 8) {
                    ForEach(TaskStatus.allCases, id: \.self) { status in
                        TaskColumnView(
                            group: status,
                            cards: viewModel.cards(for: status),
                            projectDefinitions: viewModel.projectDefinitions,
                            visibleCardPropertyIDs: viewModel.visibleCardPropertyIDs,
                            columnColor: color(for: status),
                            onTaskDropped: { droppedCard, newGroup in
                                viewModel.handleDrop(of: droppedCard, on: newGroup)
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
        switch viewModel.grouping {
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

#Preview {
    TaskBoardView()
}
