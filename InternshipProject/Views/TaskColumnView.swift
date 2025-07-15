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
    let group: Group
    let cards: [TaskCard] // Змінено з `tasks` на `cards` для відповідності моделі
    let projectDefinitions: [FieldDefinition] // Передаємо визначення для TaskCardView
    let visibleCardPropertyIDs: Set<UUID>
    let columnColor: Color // Колір для колонки
    let onTaskDropped: (TaskCard, Group) -> Void

    @State private var isTargeted: Bool = false
    @EnvironmentObject var viewSettings: ViewSettings

    var body: some View {
        VStack (alignment: .leading, spacing: 0){
            LabelTitleColumn(title: group.titleColumn, colorBg: columnColor.opacity(0.8))
                .padding(.bottom, 8)

            VStack(spacing: 8) {
                ForEach(cards) { card in
                    TaskCardView(card: card, projectDefinitions: projectDefinitions,
                    visiblePropertyIDs: visibleCardPropertyIDs)
                        .draggable(card)
                        .environmentObject(viewSettings) // ViewSettings все ще потрібен тут
                }
            }
            .padding(.bottom)

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
                    .stroke(.gray, style: StrokeStyle(lineWidth: 1))
            )
        }
        .padding(10)
        .frame(width: 300)
        .background(isTargeted ? columnColor.opacity(0.5) : columnColor.opacity(0.25))
        .cornerRadius(12)
        .dropDestination(for: TaskCard.self) { droppedTasks, location in
            guard let droppedTask = droppedTasks.first else { return false }
            onTaskDropped(droppedTask, group)
            return true
        } isTargeted: { isTargeting in
            self.isTargeted = isTargeting
        }
    }
}
//#Preview {
//    TaskColumnView(status: .notStarted, tasks:[TaskCard(title: "Premiere pro Caba Videos Edit", priority: .hard, tags: ["Polish", "Bug"], commentCount: 0, status: .notStarted)])
//}
