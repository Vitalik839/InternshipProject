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
        viewModel.project.fieldDefinitions
            .filter { card.properties.keys.contains($0.id) }
            .sorted { $0.name < $1.name }
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
                        PropertyEditorView(
                            definition: definition,
                            value: $card.properties[definition.id]
                        )
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
                 // Тут використовується існуючий AddPropertyView
                 // для додавання нових полів до цієї конкретної картки
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
