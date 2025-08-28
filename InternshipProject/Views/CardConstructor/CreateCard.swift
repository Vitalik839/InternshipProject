//
//  CreateTask.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 09.07.2025.
//

import SwiftUI
import SwiftData

struct CreateCard: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: CardViewModel

    @State private var newCard: Card
    @State private var addedDefinitions: [FieldDefinition]
    let project: Project

    @State private var showAddPropertySheet = false
    
    init(project: Project) {
        self.project = project
        let card = Card(title: "", project: project)
        let definitions = project.fieldDefinitions
        
        for definition in project.fieldDefinitions {
            let property = PropertyValue(card: card, fieldDefinition: definition)
            card.properties.append(property)
        }
        
        self._newCard = State(initialValue: card)
        self._addedDefinitions = State(initialValue: definitions)

    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable().foregroundColor(.green).frame(width: 36, height: 36)
                        
                        TextField("New task", text: $newCard.title)
                            .font(.title).foregroundColor(.white)
                    }
                    .padding(.bottom)
                    ForEach(newCard.properties) { definition in
                        if let property = newCard.properties.first(where: { $0.fieldDefinition?.id == definition.id }) {
                            
                            PropertyEditorView(property: property)
                            Divider().background(Color.gray.opacity(0.5))
                        }
                        
                    }
                    
                    Button(action: { showAddPropertySheet = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Property")
                                .bold()
                        }
                        .foregroundColor(.gray)
                    }
                    .padding(.top, 8)
                }
                .foregroundStyle(.gray)
                .padding()
            }
            .background(Color("bg"))
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveCard)
                        .disabled(newCard.title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .disabled(newCard.title.isEmpty)
                }
            }
            .sheet(isPresented: $showAddPropertySheet) {
                AddPropertyView(
                    suggestedDefinitions: project.fieldDefinitions,
                    addedDefinitions: addedDefinitions,
                    onComplete: { selectedDefinition in
                        if !addedDefinitions.contains(where: { $0.id == selectedDefinition.id }) {
                            addedDefinitions.append(selectedDefinition)
                        }
                        
                        if !newCard.properties.contains(where: { $0.fieldDefinition?.id == selectedDefinition.id }) {
                            let property = PropertyValue(card: newCard, fieldDefinition: selectedDefinition)
                            newCard.properties.append(property)
                        }
                    }
                )
            }
        }
    }
    private func saveCard() {
        modelContext.insert(newCard)
        dismiss()
    }
}


//#Preview {
//    CreateCard(viewModel: TaskBoardViewModel(), onSave: TaskCard { _ in }-> Void)
//}
