//
//  TaskColumnView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct TaskColumnView: View {
    let status: TaskStatus
    let tasks: [TaskCard]
    
    let onTaskDropped: (TaskCard) -> Void
    @State private var isTargeted: Bool = false
    
    var body: some View {
        VStack (alignment: .leading){
            LabelStatus(status: status).padding(10)
            
            VStack(spacing: 8) {
                ForEach(tasks) { task in
                    TaskCardView(task: task)
                        .onDrag {
                            let provider = NSItemProvider()
                            do {
                                let data = try JSONEncoder().encode(task)
                                provider.registerDataRepresentation(forTypeIdentifier: UTType.taskCard.identifier, visibility: .all) { completion in
                                    completion(data, nil)
                                    return nil
                                }
                            } catch {
                                print("Encoding failed")
                            }
                            return provider
                        }
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
                .cornerRadius(16)
                .fontWeight(.bold)
                .foregroundColor(status.colorTask)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(status.colorTask, lineWidth: 1)
            )
        }
        .padding(.bottom, 15)
        .frame(width: 300)
        .background(status.color)
        .cornerRadius(15)
        .padding(.trailing, 10)
        .onDrop(of: [UTType.taskCard.identifier], isTargeted: $isTargeted) { providers in
            guard !providers.isEmpty else { return false }
            
            for provider in providers {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.taskCard.identifier) { data, error in
                    if let data, let decoded = try? JSONDecoder().decode(TaskCard.self, from: data) {
                        DispatchQueue.main.async {
                            onTaskDropped(decoded)
                        }
                    }
                }
            }
            return true // Only return true if we handled the drop
        }
    }
}

extension Color {
    /// Робить колір більш насиченим.
    /// - Parameter amount: Значення від 0.0 до 1.0, на яке потрібно збільшити насиченість.
    /// - Returns: Новий, більш насичений колір.
    func saturated(by amount: CGFloat) -> Color {
        // Конвертуємо SwiftUI Color в UIColor для доступу до компонентів HSB
        let uiColor = UIColor(self)
        
        // Отримуємо компоненти HSB
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // Збільшуємо насиченість, обмежуючи значення до 1.0
        let newSaturation = min(saturation + amount, 1.0)
        
        // Створюємо новий колір з оновленою насиченістю
        return Color(hue: hue, saturation: newSaturation, brightness: brightness, opacity: alpha)
    }
}
//#Preview {
//    TaskColumnView(status: .notStarted, tasks:[TaskCard(title: "Premiere pro Caba Videos Edit", priority: .hard, tags: ["Polish", "Bug"], commentCount: 0, status: .notStarted)])
//}
