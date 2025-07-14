//
//  CreateTask.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 09.07.2025.
//

import SwiftUI

struct CreateTask: View {
    @State private var taskTitle: String = "New task"
    @State private var status: TaskStatus = .notStarted
    @State private var difficulty: Difficulty = .easy
    @State private var tags: [String] = []
    @State private var dueDate: Date? = nil
    @State private var comment: String = ""
    @State private var description: String = "Provide an overview of the task and related details."
    @State private var subTasks: [SubTask] = [
        SubTask(title: "To-do 1"),
        SubTask(title: "To-do 2"),
        SubTask(title: "To-do 3")
    ]
    
    @State private var showDatePicker = false
    let widthFrameLabel: CGFloat = 120
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .foregroundColor(.green)
                        .frame(width: 36, height: 36)
                    
                    TextField("New task", text: $taskTitle)
                        .padding(.leading)
                        .font(.title)
                        .foregroundColor(.white)
                    
                }
                .padding(.bottom)
                
                HStack {
                    Label("Status", systemImage: "circle")
                        .frame(width: widthFrameLabel, alignment: .leading)
                    Menu {
                        ForEach(TaskStatus.allCases, id: \.self) { s in
                            Button(s.rawValue) { status = s }
                        }
                    } label: {
                        LabelStatus(status: status)
                    }
                }
                
                HStack {
                    Label("Difficulty", systemImage: "circle")
                        .frame(width: widthFrameLabel, alignment: .leading)
                    
                    LabelDifficulty(difficulty: difficulty)
                    
                }
                
                HStack {
                    Label("Tags", systemImage: "tag.circle")
                        .frame(width: widthFrameLabel, alignment: .leading)
                    
                    LabelTags(tags: tags)
                }
                
                HStack {
                    Label("Due date", systemImage: "calendar")
                        .frame(width: widthFrameLabel, alignment: .leading)
                    if let date = dueDate {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .onTapGesture { showDatePicker.toggle() }
                        
                    } else {
                        Text("Empty")
                            .foregroundColor(.gray)
                            .onTapGesture { showDatePicker.toggle() }
                    }
                }
                
                HStack {
                    Label("Custom", systemImage: "ellipsis.circle")
                        .frame(width: widthFrameLabel, alignment: .leading)
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Property")
                            .padding(.horizontal, 3)
                            .padding(.vertical, 5)
                            .cornerRadius(6)
                    }
                    .padding(.horizontal, 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.gray, lineWidth: 1)
                    )
                }
                
                if showDatePicker {
                    DatePicker("", selection: Binding(get: {
                        dueDate ?? Date()
                    }, set: { newVal in
                        dueDate = newVal
                        showDatePicker = false
                    }), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .colorScheme(.dark)
                }
                
                // коментар
                ZStack(alignment: .leading) {
                    if comment.isEmpty {
                        Text("Add a comment...")
                    }
                    
                    TextField("", text: $comment)
                        .foregroundColor(.white)
                }
                .padding(.top)
                
                Rectangle().frame(height: 1).foregroundColor(.gray)
                
            }
            .foregroundStyle(.gray)
            .padding(.bottom, 20)
            
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Task description")
                    .font(.headline)
                TextEditor(text: $description)
                    .frame(height: 100)
                    .cornerRadius(8)
                    .foregroundStyle(.white)
                    .scrollContentBackground(.hidden)
                    .padding(3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.gray, lineWidth: 1)
                    )
                
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Sub-tasks")
                    .font(.headline)
                ForEach($subTasks) { $sub in
                    if !sub.title.isEmpty {
                        HStack (spacing: 15){
                            Button(action: { sub.isDone.toggle() }) {
                                Image(systemName: sub.isDone ? "checkmark.square" : "square")
                                    .foregroundColor(.blue)
                            }
                            TextField("To-do", text: $sub.title)
                        }
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .padding()
        .background(.bg)
        .foregroundColor(.white)
    }
}

struct SubTask: Identifiable {
    var id = UUID()
    var title: String
    var isDone: Bool = false
}

#Preview {
    CreateTask()
}
