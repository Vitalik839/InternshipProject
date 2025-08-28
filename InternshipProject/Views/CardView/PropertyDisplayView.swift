//
//  PropertyDisplayView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 14.07.2025.
//

import SwiftUI

struct PropertyDisplayView: View {
    @Bindable var property: PropertyValue
    
    var body: some View {
        if let definition = property.fieldDefinition {
            switch definition.name {
            case "Status":
                LabelStatus(status: statusBinding)
                
            case "Difficulty":
                LabelDifficulty(difficulty: difficultyBinding)
                
            case "Tags":
                LabelTags(tags: tagsBinding)
                
            default:
                defaultPropertyView(definition: definition)
            }
        }
    }
    
    @ViewBuilder
    private func defaultPropertyView(definition: FieldDefinition) -> some View {
        HStack {
            Text("\(definition.name): ")
                .font(.callout)
                .foregroundColor(.gray)
            
            switch definition.type {
            case .selection:
                if let option = property.selectionValue {
                    Text(option).font(.caption.bold())
                }
            case .text:
                Text(property.stringValue ?? "").font(.callout)
            case .number:
                Text(String(format: "%.2f", property.numberValue ?? 0)).font(.callout)
            case .boolean:
                Image(systemName: (property.boolValue == true) ? "checkmark.square.fill" : "square")
                    .foregroundColor(.blue)
            case .date:
                if let date = property.dateValue {
                    Text(date.formatted(date: .abbreviated, time: .omitted)).font(.callout)
                }
            case .url:
                URLPreview(url: property.urlValue, style: .compact)

            case .multiSelection:
                let tags = property.multiSelectionValue ?? []
                
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
    
    private var statusBinding: Binding<CardStatus> {
        Binding(
            get: { CardStatus(rawValue: property.selectionValue ?? "") ?? .notStarted },
            set: { property.selectionValue = $0.rawValue }
        )
    }
    
    private var difficultyBinding: Binding<CardDifficulty> {
        Binding(
            get: { CardDifficulty(rawValue: property.selectionValue ?? "") ?? .easy },
            set: { property.selectionValue = $0.rawValue }
        )
    }
    
    private var tagsBinding: Binding<[String]> {
        Binding(
            get: { property.multiSelectionValue ?? [] },
            set: { property.multiSelectionValue = $0 }
        )
    }
}

