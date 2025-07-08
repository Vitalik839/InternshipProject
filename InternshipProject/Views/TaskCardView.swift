//
//  TaskCardView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 03.07.2025.
//

import SwiftUI

struct TaskCardView: View {
    @State var task: TaskCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(task.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                HStack(spacing: 8) {
                    Button(action: {
                        // редагування
                    }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Button(action: {
                        // меню
                    }) {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            LabelDifficulty(task: task)
            LabelTags(tags: task.tags)
            
            if task.commentCount > 0 {
                HStack {
                    Image(systemName: "bubble.left")
                    Text("\(task.commentCount)")
                        .font(.caption)
                }
                .foregroundColor(.gray)
                .padding(.top, 4)
            }
        }
        .padding()
        .background(task.status.colorTask)
        .cornerRadius(16)
        .frame(width: 280)
    }
}


#Preview {
    TaskCardView( task: TaskCard(id: UUID(), title: "My task",
                  priority: .hard,
                  tags: ["Self"],
                  commentCount: 2,
                  status: .notStarted)
    )
}
