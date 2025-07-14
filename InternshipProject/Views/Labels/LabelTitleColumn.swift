//
//  LabelTitleColumn.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 12.07.2025.
//

import SwiftUI

struct LabelTitleColumn: View {
    let title: String
    let colorBg: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(.white)
                .frame(width: 8, height: 8)
                .padding(.leading)
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.trailing, 15)
                .padding(.leading, 4)
                .padding(.vertical, 5)
        }
        .background(colorBg)
        .cornerRadius(8)
        
    }
}

#Preview {
    LabelTitleColumn(title: "test", colorBg: .green)
}
