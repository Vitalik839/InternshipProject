//
//  LabelTags.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 08.07.2025.
//

import SwiftUI

struct LabelTags: View {
    @Binding var tags: [String]

    private let presetTags: [String] = ["Tech", "Polish", "Self", "Career"]
    @State private var showCustomTagAlert = false
    @State private var customTagInput = ""
    var body: some View {
        HStack(spacing: 6) {
            Menu {
                ForEach(presetTags, id: \.self) { tag in
                    Button(action: {
                        if !tags.contains(tag) {
                            tags.append(tag)
                        }
                    }) {
                        Text(tag)
                    }
                }
                Divider()
                Button("Your own task type") {
                    showCustomTagAlert = true
                }
            } label: {
                if tags.isEmpty {
                    Text("Add tags")
                } else {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                }
            }
        }
        .alert("Enter custom tag", isPresented: $showCustomTagAlert) {
            TextField("Type your tag", text: $customTagInput).foregroundStyle(.black)
            Button("Save", action: {
                let trimmed = customTagInput.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty && !tags.contains(trimmed) {
                    tags.append(trimmed)
                    customTagInput = ""
                }
            })
            Button("Cancel", role: .cancel, action: {})
        }
    }
}
