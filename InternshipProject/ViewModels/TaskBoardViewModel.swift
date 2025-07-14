//
//  TaskBoardViewModel.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 12.07.2025.
//

import Foundation
import SwiftUI

@MainActor
final class TaskBoardViewModel: ObservableObject {
    enum Grouping: String, CaseIterable {
        case byStatus = "Status"
        case byDifficulty = "Difficulty"
        case byTag = "Tags"
    }
    @Published var grouping: Grouping = .byStatus
    @Published var searchText: String = ""
    @Published var allTasks: [TaskCard] = [
        TaskCard(id: UUID(), title: "Premiere pro Caba Videos Edit", difficulty: .hard, tags: ["Polish", "Bug"], status: .notStarted),
        TaskCard(id: UUID(), title: "Premiere pro Caba Videos Edit", difficulty: .hard, tags: ["Polish", "Bug"], status: .notStarted),
        TaskCard(id: UUID(), title: "Premiere pro Caba Videos Edit", difficulty: .hard, tags: ["Polish", "Bug"], status: .notStarted),
        TaskCard(id: UUID(), title: "Premiere pro Caba Videos Edit", difficulty: .hard, tags: ["Polish", "Bug"], status: .notStarted),
        TaskCard(id: UUID(), title: "Premiere pro Caba Videos Edit", difficulty: .hard, tags: ["Polish", "Bug"], status: .inProgress)
    ]
    
    // ✅ Створюємо обчислювальну властивість для відфільтрованих завдань
    private var filteredTasks: [TaskCard] {
        if searchText.isEmpty {
            return allTasks
        } else {
            return allTasks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var currentGroupKeys: [any GroupableProperty] {
        switch grouping {
        case .byStatus:
            return TaskStatus.allCases
        case .byDifficulty:
            return Difficulty.allCases
        case .byTag:
            // Ось ключова логіка:
            // 1. flatMap збирає всі теги з усіх завдань в один великий масив.
            let allTags = allTasks.flatMap { $0.tags }
            return Array(Set(allTags)).sorted()
        }
    }
    func tasks(for group: any GroupableProperty) -> [TaskCard] {
        if let status = group as? TaskStatus {
            return filteredTasks.filter { $0.status == status }
        }
        if let difficulty = group as? Difficulty {
            return filteredTasks.filter { $0.difficulty == difficulty }
        }
        if let tag = group as? String {
            // Повертаємо завдання, які містять цей тег
            return filteredTasks.filter { $0.tags.contains(tag) }
        }
        return []
    }
    
    // ✅ Універсальна функція для обробки Drag and Drop
    func handleDrop(of task: TaskCard, on group: any GroupableProperty) {
        guard let index = allTasks.firstIndex(where: { $0.id == task.id }) else { return }
        withAnimation {
            if let newStatus = group as? TaskStatus {
                allTasks[index].status = newStatus
            } else if let newDifficulty = group as? Difficulty {
                allTasks[index].difficulty = newDifficulty
            } else if let newTag = group as? String {
                // Якщо такого тега ще немає, додаємо його
                if !allTasks[index].tags.contains(newTag) {
                    allTasks[index].tags.append(newTag)
                }
            }
        }
    }
}
