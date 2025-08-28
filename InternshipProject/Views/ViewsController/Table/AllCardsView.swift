//
//  AllTasksView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 08.07.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct AllCardsView: View {
    @EnvironmentObject var viewModel: CardViewModel

    let project: Project
    let cards: [Card]
    let onCardTapped: (Card) -> Void
        
    private let borderWidth: CGFloat = 1
    private let borderColor = Color.gray.opacity(0.5)
    private let rowHeight: CGFloat = 44
    private let columnWidth: CGFloat = 180
    
    private var visibleDefinitions: [FieldDefinition] {
        let titleDefinition = FieldDefinition(name: "Title", type: .text)
        
        let propertyDefinitions = project.fieldDefinitions
            .filter { viewModel.visibleCardPropertyIDs.contains($0.id) }
            .sorted { $0.name < $1.name }
        
        return [titleDefinition] + propertyDefinitions
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(visibleDefinitions) { column in
                            HStack {
                                Text(column.name).bold()
                                Spacer()
                                
                                if column.name != "Title" {
                                    Button(action: {
                                        viewModel.toggleCardPropertyVisibility(id: column.id)
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
                    
                    ForEach(cards) { card in
                        HStack(spacing: 0) {
                            ForEach(visibleDefinitions) { column in
                                if column.name == "Title" {
                                    Text(card.title)
                                        .lineLimit(1)
                                        .padding(.horizontal, 8)
                                        .frame(width: columnWidth, alignment: .leading)
                                } else {
                                    TableCellView(card: card, definition: column)
                                }
                                Rectangle().frame(width: borderWidth).foregroundColor(borderColor)
                            }
                        }
                        .draggable(card)
                        
                        .frame(height: rowHeight)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onCardTapped(card)
                        }
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
