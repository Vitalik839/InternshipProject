//
//  FilterMenuView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 27.07.2025.
//

import SwiftUI

struct FilterMenuView: View {
    let project: Project

    @EnvironmentObject var viewModel: CardViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showSortSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Button(action: { showSortSheet = true }) {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Sort by")
                        Spacer()
                        if let sortRule = viewModel.activeSortRule,
                           let field = project.fieldDefinitions.first(where: { $0.id == sortRule.fieldID }) {
                            Text(field.name)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 35)
                .padding(.top, 20)
                
                List {
                    ForEach(project.fieldDefinitions) { field in
                        NavigationLink(value: field) {
                            HStack {
                                Text(field.name)
                                Spacer()
                                if viewModel.activeFilters[field.id] != nil {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter by")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear Filters") {
                        viewModel.clearAllFilters()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .navigationDestination(for: FieldDefinition.self) { field in
                FilterOptionsView(field: field)
            }
            .sheet(isPresented: $showSortSheet) {
                NavigationView {
                    SortMenuView(project: project)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { showSortSheet = false }
                            }
                        }
                }
            }
            .environmentObject(viewModel)
        }
    }
}
//#Preview {
//    FilterMenuView()
//}
