//
//  Card.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers


struct TaskCard: Identifiable, Hashable, Codable, Transferable {
    var id: UUID
    var title: String
    var difficulty: Difficulty
    var tags: [String]
    var status: TaskStatus
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .taskCard)
    }
}


extension UTType {
    static let taskCard = UTType(exportedAs: "com.vitalik.taskcard")
}


extension Color {
    func saturated(by amount: CGFloat) -> Color {
        let uiColor = UIColor(self)

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // Збільшуємо насиченість, обмежуючи значення до 1.0
        let newSaturation = min(saturation + amount, 1.0)

        return Color(hue: hue, saturation: newSaturation, brightness: brightness, opacity: alpha)
    }
}
