//
//  LabelStatus.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 08.07.2025.
//

import SwiftUI

struct LabelStatus: View {
    let status: TaskStatus

    var body: some View {
        HStack {
            Circle()
                .fill(.white)
                .frame(width: 8, height: 8)
                .padding(.leading)
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

#Preview {
    LabelStatus(status: .done)
}
