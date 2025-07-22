//
//  AddPropertyView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 16.07.2025.
//

import SwiftUI

struct AddPropertyView: View {
    let addedFields: [FieldDefinition]
    var onComplete: (FieldDefinition) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var newPropertyName: String = ""
    // фільтруємо, щоб не показувати вже додані поля
    private let suggestedDefinitions: [FieldDefinition] = [
        FieldDefinition(name: "Status", type: .selection, selectionOptions: TaskStatus.allCases.map { $0.rawValue }),
        FieldDefinition(name: "Difficulty", type: .selection, selectionOptions: Difficulty.allCases.map { $0.rawValue }),
        FieldDefinition(name: "Tags", type: .multiSelection, selectionOptions: ["Polish", "Bug", "Feature Request"])
    ]
    private var availableSuggestedDefinitions: [FieldDefinition] {
        let addedNames = Set(addedFields.map { $0.name })
        return suggestedDefinitions.filter { !addedNames.contains($0.name) }
    }
    
    var body: some View {
        NavigationView {
            List {
                if !availableSuggestedDefinitions.isEmpty {
                    Section("Suggested") {
                        ForEach(availableSuggestedDefinitions) { definition in
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
                        Button(action: {
                            let newDefinition = FieldDefinition(name: newPropertyName, type: type)
                            onComplete(newDefinition)
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
