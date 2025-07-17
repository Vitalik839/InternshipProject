//
//  AddPropertyView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 16.07.2025.
//

import SwiftUI

struct AddPropertyView: View {
    let allDefinitions: [FieldDefinition]
    let addedDefinitionIDs: [UUID]
    var onSelect: (FieldDefinition) -> Void
    var onCreateNewProperty: (String, FieldType) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var newPropertyName: String = ""
    // фільтруємо, щоб не показувати вже додані поля
    private var availableDefinitions: [FieldDefinition] {
        allDefinitions.filter { !addedDefinitionIDs.contains($0.id) }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("Suggested") {
                    ForEach(availableDefinitions) { definition in
                        Button(definition.name) {
                            onSelect(definition)
                            dismiss()
                        }
                    }
                }
                
                TextField("Property Name", text: $newPropertyName)

                Section("Property Types") {
                    ForEach(FieldType.allCases, id: \.self) { type in
                        Button(action: {
                            onCreateNewProperty(newPropertyName, type)
                            dismiss()
                        }) {
                            Text(type.rawValue.capitalized)
                        }
                        // неактивно, якщо назва порожня
                        .disabled(newPropertyName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .navigationTitle("Add Property")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

//#Preview {
//    AddPropertyView()
//}
