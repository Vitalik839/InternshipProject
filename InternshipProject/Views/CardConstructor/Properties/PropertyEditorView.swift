//
//  PropertyEditorView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 16.07.2025.
//

import SwiftUI

struct PropertyEditorView: View {
    @Bindable var property: PropertyValue
    
    @EnvironmentObject var viewModel: CardViewModel
    
    @State private var showDatePicker = false
    @State private var isShowingAddOptionAlert = false
    @State private var newOptionText = ""
    
    var body: some View {
        if let definition = property.fieldDefinition {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "circle.fill")
                    .foregroundColor(.gray)
                Text(definition.name)
                
                Spacer()

                editor(for: definition)
                    .foregroundStyle(.white)
            }
        } else {
            Text("Error: Property has no definition.")
        }
    }
    
    @ViewBuilder
    private func editor(for definition: FieldDefinition) -> some View {
        switch definition.name {
        case "Status":
            LabelStatus(status: statusBinding)
        case "Difficulty":
            LabelDifficulty(difficulty: difficultyBinding)
        case "Tags":
            LabelTags(tags: tagsBinding)
        default:
            genericPropertyEditor(definition: definition)
        }
    }
    
    @ViewBuilder
    private func genericPropertyEditor(definition: FieldDefinition) -> some View {
        switch definition.type {
        case .text:
            TextField("Empty", text: Binding(get: { property.stringValue ?? "" }, set: { property.stringValue = $0 }))
                .multilineTextAlignment(.trailing)
            
        case .number:
            TextField("0", value: Binding(get: { property.numberValue ?? 0 }, set: { property.numberValue = $0 }), format: .number)
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
            
        case .boolean:
            Toggle("", isOn: Binding(get: { property.boolValue ?? false }, set: { property.boolValue = $0 }))
                .frame(width: 50)
            
        case .date:
            HStack {
                Text(property.dateValue?.formatted(date: .abbreviated, time: .omitted) ?? "Empty")
                    .foregroundColor(property.dateValue == nil ? .gray : .white)
            }
            .popover(isPresented: $showDatePicker) {
                DatePicker(
                    "Select Date",
                    selection: Binding(get: { property.dateValue ?? Date() }, set: { property.dateValue = $0 }),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
            }
            .onTapGesture { showDatePicker = true }
            
        case .selection:
            Menu {
                ForEach(definition.selectionOptions ?? [], id: \.self) { option in
                    Button(option) { property.selectionValue = option }
                }

                Divider()
                Button(action: { isShowingAddOptionAlert = true }) {
                    Label("Add New Option", systemImage: "plus")
                }
            } label: {
                Text(property.selectionValue ?? "Empty")
            }
            .alert("Add New Option", isPresented: $isShowingAddOptionAlert) {
                TextField("Option Name", text: $newOptionText)
                Button("Cancel", role: .cancel) { newOptionText = "" }
                Button("Save") {
                    viewModel.addOption(to: definition, newOption: newOptionText)
                    property.selectionValue = newOptionText.trimmingCharacters(in: .whitespaces)
                    newOptionText = ""
                }
            }
            
        case .url:
            VStack(alignment: .trailing) {
                TextField("https://example.com", text: Binding(get: { property.urlValue?.absoluteString ?? "" }, set: { property.urlValue = URL(string: $0) }))
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.URL)
                
                if let url = property.urlValue {
                    URLPreview(url: url, style: .large).padding(.top, 4)
                }
            }
            
        case .multiSelection:
            Text(property.multiSelectionValue?.joined(separator: ", ") ?? "Empty")
                .lineLimit(1)
        }
    }
    
    private var statusBinding: Binding<CardStatus> {
        Binding(
            get: { CardStatus(rawValue: property.selectionValue ?? "") ?? .notStarted },
            set: { property.selectionValue = $0.rawValue }
        )
    }
    
    private var difficultyBinding: Binding<CardDifficulty> {
        Binding(
            get: { CardDifficulty(rawValue: property.selectionValue ?? "") ?? .easy },
            set: { property.selectionValue = $0.rawValue }
        )
    }
    
    private var tagsBinding: Binding<[String]> {
        Binding(
            get: { property.multiSelectionValue ?? [] },
            set: { property.multiSelectionValue = $0 }
        )
    }
}

//#Preview {
//    PropertyEditorView()
//}
