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
        VStack (spacing: 15){
            Image(systemName: "trash.fill")
                .frame(width: 20, height: 20)
                .font(.title)
                .foregroundColor(isTargeted ? .red : .white)
            
            Text("Drop to delete")
                .font(.caption)
                .foregroundColor(isTargeted ? .red : .gray)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(isTargeted ? Color.red.opacity(0.3) : Color.gray.opacity(0.2))
        .cornerRadius(20)
        .scaleEffect(isTargeted ? 1.1 : 1.0)
        .animation(.spring(), value: isTargeted)
        .padding()
    }
}

