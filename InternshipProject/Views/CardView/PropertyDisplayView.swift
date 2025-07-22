//
//  PropertyDisplayView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 14.07.2025.
//

import SwiftUI

struct PropertyDisplayView: View {
    @EnvironmentObject var viewModel: CardViewModel
    
    let cardID: UUID
    let definition: FieldDefinition
    let value: FieldValue
    
    var body: some View {
        switch definition.name {
        case "Status":
            LabelStatus(status: statusBinding)
            
        case "Difficulty":
            LabelDifficulty(difficulty: difficultyBinding)
            
        case "Tags":
            LabelTags(tags: tagsBinding)
            
        default:
            defaultPropertyView
        }
    }
    
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
                URLPreview(url: url, style: .compact)

            case .multiSelection(let tags):
                if tags.isEmpty {
                    Text("Empty").foregroundColor(.gray)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.5))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    private var difficultyBinding: Binding<Difficulty> {
        Binding<Difficulty>(
            get: {
                if case .selection(let option) = value,
                   let difficulty = Difficulty(rawValue: option ?? "") {
                    return difficulty
                }
                return .easy // за замовчуванням
            },
            set: { newDifficulty in
                let newValue = FieldValue.selection(newDifficulty.rawValue)
                viewModel.updateProperty(
                    for: cardID,
                    definitionID: definition.id,
                    newValue: newValue
                )
            }
        )
    }
    private var statusBinding: Binding<TaskStatus> {
        Binding<TaskStatus>(
            get: {
                if case .selection(let option) = value,
                   let status = TaskStatus(rawValue: option ?? "") {
                    return status
                }
                return .notStarted
            },
            set: { newStatus in
                let newValue = FieldValue.selection(newStatus.rawValue)
                viewModel.updateProperty(
                    for: cardID,
                    definitionID: definition.id,
                    newValue: newValue
                )
            }
        )
    }
    private var tagsBinding: Binding<[String]> {
        Binding<[String]>(
            get: {
                if case .multiSelection(let tags) = value {
                    return tags
                }
                return []
            },
            set: { newTags in
                let newValue = FieldValue.multiSelection(newTags)
                viewModel.updateProperty(
                    for: cardID,
                    definitionID: definition.id,
                    newValue: newValue
                )
            }
        )
    }
}

