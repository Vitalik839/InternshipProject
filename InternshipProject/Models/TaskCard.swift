//
//  Card.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum TaskStatus: String, CaseIterable, Codable, Hashable {
    case notStarted = "Not started"
    case inProgress = "In progress"
    case done = "Done"
    
    var color: Color {
        switch self {
        case .notStarted: return .bgTaskNotStarted
        case .inProgress: return .bgTaskInProgress
        case .done: return .bgTaskDone
        }
    }
    
    var colorTask: Color {
        switch self {
        case .notStarted: return .taskNotStarted
        case .inProgress: return .taskInProgress
        case .done: return .taskDone
        }
    }
}

struct TaskCard: Identifiable, Hashable, Codable, Transferable {
    var id: UUID
    var title: String
    var priority: Priority
    var tags: [String]
    var commentCount: Int
    var status: TaskStatus
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .taskCard)
    }
}


extension UTType {
    static let taskCard = UTType(exportedAs: "com.vitalik.taskcard")
}


extension Color {
    init(hex: Int, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: opacity
        )
    }
}

