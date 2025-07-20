//
//  TableCellView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 15.07.2025.
//

import SwiftUI

struct TableCellView: View {
    let card: TaskCard
    let definition: FieldDefinition
    
    private let columnWidth: CGFloat = 180
    
    var body: some View {
        let value = card.properties[definition.id]
        
        VStack {
            if let value = value {
                PropertyDisplayView(cardID: card.id, definition: definition, value: value)
            } else {
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .frame(width: columnWidth)
    }
}

