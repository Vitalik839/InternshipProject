//
//  CreateTemplate.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 21.07.2025.
//

import SwiftUI

struct CreateTemplate: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var newProject = Project(name: "")
        
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
                    Button("Save", action: saveProject)
                        .disabled(newProject.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showAddPropertySheet) {
                AddPropertyView(
                    suggestedDefinitions: [
                        FieldDefinition(name: "Status", type: .selection, selectionOptions: CardStatus.allCases.map { $0.rawValue }),
                        FieldDefinition(name: "Difficulty", type: .selection, selectionOptions: CardDifficulty.allCases.map { $0.rawValue }),
                        FieldDefinition(name: "Tags", type: .multiSelection, selectionOptions: ["Polish", "Bug", "Feature Request"])
                    ],
                    addedDefinitions: newProject.fieldDefinitions,
                    onComplete: { newDefinition in
                        if !newProject.fieldDefinitions.contains(where: { $0.name == newDefinition.name }) {
                            newProject.fieldDefinitions.append(newDefinition)
                        }
                    }
                )
            }
        }
    }
    private func saveProject() {
        withAnimation {
            let boardView = ViewMode(name: "Board View", displayType: .board)
            let tableView = ViewMode(name: "Table View", displayType: .table)
            
            newProject.views.append(boardView)
            newProject.views.append(tableView)
            
            modelContext.insert(newProject)
        }
        dismiss()
    }
}


//#Preview {
//    CreateTemplate(viewModel: ProjectsViewModel())
//}
