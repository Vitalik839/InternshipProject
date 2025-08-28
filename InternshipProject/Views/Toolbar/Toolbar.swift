//
//  Toolbar.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import SwiftUI

struct Toolbar: View {
    let project: Project

    @EnvironmentObject var viewModel: CardViewModel
    
    @State private var showCreateCardSheet = false
    @State private var showViewModePicker = false
    @State private var isSearching = false
    @State private var showFilterSheet = false
    @State private var showPropertiesMenu = false
    
    @FocusState private var isSearchFieldFocused: Bool
    
    private var currentViewName: String {
        project.views.first { $0.id == viewModel.selectedViewID }?.name ?? "Select View"
    }
    
    var body: some View {
        Text(project.name)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.vertical, 8)
        
        HStack(spacing: 20) {
            Button(action: {
                showViewModePicker = true
            }) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text(currentViewName)
                    Image(systemName: "chevron.down")
                }
                .foregroundColor(.white)
            }
            Spacer()
            
            if !isSearching {
                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isSearching = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            isSearchFieldFocused = true
                        }
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                }
                .transition(.asymmetric(insertion: AnyTransition.opacity, removal: .opacity))
                
                
            } else {
                HStack(spacing: 8) {
                    TextField("Search tasks…", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                        .focused($isSearchFieldFocused)
                        .onSubmit {
                            isSearchFieldFocused = false
                        }
                    
                    Button(action: {
                        withAnimation(.easeIn(duration: 0.2)) {
                            isSearching = false
                            viewModel.searchText = ""
                            isSearchFieldFocused = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                .transition(.asymmetric(insertion: AnyTransition.opacity, removal: .opacity))
            }
            
            Button {
                showFilterSheet = true
            }
            label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor(.gray)
            }
            
            Button {
                showPropertiesMenu = true
            } label: {
                Image(systemName: "slider.horizontal.3")
            }
            .foregroundColor(.gray)
            
            
            .sheet(isPresented: $showPropertiesMenu) {
                PropertiesMenuView(project: project)
            }
            
            Button(action: {
                showCreateCardSheet = true
            }) {
                Image(systemName: "plus")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 8)
        .padding(.trailing, 10)
        .background(.bg)
        .sheet(isPresented: $showViewModePicker) {
            ModeSelection(
                project: project,
                isPresented: $showViewModePicker
            )
        }
        .sheet(isPresented: $showCreateCardSheet) {
            CreateCard(project: project)
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterMenuView(project: project)
        }
        .environmentObject(viewModel)
    }
}

//#Preview {
//    ToolbarPreviewWrapper()
//}
//
//struct ToolbarPreviewWrapper: View {
//    @State private var currentMode: ViewMode = .byStatus
//    @State private var currentText: String = ""
//    
//    var body: some View {
//        Toolbar(selectedMode: $currentMode, searchText: $currentText).environmentObject(TaskBoardViewModel())
//    }
//}
