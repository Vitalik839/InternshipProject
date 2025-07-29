//
//  Toolbar.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import SwiftUI

struct Toolbar: View {
    @Binding var selectedMode: ViewMode
    @Binding var searchText: String
    
    @EnvironmentObject var viewModel: CardViewModel
    
    @State private var showCreateCardSheet = false
    @State private var showViewModePicker = false
    @State private var isSearching = false
    @State private var showFilterSheet = false
    @State private var showPropertiesMenu = false
    
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        Text("\(viewModel.project.name)")
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.vertical, 8)
        Text("Stay organized with tasks, your way")
            .foregroundStyle(.white)
        
        HStack(spacing: 20) {
            Button(action: {
                showViewModePicker = true
            }) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text(selectedMode.rawValue)
                    Image(systemName: "chevron.down")
                }
                .foregroundColor(.white)
            }
            .sheet(isPresented: $showViewModePicker) {
                ModeSelection(
                    selectedMode: $selectedMode,
                    isPresented: $showViewModePicker
                )
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
                    TextField("Search tasks…", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .focused($isSearchFieldFocused)
                        .onSubmit {
                            isSearchFieldFocused = false // Ховаємо клавіатуру
                        }
                    
                    Button(action: {
                        withAnimation(.easeIn(duration: 0.2)) {
                            isSearching = false
                            searchText = ""
                            isSearchFieldFocused = false // Ховаємо клавіатуру
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
                PropertiesMenuView().environmentObject(viewModel)
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
                selectedMode: $selectedMode,
                isPresented: $showViewModePicker
            )
        }
        .sheet(isPresented: $showCreateCardSheet) {
            CreateCard(
                viewModel: viewModel,
                onSave: { newCard in
                    viewModel.addNewCard(newCard)
                    showCreateCardSheet = false
                }
            )
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterMenuView()
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
