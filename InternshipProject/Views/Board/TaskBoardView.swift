//
//  TaskBoardView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import SwiftUI

struct TaskBoardView: View {
    @Binding var project: Project
    @StateObject private var boardLogic: TaskBoardViewModel
    
    init(project: Binding<Project>) {
        self._project = project
        self._boardLogic = StateObject(wrappedValue: TaskBoardViewModel(project: project.wrappedValue))
    }
    @State private var currentMode: ViewMode = .byStatus
    
    var body: some View {
        VStack(alignment: .leading){
            Toolbar(selectedMode: $currentMode, searchText: $boardLogic.searchText)
                .environmentObject(boardLogic)
            Picker("Group By", selection: $boardLogic.grouping.animation()) {
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
                AllTasksView(viewModel: boardLogic)
            case .myTasks:
                Text("My Tasks View").foregroundStyle(.white)
            case .checklist:
                Text("Checklist View").foregroundStyle(.white)
            }
        }
        .padding(.leading, 10)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color("bg"))
        .environmentObject(boardLogic)
    }
    
    @ViewBuilder
    private var boardView: some View {
        VStack {
            ScrollView([.vertical, .horizontal], showsIndicators: false) {
                HStack(alignment: .top, spacing: 8) {
                    ForEach(TaskStatus.allCases, id: \.self) { status in
                        TaskColumnView(
                            group: status,
                            cards: boardLogic.cards(for: status),
                            projectDefinitions: boardLogic.projectDefinitions,
                            visibleCardPropertyIDs: boardLogic.visibleCardPropertyIDs,
                            columnColor: color(for: status),
                            onTaskDropped: { droppedCard, newGroup in
                                boardLogic.handleDrop(of: droppedCard, on: newGroup)
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
