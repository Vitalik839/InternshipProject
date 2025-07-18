//
//  CreateTask.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 09.07.2025.
//

import SwiftUI

struct CreateTask: View {
    @ObservedObject var viewModel: TaskBoardViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var newCard = TaskCard(id: UUID(), title: "", properties: [:])
    
    @State private var showDatePicker = false
    @State private var showAddPropertySheet = false
    
    let widthFrameLabel: CGFloat = 120
    
    private var addedDefinitions: [FieldDefinition] {
        viewModel.projectDefinitions
            .filter { newCard.properties.keys.contains($0.id) }
            .sorted { $0.name < $1.name }
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
                        viewModel.addNewCard(newCard)
                        dismiss()
                    }
                    .disabled(newCard.title.isEmpty) // Кнопка неактивна без заголовка
                }
            }
            .sheet(isPresented: $showAddPropertySheet) {
                AddPropertyView(
                    allDefinitions: viewModel.projectDefinitions,
                    addedDefinitionIDs: addedDefinitions.map { $0.id },
                    onSelect: { selectedDefinition in
                        addProperty(definition: selectedDefinition)
                    },
                    onCreateNewProperty: { name, type in
                        let newDefinition = viewModel.createNewFieldDefinition(name: name, type: type)
                        
                        addProperty(definition: newDefinition)
                    }
                )
            }
        }
    }
    private func addProperty(definition: FieldDefinition) {
        newCard.properties[definition.id] = getDefaultValue(for: definition.type)
    }

    private func getDefaultValue(for type: FieldType) -> FieldValue {
        switch type {
        case .text: return .text("")
        case .number: return .number(0)
        case .boolean: return .boolean(false)
        case .date: return .date(Date()) // Починаємо з порожньої дати
        case .selection: return .selection(nil)
        case .multiSelection: return .multiSelection([])
        case .url: return .url(nil)
        }
    }

}


//#Preview {
//    CreateTask(viewModel: TaskBoardViewModel(), onSave: TaskCard { _ in }-> Void)
//}
