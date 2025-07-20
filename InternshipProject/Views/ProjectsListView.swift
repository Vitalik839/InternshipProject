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
                .onDelete(perform: viewModel.deleteProject)
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
                Text("Project Constructor Screen")
            }
            .navigationDestination(for: Project.self) { project in
                if let index = viewModel.projects.firstIndex(where: { $0.id == project.id }) {
                    TaskBoardView(project: $viewModel.projects[index])
                }
            }
        }
        .background(.bg)
    }
}

#Preview {
    ProjectsListView()
}
