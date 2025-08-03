//
//  CardDataProcessorTests.swift
//  InternshipProjectTests
//
//  Created by Vitalii Novakovskyi on 04.08.2025.
//

import Foundation
@testable import InternshipProject
import XCTest

final class CardDataProcessorTests: XCTestCase {
    
    var processor: CardDataProcessor!
    var allCards: [Card]!
    var definitions: [FieldDefinition]!
    var statusDef, difficultyDef, tagsDef, dateDef, numberDef: FieldDefinition!

    override func setUp() {
        super.setUp()
        processor = CardDataProcessor()
        
        statusDef = FieldDefinition(name: "Status", type: .selection, selectionOptions: ["Not Started", "In Progress", "Done"])
        difficultyDef = FieldDefinition(name: "Difficulty", type: .selection, selectionOptions: ["Easy", "Medium", "Hard"])
        tagsDef = FieldDefinition(name: "Tags", type: .multiSelection, selectionOptions: ["UI", "Backend", "Bug"])
        dateDef = FieldDefinition(name: "Due Date", type: .date)
        numberDef = FieldDefinition(name: "Story Points", type: .number)
        definitions = [statusDef, difficultyDef, tagsDef, dateDef, numberDef]
        
        let card1 = Card(id: UUID(), title: "First Card", properties: [
            statusDef.id: .selection("In Progress"),
            difficultyDef.id: .selection("Hard"),
            tagsDef.id: .multiSelection(["UI", "Bug"]),
            dateDef.id: .date(Date(timeIntervalSinceNow: -86400 * 2)), // 2 days ago
            numberDef.id: .number(8)
        ])
        
        let card2 = Card(id: UUID(), title: "Second Card", properties: [
            statusDef.id: .selection("Not Started"),
            difficultyDef.id: .selection("Easy"),
            tagsDef.id: .multiSelection(["Backend"]),
            dateDef.id: .date(Date()), // Today
            numberDef.id: .number(3)
        ])

        let card3 = Card(id: UUID(), title: "Third Special Card", properties: [
            statusDef.id: .selection("Done"),
            difficultyDef.id: .selection("Medium"),
            tagsDef.id: .multiSelection(["UI"]),
            dateDef.id: .date(Date(timeIntervalSinceNow: 86400 * 5)), // in 5 days
            numberDef.id: .number(5)
        ])
        
        allCards = [card1, card2, card3]
    }

    override func tearDown() {
        processor = nil
        allCards = nil
        definitions = nil
        super.tearDown()
    }

    func testSearchTextFiltering() async {
        let result = await processor.processCards(allCards, searchText: "Special", filters: [:], sortRule: nil, definitions: definitions)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Third Special Card")
    }

    func testSingleFilter_Selection() async {
        let filters: [UUID: FilterType] = [
            statusDef.id: .selectionContains(["Done"])
        ]
        let result = await processor.processCards(allCards, searchText: "", filters: filters, sortRule: nil, definitions: definitions)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Third Special Card")
    }
    
    func testSingleFilter_MultiSelection() async {
        let filters: [UUID: FilterType] = [
            tagsDef.id: .selectionContains(["Bug"])
        ]
        let result = await processor.processCards(allCards, searchText: "", filters: filters, sortRule: nil, definitions: definitions)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "First Card")
    }

    func testSingleFilter_NumberRange() async {
        let filters: [UUID: FilterType] = [
            numberDef.id: .numberRange(start: 4, end: 6)
        ]
        let result = await processor.processCards(allCards, searchText: "", filters: filters, sortRule: nil, definitions: definitions)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Third Special Card")
    }

    func testSingleFilter_DateRange() async {
        let filters: [UUID: FilterType] = [
            dateDef.id: .dateRange(start: Date(timeIntervalSinceNow: -86400), end: Date(timeIntervalSinceNow: 86400))
        ]
        let result = await processor.processCards(allCards, searchText: "", filters: filters, sortRule: nil, definitions: definitions)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Second Card")
    }
    
    func testCombinedFilters() async {
        let filters: [UUID: FilterType] = [
            statusDef.id: .selectionContains(["In Progress", "Done"]),
            tagsDef.id: .selectionContains(["UI"])
        ]
        let result = await processor.processCards(allCards, searchText: "", filters: filters, sortRule: nil, definitions: definitions)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains(where: { $0.title == "First Card" }))
        XCTAssertTrue(result.contains(where: { $0.title == "Third Special Card" }))
    }

    func testSorting_ByNumber_Ascending() async {
        let sortRule = SortRule(fieldID: numberDef.id, direction: .ascending)
        let result = await processor.processCards(allCards, searchText: "", filters: [:], sortRule: sortRule, definitions: definitions)
        
        XCTAssertEqual(result.map { $0.title }, ["Second Card", "Third Special Card", "First Card"])
    }

    func testSorting_ByNumber_Descending() async {
        var sortRule = SortRule(fieldID: numberDef.id, direction: .ascending)
        sortRule.direction = .descending
        
        let result = await processor.processCards(allCards, searchText: "", filters: [:], sortRule: sortRule, definitions: definitions)
        
        XCTAssertEqual(result.map { $0.title }, ["First Card", "Third Special Card", "Second Card"])
    }
    
    func testSorting_ByDate_Ascending() async {
        let sortRule = SortRule(fieldID: dateDef.id, direction: .ascending)
        let result = await processor.processCards(allCards, searchText: "", filters: [:], sortRule: sortRule, definitions: definitions)
        
        XCTAssertEqual(result.map { $0.title }, ["First Card", "Second Card", "Third Special Card"])
    }

    func testNoFilterOrSort() async {
        let result = await processor.processCards(allCards, searchText: "", filters: [:], sortRule: nil, definitions: definitions)
        XCTAssertEqual(result.count, 3)
    }

    func testWithEmptyCardsArray() async {
        let result = await processor.processCards([], searchText: "", filters: [:], sortRule: nil, definitions: definitions)
        XCTAssertEqual(result.count, 0)
    }
}
