//
//  AllTasksView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 08.07.2025.
//

import SwiftUI

struct AllTasksView: View {
    let tasks: [TaskCard]
    
    private let titleWidth: CGFloat = 250
    private let dateWidth: CGFloat = 120
    private let priorityWidth: CGFloat = 130
    private let statusWidth: CGFloat = 170
    private let typeWidth: CGFloat = 200
    
    // Константи для рамок
    private let borderWidth: CGFloat = 1
    private let borderColor = Color.gray.opacity(0.5)
    
    // Висота рядка
    private let rowHeight: CGFloat = 44
    
    
    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text("Title")
                        .frame(width: titleWidth)
                    
                    Text("Due date")
                        .frame(width: dateWidth)
                    
                    Text("Priority")
                        .frame(width: priorityWidth)
                    
                    Text("Status")
                        .frame(width: statusWidth)
                    
                    Text("Task type")
                        .frame(width: typeWidth)
                }
                .bold()
                .frame(height: rowHeight)
                
                Rectangle().frame(height: borderWidth).foregroundColor(borderColor)

                ForEach(tasks) { task in
                    HStack(spacing: 0) {
                        Text(task.title).lineLimit(1)
                            .frame(width: titleWidth)
                        
                        Rectangle().frame(width: borderWidth).foregroundColor(borderColor)
                        
                        Text("07/08/2025")
                            .frame(width: dateWidth)
                        
                        Rectangle().frame(width: borderWidth).foregroundColor(borderColor)
                        
                        LabelDifficulty(task: task)
                            .frame(width: priorityWidth)
                        
                        Rectangle().frame(width: borderWidth).foregroundColor(borderColor)
                        
                        LabelStatus(status: task.status)
                            .frame(width: statusWidth)
                        
                        Rectangle().frame(width: borderWidth).foregroundColor(borderColor)
                        
                        LabelTags(tags: task.tags)
                            .frame(width: typeWidth)
                    }
                    .frame(height: rowHeight)
                    
                    Rectangle().frame(height: borderWidth).foregroundColor(borderColor)
                }
            }
            Spacer(minLength: 300)
        }
        .background(.bg)
        .foregroundStyle(.white)
    }
}

#Preview {
    AllTasksView(tasks: [
        TaskCard(id: UUID(), title: "Premiere pro Caba Videos Edit", priority: .hard, tags: ["Polish", "Bug"], commentCount: 0, status: .notStarted),
        TaskCard(id: UUID(), title: "BCOLA138 Study", priority: .easy, tags: ["Learn"], commentCount: 0, status: .notStarted),
        TaskCard(id: UUID(), title: "E-commerce Study", priority: .medium, tags: ["Learn"], commentCount: 0, status: .notStarted),
        TaskCard(id: UUID(), title: "Song finalising", priority: .medium, tags: ["Self"], commentCount: 0, status: .inProgress),
        TaskCard(id: UUID(), title: "Learn Fonts", priority: .medium, tags: ["Self"], commentCount: 0, status: .inProgress),
        TaskCard(id: UUID(), title: "My Task", priority: .medium, tags: ["Tech", "Polish"], commentCount: 1, status: .done),
        TaskCard(id: UUID(), title: "Premiere pro Caba Videos Edit", priority: .hard, tags: ["Polish", "Bug"], commentCount: 0, status: .notStarted),
        TaskCard(id: UUID(), title: "Premiere pro Caba Videos Edit", priority: .hard, tags: ["Polish", "Bug"], commentCount: 0, status: .notStarted)
    ])
}
