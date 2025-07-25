//
//  TrashView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 25.07.2025.
//

import SwiftUI

struct TrashView: View {
    @Binding var isTargeted: Bool

    var body: some View {
        VStack {
            Image(systemName: "trash.fill")
                .font(.title)
                .foregroundColor(isTargeted ? .red : .white)
            
            Text("Drop here to delete")
                .font(.caption)
                .foregroundColor(isTargeted ? .red : .gray)
        }
        .frame(width: 200, height: 100)
        .background(isTargeted ? Color.red.opacity(0.3) : Color.gray.opacity(0.2))
        .cornerRadius(20)
        .scaleEffect(isTargeted ? 1.1 : 1.0)
        .animation(.spring(), value: isTargeted)
    }
}

