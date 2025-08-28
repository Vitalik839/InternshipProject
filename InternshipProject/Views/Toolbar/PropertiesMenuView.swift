//
//  PropertiesMenuView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 11.07.2025.
//

import SwiftUI

struct PropertiesMenuView: View {
    @EnvironmentObject var viewModel: CardViewModel
    let project: Project

    private var shownProperties: [FieldDefinition] {
        project.fieldDefinitions.filter { viewModel.visibleCardPropertyIDs.contains($0.id) }
            .sorted { $0.name < $1.name }
    }
    
    private var hiddenProperties: [FieldDefinition] {
        project.fieldDefinitions.filter { !viewModel.visibleCardPropertyIDs.contains($0.id) }
            .sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Shown in board")) {
                    ForEach(shownProperties) { property in
                        propertyRow(for: property, isVisible: true)
                    }
                }
                Section(header: Text("Hidden in board")) {
                    ForEach(hiddenProperties) { property in
                        propertyRow(for: property, isVisible: false)
                    }
                }
            }
            .navigationTitle("Properties")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    @ViewBuilder
    private func propertyRow(for property: FieldDefinition, isVisible: Bool) -> some View {
        HStack {
            Text(property.name)
            Spacer()
            Button(action: {
                viewModel.toggleCardPropertyVisibility(id: property.id)
            }) {
                Image(systemName: isVisible ? "eye" : "eye.slash")
            }
            .buttonStyle(.plain)
        }
    }
}

//#Preview {
//    PropertiesMenuView().environmentObject(ViewSettings())
//}
