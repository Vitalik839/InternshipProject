//
//  LabelDifficulty.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 08.07.2025.
//

import SwiftUI

enum Priority: String, CaseIterable, Codable, Hashable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var color: Color {
        switch self {
        case .easy: return Color(hex: 0x3C6752)
        case .medium: return Color(hex: 0x8B744A)
        case .hard: return Color(hex: 0x8B4F4F)
        }
    }
}

struct LabelDifficulty: View {
    @State var task: TaskCard

    var body: some View {
        Menu {
            ForEach(Priority.allCases, id: \.self) { level in
                Button(action: {
                    task.priority = level
                }) {
                    Text(level.rawValue)
                }
            }
        } label: {
            Text(task.priority.rawValue)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(task.priority.color)
                .foregroundColor(.white)
                .cornerRadius(6)
        }
    }
}
