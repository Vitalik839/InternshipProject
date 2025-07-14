//
//  PropertiesMenuView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 11.07.2025.
//

import SwiftUI

struct PropertiesMenuView: View {
    @EnvironmentObject var settings: ViewSettings
    // Розділимо властивості на показані та приховані
    private var shownProperties: [TaskProperty] {
        TaskProperty.allCases.filter { settings.visibleProperties.contains($0) }
    }
    private var hiddenProperties: [TaskProperty] {
        TaskProperty.allCases.filter { !settings.visibleProperties.contains($0) }
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
    private func propertyRow(for property: TaskProperty, isVisible: Bool) -> some View {
        HStack {
            Image(systemName: property.systemImageName)
                .frame(width: 20)
            Text(property.rawValue)
            Spacer()
            Button(action: {
                toggleVisibility(for: property)
                print("djfjdjf")
            }) {
                Image(systemName: isVisible ? "eye" : "eye.slash")
            }
            .buttonStyle(.plain) // Прибирає синій колір кнопки
        }
    }
    private func toggleVisibility(for property: TaskProperty) {
        if settings.visibleProperties.contains(property) {
            settings.visibleProperties.remove(property)
        } else {
            settings.visibleProperties.insert(property)
        }
    }
}

//#Preview {
//    PropertiesMenuView().environmentObject(ViewSettings())
//}
