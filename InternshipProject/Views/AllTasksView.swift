//
//  AllTasksView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 08.07.2025.
//

import SwiftUI

struct AllTasksView: View {
    @ObservedObject var viewModel: TaskBoardViewModel

    // Константи залишаються ті ж самі
    private let borderWidth: CGFloat = 1
    private let borderColor = Color.gray.opacity(0.5)
    private let rowHeight: CGFloat = 44
    private let columnWidth: CGFloat = 180

    private var visibleDefinitions: [FieldDefinition] {
        // Створюємо фіктивне визначення для "Title", щоб він завжди був у списку
        let titleDefinition = FieldDefinition(name: "Title", type: .text)
        
        // Фільтруємо основні визначення і сортуємо їх
        let filtered = viewModel.projectDefinitions
            .filter { viewModel.visibleDefinitionIDs.contains($0.id) }
            .sorted { $0.name < $1.name }
            
        return [titleDefinition] + filtered
    }

    var body: some View {
        VStack {
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(visibleDefinitions) { definition in
                            HStack {
                                Text(definition.name).bold()
                                Spacer()
                                
                                if definition.name != "Title" {
                                    Button(action: {
                                        viewModel.hideDefinition(id: definition.id)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                            .frame(width: columnWidth)
                            
                            Rectangle().frame(width: borderWidth).foregroundColor(borderColor)
                        }
                    }
                    .frame(height: rowHeight)
                    .background(Color.gray.opacity(0.2))
                    
                    Rectangle().frame(height: borderWidth).foregroundColor(borderColor)
                    
                    // --- Рядки таблиці, які тепер теж динамічні ---
                    ForEach(viewModel.allCards) { card in
                        HStack(spacing: 0) {
                            ForEach(visibleDefinitions) { definition in
                                if definition.name == "Title" {
                                    Text(card.title)
                                        .lineLimit(1)
                                        .padding(.horizontal, 8)
                                        .frame(width: columnWidth, alignment: .leading)
                                } else {
                                    TableCellView(card: card, definition: definition)
                                }
                                Rectangle().frame(width: borderWidth).foregroundColor(borderColor)
                            }
                        }
                        .frame(height: rowHeight)
                        Rectangle().frame(height: borderWidth).foregroundColor(borderColor)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color("bg"))
        .foregroundStyle(.white)
    }
}
#Preview {
    AllTasksView(viewModel: TaskBoardViewModel())
}
