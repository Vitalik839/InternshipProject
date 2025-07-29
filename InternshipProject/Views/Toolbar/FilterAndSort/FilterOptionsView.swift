//
//  FilterOptionsView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 28.07.2025.
//

import SwiftUI

struct FilterOptionsView: View {
    @EnvironmentObject var viewModel: CardViewModel
    let field: FieldDefinition
    
    @State private var textFilter: String = ""
    @State private var selectionFilter: Set<String> = []
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var startNumber: Double?
    @State private var endNumber: Double?
    @State private var isNotEmpty: Bool = false

    var body: some View {
        List {
            switch field.type {
            case .selection, .multiSelection:
                ForEach(field.selectionOptions ?? [], id: \.self) { option in
                    Button(action: { toggleSelection(option) }) {
                        HStack {
                            Text(option)
                            Spacer()
                            if selectionFilter.contains(option) { Image(systemName: "checkmark") }
                        }
                    }
                    .foregroundColor(.white)
                }
                
            case .text:
                TextField("Contains text...", text: $textFilter)
                
            case .date:
                OptionalDatePicker(title: "Start Date", date: $startDate)
                OptionalDatePicker(title: "End Date", date: $endDate)
                
            case .number:
                HStack {
                    Text("From")
                    TextField("Start", value: $startNumber, format: .number)
                }
                HStack {
                    Text("To")
                    TextField("End", value: $endNumber, format: .number)
                }
            
            case .url, .boolean:
                Toggle("Is not empty", isOn: $isNotEmpty)
                
            }
        }
        .navigationTitle("Filter by \(field.name)")
        .onAppear(perform: setupInitialState)
        .onDisappear(perform: saveFilterState)
    }
    
    private func setupInitialState() {
        guard let filter = viewModel.activeFilters[field.id] else { return }
        switch filter {
        case .textContains(let text): self.textFilter = text
        case .selectionContains(let selections): self.selectionFilter = selections
        case .dateRange(let start, let end):
            self.startDate = start
            self.endDate = end
        case .numberRange(let start, let end):
            self.startNumber = start
            self.endNumber = end
        case .isNotEmpty: self.isNotEmpty = true
        }
    }

    private func saveFilterState() {
        var newFilter: FilterType?
        
        switch field.type {
        case .text:
            if !textFilter.isEmpty { newFilter = .textContains(textFilter) }
        case .selection, .multiSelection:
            if !selectionFilter.isEmpty { newFilter = .selectionContains(selectionFilter) }
        case .date:
            if startDate != nil || endDate != nil { newFilter = .dateRange(start: startDate, end: endDate) }
        case .number:
             if startNumber != nil || endNumber != nil { newFilter = .numberRange(start: startNumber, end: endNumber) }
        case .url, .boolean:
            if isNotEmpty { newFilter = .isNotEmpty }
        }
        
        viewModel.setFilter(newFilter, for: field.id)
    }
    
    private func toggleSelection(_ option: String) {
        if selectionFilter.contains(option) { selectionFilter.remove(option) }
        else { selectionFilter.insert(option) }
    }
}

struct OptionalDatePicker: View {
    let title: String
    @Binding var date: Date?

    var body: some View {
        HStack {
            if date != nil {
                DatePicker(title, selection: Binding(get: { date! }, set: { date = $0 }), displayedComponents: .date)
                Button(action: { date = nil }) { Image(systemName: "xmark.circle.fill") }
            } else {
                Text(title).foregroundColor(.gray)
                Spacer()
                Button("Set") { date = Date() }
            }
        }
    }
}
