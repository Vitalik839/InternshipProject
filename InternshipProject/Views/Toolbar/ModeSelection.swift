//
//  ModeSelection.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import SwiftUI

struct ModeSelection: View {
    @EnvironmentObject var viewModel: CardViewModel
    @Environment(\.modelContext) private var modelContext
    
    let project: Project
    @Binding var isPresented: Bool
    
    @State private var isCreatingView = false
    
    private var defaultViews: [ViewMode] {
        Array(project.views.prefix(2))
    }
    
    private var customViews: [ViewMode] {
        Array(project.views.dropFirst(2))
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
                        .onDelete(perform: deleteView)
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
                CreateCustomView(project: project)
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

    private func deleteView(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let viewToDelete = project.views[index]
                viewModel.deleteView(viewToDelete)
            }
        }
    }
}
