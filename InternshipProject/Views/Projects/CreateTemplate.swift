//
//  CreateTemplate.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 21.07.2025.
//

import SwiftUI

struct CreateTemplate: View {
    @ObservedObject var viewModel: ProjectsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var newProject = Project(name: "", fieldDefinitions: [], cards: [])
    
    @State private var showDatePicker = false
    @State private var showAddPropertySheet = false
    
    let widthFrameLabel: CGFloat = 120
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable().foregroundColor(.green).frame(width: 36, height: 36)
                        
                        TextField("New project", text: $newProject.name)
                            .font(.title).foregroundColor(.white)
                    }
                    .padding(.bottom)
                    
                    ForEach(newProject.fieldDefinitions) { definition in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(definition.name)
                            Spacer()
                            Text(definition.type.rawValue.capitalized)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
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
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addProject(newProject)
                        dismiss()
                    }
                    .disabled(newProject.name.isEmpty)
                }
            }
            .sheet(isPresented: $showAddPropertySheet) {
                AddPropertyView(
                    projectFields: [
                        FieldDefinition(name: "Status", type: .selection, selectionOptions: CardStatus.allCases.map { $0.rawValue }),
                        FieldDefinition(name: "Difficulty", type: .selection, selectionOptions: CardDifficulty.allCases.map { $0.rawValue }),
                        FieldDefinition(name: "Tags", type: .multiSelection, selectionOptions: ["Polish", "Bug", "Feature Request"])
                    ],
                    addedFields: newProject.fieldDefinitions,
                    onComplete: { newDefinition in
                        newProject.fieldDefinitions.append(newDefinition)
                    }
                )
            }
        }
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


#Preview {
    CreateTemplate(viewModel: ProjectsViewModel())
}
