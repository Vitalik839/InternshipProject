//
//  ProjectsListView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 18.07.2025.
//

import SwiftUI

struct ProjectsListView: View {
    @StateObject private var viewModel = ProjectsViewModel()
    @State private var isCreatingProject = false
    @State private var offsetsToDelete: IndexSet?
    @State private var showDeleteConfirmation = false
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.projects) { project in
                    NavigationLink(value: project) {
                        VStack(alignment: .leading) {
                            Text(project.name).font(.headline)
                            Text("\(project.cards.count) cards")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete { indexSet in
                    self.offsetsToDelete = indexSet
                    self.showDeleteConfirmation = true
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { isCreatingProject = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isCreatingProject) {
                CreateTemplate(viewModel: viewModel)
            }
            .navigationDestination(for: Project.self) { project in
                if let index = viewModel.projects.firstIndex(where: { $0.id == project.id }) {
                    CardBoardView(project: $viewModel.projects[index])
                }
            }
            .confirmationDialog(
                "Delete this project?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Project", role: .destructive) {
                    if let offsets = offsetsToDelete {
                        viewModel.deleteProject(at: offsets)
                    }
                }
                Button("Cancel", role: .cancel) {
                    offsetsToDelete = nil
                }
            }
        }
        .background(.bg)
    }
}

#Preview {
    ProjectsListView()
}
