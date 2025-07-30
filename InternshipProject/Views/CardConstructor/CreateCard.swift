//
//  CreateTask.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 09.07.2025.
//

import SwiftUI

struct CreateCard: View {
    @ObservedObject var viewModel: CardViewModel
    @Environment(\.dismiss) private var dismiss
    var onSave: (Card) -> Void
    @State private var newCard = Card(id: UUID(), title: "", properties: [:])
    
    @State private var showDatePicker = false
    @State private var showAddPropertySheet = false
    
    @State var addedDefinitions: [FieldDefinition]
    
    init(viewModel: CardViewModel, onSave: @escaping (Card) -> Void) {
        self.viewModel = viewModel
        self.onSave = onSave
        self._addedDefinitions = State(initialValue: viewModel.project.fieldDefinitions)
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
                    ForEach(addedDefinitions) { definition in
                        PropertyEditorView(
                            definition: definition,
                            value: $newCard.properties[definition.id]
                        )
                        .environmentObject(viewModel)
                        Divider().background(Color.gray.opacity(0.5))
                        
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
                    Button("Save") {
                        onSave(newCard)
                        dismiss()
                    }
                    .disabled(newCard.title.isEmpty)
                }
            }
            .sheet(isPresented: $showAddPropertySheet) {
                AddPropertyView(
                    projectFields: viewModel.projectDefinitions,
                    addedFields: addedDefinitions,
                    onComplete: { selectedDefinition in
                        if !addedDefinitions.contains(where: { $0.id == selectedDefinition.id }) {
                            addedDefinitions.append(selectedDefinition)
                        }
                        viewModel.addProperty(to: newCard.id, with: selectedDefinition)

                    }
                )
            }
        }
    }
}


//#Preview {
//    CreateCard(viewModel: TaskBoardViewModel(), onSave: TaskCard { _ in }-> Void)
//}
