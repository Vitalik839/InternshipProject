//
//  ModeSelection.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import SwiftUI

enum ViewMode: String, CaseIterable, Identifiable {
    case all = "All Tasks"
    case byStatus = "By Status"
    case myTasks = "My Tasks"
    case checklist = "Checklist"
    
    var id: String { self.rawValue }
}

struct ModeSelection: View {
    @Binding var selectedMode: ViewMode
    @Binding var isPresented: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(ViewMode.allCases) { mode in
                    HStack {
                        Text(mode.rawValue)
                        Spacer()
                        if mode == selectedMode {
                            Image(systemName: "checkmark")
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedMode = mode
                    }
                }
            }
            .navigationTitle("View Mode")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isPresented = false
                        dismiss()
                    }
                }
            }
        }
    }
}
