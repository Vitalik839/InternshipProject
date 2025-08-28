//
//  CardDetailView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 21.07.2025.
//

import SwiftUI
import SwiftData

struct CardDetailView: View {
    @Bindable var card: Card
    
    @EnvironmentObject var viewModel: CardViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var showAddPropertySheet = false

    private var sortedProperties: [PropertyValue] {
        card.properties.sorted {
            ($0.fieldDefinition?.name ?? "") < ($1.fieldDefinition?.name ?? "")
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TextField("Card Title", text: $card.title)
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Divider()

                    ForEach(sortedProperties) { property in
                        if let definition = property.fieldDefinition {
                            HStack(spacing: 12) {
                                PropertyEditorView(property: property)
                                
                                Button(action: {
                                    viewModel.toggleVisibility(for: card, definition: definition)
                                }) {
                                    Image(systemName: card.isFieldHidden(with: definition.id) ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(.plain)
                                
                                Button(action: {
                                    viewModel.removeProperty(property)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(.plain)
                            }
                            Divider()
                        }
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
                if let project = card.project {
                    AddPropertyView(
                        suggestedDefinitions: project.fieldDefinitions,
                        addedDefinitions: card.properties.compactMap { $0.fieldDefinition },
                        onComplete: { definition in
                            viewModel.addProperty(to: card, basedOn: definition, in: project)
                        }
                    )
                }
            }
        }
    }
}

//#Preview {
//    @State var card = Card(id: UUID(), title: "Test Card", properties: [:])
//    
//    let project = Project(name: "Test Project", fieldDefinitions: [], cards: [card])
//    let viewModel = CardViewModel(project: project)
//
//    return CardDetailView(card: $card)
//        .environmentObject(viewModel)
//}
