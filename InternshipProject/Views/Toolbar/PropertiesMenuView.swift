//
//  PropertiesMenuView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 11.07.2025.
//

import SwiftUI

struct PropertiesMenuView: View {
    @EnvironmentObject var viewModel: CardViewModel
    private var shownProperties: [FieldDefinition] {
        viewModel.projectDefinitions.filter { viewModel.visibleCardPropertyIDs.contains($0.id) }
    }
    
    private var hiddenProperties: [FieldDefinition] {
        viewModel.projectDefinitions.filter { !viewModel.visibleCardPropertyIDs.contains($0.id) }
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
            .buttonStyle(.plain) // Прибирає синій колір кнопки
        }
    }
}

//#Preview {
//    PropertiesMenuView().environmentObject(ViewSettings())
//}
