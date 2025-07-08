//
//  TaskRowView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 08.07.2025.
//

import SwiftUI

struct TaskRowView: View {
    let task: TaskCard

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            // Назва завдання
            Text(task.title)
                .font(.headline)
            
            Spacer() // Цей елемент розштовхне назву і теги по краях
            
            LabelDifficulty(task: task)
            
            HStack(spacing: 6) {
                LabelTags(tags: task.tags)
            }
        }
        .padding(.vertical, 10) // Вертикальний відступ для кожного рядка
    }
}
