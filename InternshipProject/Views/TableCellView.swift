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
    
    // Ширина колонки, може бути налаштована
    private let columnWidth: CGFloat = 180
    
    var body: some View {
        // Знаходимо значення для цього поля у картці
        let value = card.properties[definition.id]
        
        VStack {
            if let value = value {
                // Якщо значення існує, використовуємо наш PropertyDisplayView,
                // який вже вміє гарно показувати всі типи даних.
                PropertyDisplayView(definition: definition, value: value)
            } else {
                // Якщо у картки немає такого поля, комірка буде порожньою.
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .frame(width: columnWidth)
    }
}

