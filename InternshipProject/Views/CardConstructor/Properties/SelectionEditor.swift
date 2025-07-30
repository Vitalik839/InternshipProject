//
//  SelectionEditor.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 30.07.2025.
//

import SwiftUI

struct SelectionEditor: View {
    let propertyName: String
    let type: FieldType
    let isNameEmpty: Bool
    var onSave: ([String]) -> Void

    @State private var options: [IdentifiableOption] = [IdentifiableOption()]

    var body: some View {
        Form {
            Section(header: Text("Options")) {
                ForEach($options) { $option in
                    TextField("Option name", text: $option.text)
                }
                .onDelete { indexSet in
                    options.remove(atOffsets: indexSet)
                }
                Button(action: {
                    options.append(IdentifiableOption())
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Option")
                    }
                }
            }
        }
        .navigationTitle("Edit \(type.rawValue.capitalized)")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let finalOptions = options
                        .map { $0.text.trimmingCharacters(in: .whitespaces) }
                        .filter { !$0.isEmpty }
                    onSave(finalOptions)
                }
                .disabled(isNameEmpty || options.allSatisfy { $0.text.trimmingCharacters(in: .whitespaces).isEmpty })
            }
        }
    }
}
