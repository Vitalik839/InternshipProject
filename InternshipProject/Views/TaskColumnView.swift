//
//  TaskColumnView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import SwiftUI
import UniformTypeIdentifiers

protocol GroupableProperty: Hashable, Identifiable, Sendable {
    var id: Self { get }
    var titleColumn: String { get } // Назва для заголовка колонки
    var color: Color { get } // Колір для заголовка
}

extension GroupableProperty {
    public var id: Self { self } // ID - це саме значення
}

extension String: @retroactive Identifiable {}
extension String: GroupableProperty {
    var titleColumn: String { self }
    var color: Color { .purple }
}

struct TaskColumnView<Group: GroupableProperty>: View {
    let group: Group // Замість 'status', тепер 'group'
    let tasks: [TaskCard]
    let onTaskDropped: (TaskCard, Group) -> Void // Тепер передаємо і картку, і групу
    
    @State private var isTargeted: Bool = false
    @EnvironmentObject var viewSettings: ViewSettings
    
    var body: some View {
        VStack (alignment: .leading){
            LabelTitleColumn(title: group.titleColumn, colorBg: group.color)
            //LabelStatus(status: status).padding(10)
            VStack(spacing: 8) {
                ForEach(tasks) { task in
                    TaskCardView(task: task)
                        .draggable(task)
                        .environmentObject(viewSettings)
                }
            }
            Button(action: {
                // Ваша дія для створення нового завдання
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("New Task")
                    Spacer()
                }
                .padding()
                .frame(width: 280)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.gray, lineWidth: 1)
            )
        }
        .padding(.bottom, 15)
        .frame(width: 300)
        .background(isTargeted ? group.color.saturated(by: 0.5): group.color)
        .cornerRadius(15)
        .padding(.trailing, 10)
        .dropDestination(for: TaskCard.self) { droppedTasks, location in
            guard let droppedTask = droppedTasks.first else { return false }
            onTaskDropped(droppedTask, group)
            
            return true // підтверджуємо успішне скидання
        } isTargeted: { isTargeting in
            self.isTargeted = isTargeting
        }
    }
}

//#Preview {
//    TaskColumnView(status: .notStarted, tasks:[TaskCard(title: "Premiere pro Caba Videos Edit", priority: .hard, tags: ["Polish", "Bug"], commentCount: 0, status: .notStarted)])
//}
