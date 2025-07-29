//
//  SortMenuView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 29.07.2025.
//

import SwiftUI

struct SortMenuView: View {
    @EnvironmentObject var viewModel: CardViewModel

    var body: some View {
        List {
            Button(action: {
                viewModel.clearSort()
            }) {
                HStack {
                    Text("None")
                    Spacer()
                    if viewModel.activeSortRule == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .foregroundColor(viewModel.activeSortRule == nil ? .blue : .white)

            Section("Sort by") {
                ForEach(viewModel.project.fieldDefinitions) { field in
                    Button(action: {
                        viewModel.setSort(by: field.id)
                    }) {
                        HStack {
                            Text(field.name)
                            Spacer()
                            // Якщо сортуємо за цим полем, показуємо іконку напрямку
                            if viewModel.activeSortRule?.fieldID == field.id {
                                Image(systemName: viewModel.activeSortRule?.direction == .ascending ? "arrow.up" : "arrow.down")
                            }
                        }
                    }
                    .foregroundColor(viewModel.activeSortRule?.fieldID == field.id ? .blue : .white)
                }
            }
        }
        .navigationTitle("Sort")
        .navigationBarTitleDisplayMode(.inline)
    }
}
