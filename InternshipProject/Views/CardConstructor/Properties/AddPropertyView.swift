//
//  AddPropertyView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 16.07.2025.
//

import SwiftUI

struct IdentifiableOption: Identifiable {
    let id = UUID()
    var text: String = ""
}

struct AddPropertyView: View {
    let suggestedDefinitions: [FieldDefinition]
    let addedDefinitions: [FieldDefinition]
    let onComplete: (FieldDefinition) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var newPropertyName: String = ""
    
    private var availableSuggestedDefinitions: [FieldDefinition] {
        let addedNames = Set(addedDefinitions.map { $0.name })
        return suggestedDefinitions.filter { !addedNames.contains($0.name) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    if !availableSuggestedDefinitions.isEmpty {
                        Section("Suggested Properties") {
                            ForEach(availableSuggestedDefinitions, id: \.name) { definition in
                                Button(definition.name) {
                                    onComplete(definition)
                                    dismiss()
                                }
                            }
                        }
                    }
                    
                    TextField("Property Name", text: $newPropertyName)
                    
                    Section("Property Types") {
                        ForEach(FieldType.allCases, id: \.self) { type in
                            if type == .selection || type == .multiSelection {
                                NavigationLink(value: type) {
                                    Text(type.rawValue.capitalized)
                                }
                                .disabled(newPropertyName.trimmingCharacters(in: .whitespaces).isEmpty)
                            } else {
                                Button(type.rawValue.capitalized) {
                                    let newDefinition = FieldDefinition(name: newPropertyName, type: type)
                                    onComplete(newDefinition)
                                    dismiss()
                                }
                                .disabled(newPropertyName.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                        }
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
            .navigationDestination(for: FieldType.self) { type in
                SelectionEditor(
                    propertyName: newPropertyName,
                    type: type,
                    isNameEmpty: newPropertyName.trimmingCharacters(in: .whitespaces).isEmpty,
                    onSave: { options in
                        let newDefinition = FieldDefinition(
                            name: newPropertyName,
                            type: type,
                            selectionOptions: options
                        )
                        onComplete(newDefinition)
                        dismiss()
                    }
                )
            }
        }
    }
}

//#Preview {
//    AddPropertyView()
//}
