//
//  VisibleProperties.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 11.07.2025.
//

import Foundation

import SwiftUI

enum TaskProperty: String, CaseIterable, Identifiable {
    case taskName = "Task name"
    case priority = "Priority"
    case taskType = "Task type"
    case description = "Description"
    case updatedAt = "Updated at"
    case status = "Status"
    case effortLevel = "Effort level"
    case dueDate = "Due date"
    case tags = "Tags"

    var id: String { self.rawValue }

    var systemImageName: String {
        switch self {
        case .taskName: "Aa"
        case .priority: "arrow.down.circle"
        case .taskType: "folder"
        case .description: "line.3.horizontal"
        case .updatedAt: "clock"
        case .status: "sun.max"
        case .effortLevel: "hourglass"
        case .dueDate: "calendar"
        case .tags: "tag"
        }
    }
}

// Клас, який буде зберігати налаштування і повідомляти View про зміни
final class VisibleProperties: ObservableObject {
    // @Published змушує View оновлюватися при зміні цього масиву
    @Published var visibleProperties: Set<TaskProperty> = [
        .taskName, .priority, .tags // Поля, видимі за замовчуванням
    ]
}
