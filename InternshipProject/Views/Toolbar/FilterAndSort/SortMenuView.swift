//
//  SortMenuView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 29.07.2025.
//

import SwiftUI

struct SortMenuView: View {
    let project: Project

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
                ForEach(project.fieldDefinitions) { field in
                    Button(action: {
                        viewModel.setSort(by: field.id)
                    }) {
                        HStack {
                            Text(field.name)
                            Spacer()
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
