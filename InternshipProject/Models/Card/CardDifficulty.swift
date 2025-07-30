//
//  TaskDifficulty.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 13.07.2025.
//

import Foundation
import SwiftUI

enum CardDifficulty: String, CaseIterable, Codable, Hashable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var titleColumn: String {
        self.rawValue
    }
    
    var color: Color {
        switch self {
        case .easy: return Color(.easy)
        case .medium: return Color(.medium)
        case .hard: return Color(.hard)
        }
    }
}
