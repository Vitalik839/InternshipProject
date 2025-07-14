//
//  TaskCardView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 03.07.2025.
//

import SwiftUI

struct TaskCardView: View {
    @EnvironmentObject var settings: ViewSettings
    let task: TaskCard
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                if settings.visibleProperties.contains(.taskName) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(task.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
            if settings.visibleProperties.contains(.priority) {
                LabelDifficulty(difficulty: task.difficulty)
            }
            if settings.visibleProperties.contains(.tags) {
                LabelTags(tags: task.tags)
            }
        }
        .padding()
        .background(task.status.colorTask)
        .cornerRadius(16)
        .frame(width: 280)
    }
}


//#Preview {
//    TaskCardView( task: TaskCard(id: UUID(), properties: [
//        Property(name: "Task Name", type: .text, value: .text("Premiere pro Caba Videos Edit")),
//        Property(name: "Priority", type: .selection, value: .selection("Hard"), selectionOptions: Difficulty.allCases.map(\.rawValue)),
//        Property(name: "Tags", type: .selection, value: .selection("Polish,Bug"), selectionOptions: ["Polish", "Bug", "Tech"]),
//        Property(name: "Status", type: .selection, value: .selection("To Do"), selectionOptions: ["To Do", "In Progress", "Done"])
//    ])
//    ).environmentObject(ViewSettings())
//}
