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
    var titleColumn: String { get }
    var color: Color { get }
}

extension GroupableProperty {
    public var id: Self { self }
}

extension String: @retroactive Identifiable {}
extension String: GroupableProperty {
    var titleColumn: String { self }
    var color: Color { .purple }
}

struct TaskColumnView<Group: GroupableProperty>: View {
    let group: Group
    let cards: [TaskCard]
    let projectDefinitions: [FieldDefinition]
    let visibleCardPropertyIDs: Set<UUID>
    let columnColor: Color
    let onTaskDropped: (TaskCard, Group) -> Void

    @State private var isTargeted: Bool = false
    @EnvironmentObject var viewModel: TaskBoardViewModel

    var body: some View {
        VStack (alignment: .leading, spacing: 0){
            LabelTitleColumn(title: group.titleColumn, colorBg: columnColor.opacity(0.8))
                .padding(.bottom, 8)

            VStack(spacing: 8) {
                ForEach(cards) { card in
                    TaskCardView(card: card, projectDefinitions: projectDefinitions,
                    visiblePropertyIDs: visibleCardPropertyIDs)
                        .draggable(card)
                        .environmentObject(viewModel)
                }
            }
            .padding(.bottom)

            Button(action: {
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
