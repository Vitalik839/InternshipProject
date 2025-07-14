//
//  TaskCardOperation.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 11.07.2025.
//

import Foundation

class TaskCardOperation: ObservableObject {
    @Published var taskCards: [TaskCard] = []
    
    func addTaskCard(_ taskCard: TaskCard) {
        taskCards.append(taskCard)
    }
}
