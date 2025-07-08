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
    
    @State private var allTasks: [TaskCard] = [
        TaskCard(id: UUID(), title: "Premiere pro Caba Videos Edit", priority: .hard, tags: ["Polish", "Bug"], commentCount: 0, status: .notStarted),
        TaskCard(id: UUID(), title: "BCOLA138 Study", priority: .easy, tags: ["Learn"], commentCount: 0, status: .notStarted),
        TaskCard(id: UUID(), title: "E-commerce Study", priority: .medium, tags: ["Learn"], commentCount: 0, status: .notStarted),
        TaskCard(id: UUID(), title: "Song finalising", priority: .medium, tags: ["Self"], commentCount: 0, status: .inProgress),
        TaskCard(id: UUID(), title: "Learn Fonts", priority: .medium, tags: ["Self"], commentCount: 0, status: .inProgress),
        TaskCard(id: UUID(), title: "My Task", priority: .medium, tags: ["Tech", "Polish"], commentCount: 1, status: .done),
        TaskCard(id: UUID(), title: "Premiere pro Caba Videos Edit", priority: .hard, tags: ["Polish", "Bug"], commentCount: 0, status: .notStarted),
        TaskCard(id: UUID(), title: "Premiere pro Caba Videos Edit", priority: .hard, tags: ["Polish", "Bug"], commentCount: 0, status: .notStarted)
    ]
    
    var body: some View {
        VStack(alignment: .leading){
            Toolbar(selectedMode: $currentMode, searchText: $searchText)
            
            switch currentMode {
            case .byStatus:
                ScrollView([.horizontal, .vertical]) {
                    HStack(alignment: .top, spacing: 8) {
                        ForEach(TaskStatus.allCases, id: \.self) { status in
                            TaskColumnView(
                                status: status,
                                tasks: allTasks.filter { $0.status == status }
                                    .filter { searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) },
                                onTaskDropped: { droppedTask in
                                    if let index = allTasks.firstIndex(where: { $0.id == droppedTask.id }) {
                                        allTasks[index].status = status
                                    }
                                    print("Dropped task: \(droppedTask.title) → \(status.rawValue)")
                                    
                                }
                            )
                        }
                    }
                }
            case .all:
                AllTasksView(tasks: allTasks)
            case .myTasks:
                Text("My Tasks View").padding()
            case .checklist:
                Text("Checklist View").padding()
            }
        }
        .padding(.leading, 10)
        .background(.bg)
    }
}


#Preview {
    TaskBoardView()
}
