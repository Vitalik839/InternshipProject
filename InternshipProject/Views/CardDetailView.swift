//
//  CardDetailView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 21.07.2025.
//

import SwiftUI

struct CardDetailView: View {
    @Binding var card: Card

    @EnvironmentObject var viewModel: CardViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var showAddPropertySheet = false

    private var displayedFields: [FieldDefinition] {
        let fieldIDsInCard = card.properties.keys
        return fieldIDsInCard.compactMap { fieldID in
            viewModel.project.fieldDefinitions.first { $0.id == fieldID }
        }
        .sorted { $0.name < $1.name } // Сортуємо для краси
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TextField("Card Title", text: $card.title)
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Divider()

                    ForEach(displayedFields) { definition in
                        HStack(spacing: 12) {
                            PropertyEditorView(
                                definition: definition,
                                value: $card.properties[definition.id]
                            )
                            Button(action: {
                                viewModel.toggleVisibility(for: card.id, definitionID: definition.id)
                            }) {
                                Image(systemName: card.hiddenFieldIDs.contains(definition.id) ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                            .buttonStyle(.plain)
                            Button(action: {
                                viewModel.removeProperty(from: card.id, with: definition.id)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .buttonStyle(.plain)
                        }
                        Divider()
                    }

                    Button(action: { showAddPropertySheet = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Property").bold()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Card Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showAddPropertySheet) {
                 AddPropertyView(
                    addedFields: displayedFields,
                    onComplete: { definition in
                        if !viewModel.project.fieldDefinitions.contains(where: { $0.id == definition.id }) {
                            viewModel.project.fieldDefinitions.append(definition)
                            viewModel.projectDefinitions.append(definition)
                        }
                        card.properties[definition.id] = viewModel.getDefaultValue(for: definition.type)

                    }
                 )
            }
        }
    }
}

#Preview {
    @State var card = Card(id: UUID(), title: "Test Card", properties: [:])
    
    let project = Project(name: "Test Project", fieldDefinitions: [], cards: [card])
    let viewModel = CardViewModel(project: project)

    return CardDetailView(card: $card)
        .environmentObject(viewModel)
}
