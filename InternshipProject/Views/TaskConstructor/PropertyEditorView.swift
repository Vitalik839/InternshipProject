//
//  PropertyEditorView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 16.07.2025.
//

import SwiftUI

struct PropertyEditorView: View {
    let definition: FieldDefinition
    @Binding var value: FieldValue?
    
    var body: some View {
        HStack (alignment: .top, spacing: 10){
            Image(systemName: "circle.fill")
                .foregroundColor(.gray)
            Text(definition.name)
            
            Spacer()
            
            Group {
                switch definition.name {
                case "Status":
                    LabelStatus(status: statusBinding)
                    
                case "Difficulty":
                    LabelDifficulty(difficulty: difficultyBinding)
                    
                case "Tags":
                    LabelTags(tags: tagsBinding)
                    
                default:
                    genericPropertyEditor
                }
            }
            .foregroundStyle(.white)
            
        }
    }

    @ViewBuilder
    private var genericPropertyEditor: some View {
        switch definition.type {
        case .text:
            TextField("Empty", text: textBinding)
                .multilineTextAlignment(.trailing)
            
        case .number:
            TextField("0", value: numberBinding, format: .number)
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
            
        case .boolean:
            Toggle("", isOn: boolBinding)
                .frame(width: 50)
            
        case .date:
            if let date = dateBinding.wrappedValue {
                Text(date.formatted(date: .abbreviated, time: .omitted))
            } else {
                Text("Empty").foregroundColor(.gray)
            }
            
        case .selection:
            Menu {
                ForEach(definition.selectionOptions ?? [], id: \.self) { option in
                    Button(option) {
                        value = .selection(option)
                    }
                }
            } label: {
                if case .selection(let selected) = value, let selected = selected {
                    Text(selected)
                } else {
                    Text("Empty").foregroundColor(.gray)
                }
            }
            
        case .url:
            VStack(alignment: .trailing) {
                TextField("https://example.com", text: urlBinding)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.URL)
                
                if let url = URL(string: urlBinding.wrappedValue) {
                    URLPreview(url: url, style: .large)
                        .padding(.top, 4)
                }
            }
            
        case .multiSelection:
            Text(multiSelectionBinding.wrappedValue.joined(separator: ", "))
                .lineLimit(1)
        }
    }
    
    private var textBinding: Binding<String> {
        Binding<String>(
            get: {
                if case .text(let text) = value { return text }
                return ""
            },
            set: { value = .text($0) }
        )
    }
    
    private var numberBinding: Binding<Double> {
        Binding<Double>(
            get: {
                if case .number(let number) = value { return number }
                return 0
            },
            set: { value = .number($0) }
        )
    }
    
    private var boolBinding: Binding<Bool> {
        Binding<Bool>(
            get: {
                if case .boolean(let bool) = value { return bool }
                return false
            },
            set: { value = .boolean($0) }
        )
    }
    
    private var dateBinding: Binding<Date?> {
        Binding<Date?>(
            get: {
                if case .date(let date) = value { return date }
                return nil
            },
            set: { value = .date($0!) }
        )
    }
    
    private var urlBinding: Binding<String> {
        Binding<String>(
            get: {
                if case .url(let url) = value { return url?.absoluteString ?? "" }
                return ""
            },
            set: {
                if let newURL = URL(string: $0) {
                    value = .url(newURL)
                } else {
                    value = .url(nil)
                }
            }
        )
    }
    
    private var multiSelectionBinding: Binding<[String]> {
        Binding<[String]>(
            get: {
                if case .multiSelection(let tags) = value { return tags }
                return []
            },
            set: { value = .multiSelection($0) }
        )
    }
    
    private var statusBinding: Binding<TaskStatus> {
        Binding<TaskStatus>(
            get: {
                if case .selection(let option) = value, let status = TaskStatus(rawValue: option ?? "") {
                    return status
                }
                return .notStarted
            },
            set: { value = .selection($0.rawValue) }
        )
    }
    
    private var difficultyBinding: Binding<Difficulty> {
        Binding<Difficulty>(
            get: {
                if case .selection(let option) = value, let difficulty = Difficulty(rawValue: option ?? "") {
                    return difficulty
                }
                return .easy
            },
            set: { value = .selection($0.rawValue) }
        )
    }
    
    private var tagsBinding: Binding<[String]> {
        Binding<[String]>(
            get: {
                if case .multiSelection(let tags) = value { return tags }
                return []
            },
            set: { value = .multiSelection($0) }
        )
    }
}

//#Preview {
//    PropertyEditorView()
//}
