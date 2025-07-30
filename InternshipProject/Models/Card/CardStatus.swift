//
//  TaskStatus.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 13.07.2025.
//

import Foundation
import SwiftUI

enum CardStatus: String, CaseIterable, Codable, Hashable {
    case notStarted = "Not started"
    case inProgress = "In progress"
    case done = "Done"
    
    var titleColumn: String {
        self.rawValue
    }
    
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
