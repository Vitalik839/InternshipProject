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
    case description = "Description"
    case status = "Status"
    case dueDate = "Due date"
    case tags = "Tags"
    var id: String { self.rawValue }
    var systemImageName: String {
        switch self {
        case .taskName: "pencil"
        case .priority: "arrow.down.circle"
        case .description: "line.3.horizontal"
        case .status: "sun.max"
        case .dueDate: "calendar"
        case .tags: "tag"
        }
    }
}
final class ViewSettings: ObservableObject {
    @Published var visibleProperties: Set<TaskProperty> = [
        .taskName, .priority, .tags // Поля, видимі за замовчуванням
    ]
    @Published var searchText: String = ""
    @Published var currentMode: ViewMode = .byStatus
}
