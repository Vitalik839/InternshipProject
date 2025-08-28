//
//  CreateCustomView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 31.07.2025.
//

import SwiftUI

struct CreateCustomView: View {
    @EnvironmentObject var viewModel: CardViewModel
    @Environment(\.dismiss) private var dismiss
    
    let project: Project

    @State private var viewName: String = ""
    @State private var displayType: ViewMode.DisplayType = .board
    @State private var groupingFieldID: UUID?
    
    var body: some View {
        NavigationView {
            Form {
                Section("View Name") {
                    TextField("My Custom Board", text: $viewName)
                }
                
                Section("Display Type") {
                    Picker("Type", selection: $displayType) {
                        ForEach(ViewMode.DisplayType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                if displayType == .board {
                    Section("Board Settings") {
                        Picker("Group By", selection: $groupingFieldID) {
                            Text("None").tag(nil as UUID?)
                            ForEach(viewModel.groupableFields(for: project)) { field in
                                Text(field.name).tag(field.id as UUID?)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New View")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.createNewView(
                            name: viewName,
                            displayType: displayType,
                            groupingFieldID: groupingFieldID,
                            for: project
                        )
                        dismiss()
                    }
                    .disabled(viewName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear {
            groupingFieldID = viewModel.groupableFields(for: project).first?.id
        }
    }
}
