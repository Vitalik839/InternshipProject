//
//  Card.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 04.07.2025.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import SwiftData

@Model
final class Card {
    @Attribute(.unique) var id: UUID
    var title: String
    var hiddenFieldIDs: Data = Data()

    var project: Project?
    
    @Relationship(deleteRule: .cascade, inverse: \PropertyValue.card)
    var properties: [PropertyValue] = []

    init(title: String, project: Project) {
        self.id = UUID()
        self.title = title
        self.project = project
    }
    
    func isFieldHidden(with definitionID: UUID) -> Bool {
        if let set = try? JSONDecoder().decode(Set<UUID>.self, from: hiddenFieldIDs) {
            return set.contains(definitionID)
        }
        return false
    }
    
    func toggleFieldVisibility(for definitionID: UUID) {
        var set = (try? JSONDecoder().decode(Set<UUID>.self, from: hiddenFieldIDs)) ?? Set<UUID>()
        
        if set.contains(definitionID) {
            set.remove(definitionID)
        } else {
            set.insert(definitionID)
        }
        
        hiddenFieldIDs = (try? JSONEncoder().encode(set)) ?? Data()
    }
}


@Model
final class FieldDefinition {
    @Attribute(.unique) var id: UUID
    var name: String
    var type: FieldType
    var selectionOptions: [String]?
    
    var project: Project?

    init(name: String, type: FieldType, selectionOptions: [String]? = nil) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.selectionOptions = selectionOptions
    }
}


@Model
final class PropertyValue {
    @Attribute(.unique) var id: UUID
    
    // Зв'язки
    var card: Card?
    var fieldDefinition: FieldDefinition?

    // Замість одного поля `value: Data` робимо окремі поля для кожного типу
    // Це дозволить базі даних фільтрувати за ними
    var stringValue: String?
    var numberValue: Double?
    var dateValue: Date?
    var boolValue: Bool?
    var urlValue: URL?
    var selectionValue: String? // Для selection та multiSelection
    var multiSelectionValue: [String]?

    init(card: Card, fieldDefinition: FieldDefinition) {
        self.id = UUID()
        self.card = card
        self.fieldDefinition = fieldDefinition
    }
}


enum FieldType: String, Codable, CaseIterable {
    case text, number, boolean, date, url, selection, multiSelection
}
enum FieldValue: Codable, Hashable {
    case text(String)
    case number(Double)
    case boolean(Bool)
    case date(Date)
    case url(URL?)
    case selection(String?)
    case multiSelection([String])
}


extension Card: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.id.uuidString)
    }
}

extension UUID: Identifiable {
    public var id: UUID { self }
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

        let newSaturation = min(saturation + amount, 1.0)

        return Color(hue: hue, saturation: newSaturation, brightness: brightness, opacity: alpha)
    }
}
