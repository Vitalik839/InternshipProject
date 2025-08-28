//
//  TableCellView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 15.07.2025.
//

import SwiftUI

struct TableCellView: View {
    let card: Card
    let definition: FieldDefinition
    
    @EnvironmentObject var viewModel: CardViewModel
    
    private let columnWidth: CGFloat = 180
    
    private var property: PropertyValue? {
        card.properties.first { $0.fieldDefinition?.id == definition.id }
    }
    
    var body: some View {
        VStack {
            if let property = property, !card.isFieldHidden(with: definition.id) {
                PropertyDisplayView(property: property)
            } else {
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .frame(width: columnWidth)
    }
}

