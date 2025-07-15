//
//  PropertyDisplayView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 14.07.2025.
//

import SwiftUI

struct PropertyDisplayView: View {
    let definition: FieldDefinition
    let value: FieldValue

    var body: some View {
        // Перевіряємо, чи є ця властивість однією з наперед визначених
        switch definition.name {
        case "Status":
            if case .selection(let option) = value, let statusString = option, let status = TaskStatus(rawValue: statusString) {
                LabelStatus(status: status)
            }
            
        case "Difficulty":
             if case .selection(let option) = value, let difficultyString = option, let difficulty = Difficulty(rawValue: difficultyString) {
                LabelDifficulty(difficulty: difficulty)
            }

        case "Tags":
            // Примітка: для повноцінної підтримки кількох тегів краще мати тип .multiSelection,
            // але для інтеграції покажемо один тег.
            if case .selection(let option) = value, let tag = option {
                LabelTags(tags: [tag]) // Передаємо тег як масив з одного елемента
            }
            
        default:
            defaultPropertyView
        }
    }
    
    // Стандартне відображення для всіх інших (неспеціальних) полів
    @ViewBuilder
    private var defaultPropertyView: some View {
        HStack {
            Text("\(definition.name): ")
                .font(.callout)
                .foregroundColor(.gray)
            
            
            switch value {
            case .selection(let option):
                if let option = option {
                    Text(option)
                        .font(.caption.bold())
                }
            case .text(let text):
                Text(text)
                    .font(.callout)
            case .number(let number):
                Text(String(format: "%.2f", number))
                    .font(.callout)
            case .boolean(let bool):
                Image(systemName: bool ? "checkmark.square.fill" : "square")
                    .foregroundColor(.blue)
            case .date(let date):
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.callout)
            case .url(let url):
                if let url = url {
                    Text(url.host ?? "Link")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

