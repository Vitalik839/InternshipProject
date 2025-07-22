//
//  AllTasksView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 08.07.2025.
//

import SwiftUI

struct AllCardsView: View {
    @ObservedObject var viewModel: CardViewModel

    // Константи залишаються ті ж самі
    private let borderWidth: CGFloat = 1
    private let borderColor = Color.gray.opacity(0.5)
    private let rowHeight: CGFloat = 44
    private let columnWidth: CGFloat = 180

    private var visibleDefinitions: [FieldDefinition] {
        let titleDefinition = FieldDefinition(name: "Title", type: .text)
        
        // Фільтруємо основні визначення і сортуємо їх
        let filtered = viewModel.project.fieldDefinitions
            .filter { viewModel.visibleCardPropertyIDs.contains($0.id) }
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
                                        viewModel.toggleCardPropertyVisibility(id: definition.id)
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
                    
                    ForEach(viewModel.project.cards) { card in
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
//#Preview {
//    AllTasksView(viewModel: TaskBoardViewModel())
//}
