//
//  TaskBoardView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import SwiftUI

struct TaskBoardView: View {
    @State private var currentMode: ViewMode = .byStatus
    @State private var searchText: String = ""
    @StateObject private var viewSettings = ViewSettings()
    @StateObject private var viewModel = TaskBoardViewModel()
    
    
    var body: some View {
        VStack(alignment: .leading){
            Toolbar(selectedMode: $currentMode, searchText: $searchText)
            Picker("Group By", selection: $viewModel.grouping.animation()) {
                ForEach(TaskBoardViewModel.Grouping.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom)
            
            switch currentMode {
            case .byStatus:
                ScrollView([.horizontal, .vertical]) {
                    HStack(alignment: .top, spacing: 8) {
                        ForEach(TaskStatus.allCases, id: \.self) { status in
                            TaskColumnView(
                                group: status,
                                tasks: viewModel.tasks(for: status),
                                onTaskDropped: { droppedTask, newGroup in
                                    viewModel.handleDrop(of: droppedTask, on: newGroup)
                                }
                            )
                        }
                    }
                }
            case .all:
                AllTasksView(tasks: viewModel.allTasks)
            case .myTasks:
                Text("My Tasks View").padding()
            case .checklist:
                Text("Checklist View").padding()
            }
        }
        
        .padding(.leading, 10)
        .background(.bg)
        .environmentObject(viewSettings)
    }
}

#Preview {
    TaskBoardView()
}
