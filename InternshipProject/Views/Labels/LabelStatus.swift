//
//  LabelStatus.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 08.07.2025.
//

import SwiftUI

struct LabelStatus: View {
    @Binding var status: CardStatus

    var body: some View {
        Menu {
            ForEach(CardStatus.allCases, id: \.self) { newStatus in
                Button(newStatus.rawValue) {
                    self.status = newStatus
                }
            }
        } label: {
            HStack {
                Text(status.rawValue)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
            }
            .background(status.colorTask)
            .cornerRadius(8)
        }
    }
}
