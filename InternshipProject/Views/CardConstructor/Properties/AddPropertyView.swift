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
    let projectFields: [FieldDefinition]
    let addedFields: [FieldDefinition]
    var onComplete: (FieldDefinition) -> Void

    @Environment(\.dismiss) private var dismiss
    
    @State private var newPropertyName: String = ""
    @State private var selectionTypeToConfigure: FieldType?
    @State private var isNavigationActive = false
    
    private var availableSuggestedDefinitions: [FieldDefinition] {
        let addedNames = Set(addedFields.map { $0.name })
        return projectFields.filter { !addedNames.contains($0.name) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
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
                                handleTypeSelection(type)
                            }) {
                                HStack {
                                    Text(type.rawValue.capitalized)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .disabled(newPropertyName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
                if let type = selectionTypeToConfigure {
                    NavigationLink(
                        destination: SelectionEditor(
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
                        ),
                        isActive: $isNavigationActive,
                        label: { EmptyView() }
                    )
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
    
    private func handleTypeSelection(_ type: FieldType) {
        if type == .selection || type == .multiSelection {
            selectionTypeToConfigure = type
            isNavigationActive = true
        } else {
            let newDefinition = FieldDefinition(name: newPropertyName, type: type)
            onComplete(newDefinition)
            dismiss()
        }
    }
}

//#Preview {
//    AddPropertyView()
//}
