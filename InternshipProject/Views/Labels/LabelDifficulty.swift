//
//  LabelDifficulty.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 08.07.2025.
//

import SwiftUI

struct LabelDifficulty: View {
    @State var difficulty: Difficulty
    @StateObject private var viewModel = TaskBoardViewModel()
    var body: some View {
        Menu {
            ForEach(Difficulty.allCases, id: \.self) { level in
                Button(action: {
                    difficulty = level
                }) {
                    Text(level.rawValue)
                }
            }
        } label: {
            Text(difficulty.rawValue)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(difficulty.color)
                .foregroundColor(.white)
                .cornerRadius(6)
        }
    }
}
