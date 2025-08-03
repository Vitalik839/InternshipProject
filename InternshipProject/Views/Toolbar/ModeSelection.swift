//
//  ModeSelection.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import SwiftUI

struct ModeSelection: View {
    @EnvironmentObject var viewModel: CardViewModel
    @Binding var isPresented: Bool
    
    @State private var isCreatingView = false
    
    private var defaultViews: [ViewMode] {
        Array(viewModel.project.views.prefix(2))
    }
    
    private var customViews: [ViewMode] {
        Array(viewModel.project.views.dropFirst(2))
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Default Views")) {
                    ForEach(defaultViews) { config in
                        viewRow(for: config)
                    }
                }
                
                if !customViews.isEmpty {
                    Section(header: Text("Custom Views")) {
                        ForEach(customViews) { config in
                            viewRow(for: config)
                        }
                        .onDelete(perform: deleteCustomView)
                    }
                }
            }
            .navigationTitle("View Mode")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isCreatingView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isCreatingView) {
                CreateCustomView()
            }
        }
    }
    
    @ViewBuilder
    private func viewRow(for config: ViewMode) -> some View {
        HStack {
            Text(config.name)
            Spacer()
            if config.id == viewModel.selectedViewID {
                Image(systemName: "checkmark")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.selectedViewID = config.id
            isPresented = false
        }
    }

    private func deleteCustomView(at offsets: IndexSet) {
        let originalIndices = IndexSet(offsets.map { $0 + defaultViews.count })
        viewModel.deleteView(at: originalIndices)
    }
}
