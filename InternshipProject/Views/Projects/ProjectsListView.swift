//
//  ProjectsListView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 18.07.2025.
//

import SwiftUI
import SwiftData

struct ProjectsListView: View {
    @Environment(\.modelContext) private var modelContext
        
    @Query(sort: \Project.name) private var projects: [Project]
        
    @State private var isCreatingProject = false
    @State private var offsetsToDelete: IndexSet?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(projects) { project in
                    NavigationLink(value: project) {
                        VStack(alignment: .leading) {
                            Text(project.name).font(.headline)
                            Text("\(project.cards.count) cards")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: deleteProjects)
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
                CreateTemplate()
            }
            .navigationDestination(for: Project.self) { project in
                ViewsController(project: project)
            }
            .confirmationDialog(
                "Delete this project?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Project", role: .destructive) {
                    if let offsets = offsetsToDelete {
                        deleteProjects(at: offsets)
                    }
                }
                Button("Cancel", role: .cancel) {
                    offsetsToDelete = nil
                }
            }
        }
        .background(.bg)
    }
    
    private func deleteProjects(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(projects[index])
            }
        }
        offsetsToDelete = nil

    }
}

//#Preview {
//    ProjectsListView()
//}
