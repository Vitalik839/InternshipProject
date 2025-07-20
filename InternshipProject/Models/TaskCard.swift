//
//  Card.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum FieldValue: Codable, Hashable {
    case text(String)
    case number(Double)
    case boolean(Bool)
    case date(Date)
    case url(URL?)
    case selection(String?)
    case multiSelection([String])
}

enum FieldType: String, Codable, CaseIterable {
    case text
    case number
    case boolean
    case date
    case url
    case selection
    case multiSelection
}

struct FieldDefinition: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var type: FieldType
    var selectionOptions: [String]?
}

struct TaskCard: Identifiable, Hashable, Codable {
    var id: UUID
    var title: String
    
    // Ключ - це `id` з `FieldDefinition`, а значення - це дані, введені користувачем.
    var properties: [UUID: FieldValue]
}
extension TaskCard: Transferable {
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
