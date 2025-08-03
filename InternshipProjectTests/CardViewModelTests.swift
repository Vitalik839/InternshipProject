//
//  CardViewModelTests.swift
//  InternshipProjectTests
//
//  Created by Vitalii Novakovskyi on 02.08.2025.
//

import Testing
@testable import InternshipProject
import XCTest

@MainActor
final class CardViewModelTests: XCTestCase {

    var viewModel: CardViewModel!
    var project: Project!
    var statusDef: FieldDefinition!
    var difficultyDef: FieldDefinition!
    var tagsDef: FieldDefinition!
    var dateDef: FieldDefinition!
    var textDef: FieldDefinition!


    override func setUpWithError() throws {
        statusDef = FieldDefinition(name: "Status", type: .selection, selectionOptions: CardStatus.allCases.map(\.rawValue))
        difficultyDef = FieldDefinition(name: "Difficulty", type: .selection, selectionOptions: CardDifficulty.allCases.map(\.rawValue))
        tagsDef = FieldDefinition(name: "Tags", type: .multiSelection,
                                      selectionOptions: ["Polish", "Bug", "Feature Request", "Self", "Tech"])
        dateDef = FieldDefinition(name: "Due date", type: .date)
        textDef = FieldDefinition(name: "Text", type: .text)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        let card1 = Card(
            id: UUID(),
            title: "Implement new login screen",
            properties: [
                statusDef.id: .selection(CardStatus.inProgress.rawValue),
                difficultyDef.id: .selection(CardDifficulty.hard.rawValue),
                tagsDef.id: .multiSelection(["Feature Request"]),
                dateDef.id: .date(formatter.date(from: "2025/08/13")!),
                textDef.id: .text("Деякий текст")
            ]
        )
        let card2 = Card(
            id: UUID(),
            title: "Fix crash on main screen",
            properties: [
                statusDef.id: .selection(CardStatus.notStarted.rawValue),
                difficultyDef.id: .selection(CardDifficulty.medium.rawValue),
                tagsDef.id: .multiSelection(["Bug", "Self"]),
                dateDef.id: .date(formatter.date(from: "2025/10/22")!),
                textDef.id: .text("Особливий текст")
            ]
        )
        
        let card3 = Card(
            id: UUID(),
            title: "Refactor networking layer",
            properties: [
                statusDef.id: .selection(CardStatus.done.rawValue),
                difficultyDef.id: .selection(CardDifficulty.easy.rawValue),
                dateDef.id: .date(formatter.date(from: "2025/04/09")!),
                textDef.id: .text("Просто текст")
            ]
        )
        
        let initialView = ViewMode(name: "Default View", displayType: .board, groupingFieldID: statusDef.id, filters: [:], sortRule: nil)
        
        project = Project(
            name: "Tasks Tracker",
            fieldDefinitions: [statusDef, difficultyDef, tagsDef, dateDef, textDef],
            cards: [card1, card2, card3],
            views: [initialView]
        )
        
        viewModel = CardViewModel(project: project)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        project = nil
        statusDef = nil
        difficultyDef = nil
        tagsDef = nil
        dateDef = nil
        textDef = nil
    }

    func testInitialization() {
        XCTAssertEqual(viewModel.project.name, "InternshipProject")
        XCTAssertEqual(viewModel.filteredCards.count, 3)
        XCTAssertEqual(viewModel.projectDefinitions.count, 5)
        XCTAssertNotNil(viewModel.groupingFieldID)
        XCTAssertNotNil(viewModel.selectedViewID)
    }
    
    func testAddNewCard() {
        let newCard = Card(id: UUID(), title: "New Test Card", properties: [:])
        viewModel.addNewCard(newCard)
        XCTAssertEqual(viewModel.project.cards.count, 4)
        XCTAssertTrue(viewModel.project.cards.contains(where: { $0.title == "New Test Card" }))
    }

    func testDeleteCard() {
        let cardToDelete = viewModel.project.cards.first!
        viewModel.deleteCard(cardToDelete)
        XCTAssertEqual(viewModel.project.cards.count, 2)
        XCTAssertFalse(viewModel.project.cards.contains(where: { $0.id == cardToDelete.id }))
    }
    
    func testUpdateProperty() {
        let cardToUpdate = viewModel.project.cards.first!
        let newTitle = "Updated Title"

        var updatedCard = cardToUpdate
        updatedCard.title = newTitle
        
        if let index = viewModel.project.cards.firstIndex(where: { $0.id == cardToUpdate.id }) {
            viewModel.project.cards[index] = updatedCard
        }
        
        XCTAssertEqual(viewModel.project.cards.first?.title, newTitle)
    }
    
    func testAddPropertyToCard() {
        let cardToUpdate = viewModel.project.cards.first!
        let newPropertyDef = FieldDefinition(name: "New Property", type: .boolean)
        
        viewModel.addProperty(to: cardToUpdate.id, with: newPropertyDef)
        
        let updatedCard = viewModel.project.cards.first!
        XCTAssertTrue(updatedCard.properties.keys.contains(newPropertyDef.id))
        
        if case .boolean(let value) = updatedCard.properties[newPropertyDef.id] {
            XCTAssertFalse(value)
        } else {
            XCTFail("Default value for boolean should be false")
        }
    }
    
    func testRemovePropertyFromCard() {
        var cardToUpdate = viewModel.project.cards.first!
        let propertyToRemoveID = cardToUpdate.properties.keys.first!
        
        viewModel.removeProperty(from: cardToUpdate.id, with: propertyToRemoveID)
        
        cardToUpdate = viewModel.project.cards.first!
        XCTAssertFalse(cardToUpdate.properties.keys.contains(propertyToRemoveID))
    }
    
    func testCreateQuickCard() {
        let initialCardCount = viewModel.project.cards.count
        let groupKey = CardStatus.notStarted.rawValue
        viewModel.groupingFieldID = statusDef.id
        
        viewModel.createQuickCard(in: groupKey)
        
        XCTAssertEqual(viewModel.project.cards.count, initialCardCount + 1)
        let newCard = viewModel.project.cards.last!
        XCTAssertEqual(newCard.title, "New Task")
        
        if case .selection(let value) = newCard.properties[statusDef.id] {
            XCTAssertEqual(value, groupKey)
        } else {
            XCTFail("Quick card should have the correct group value")
        }
    }

    func testFiltering() {
        viewModel.setFilter(.textContains("Особливий"), for: textDef.id)
        
        let expectation = self.expectation(description: "Filtering completes")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(self.viewModel.filteredCards.count, 1)
            XCTAssertEqual(self.viewModel.filteredCards.first?.title, "Fix crash on main screen")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testSorting() {
        viewModel.setSort(by: difficultyDef.id) // Sort ascending by default
        
        let expectation = self.expectation(description: "Sorting completes")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(self.viewModel.filteredCards.first?.title, "Refactor networking layer")
            XCTAssertEqual(self.viewModel.filteredCards[1].title, "Implement new login screen")
            XCTAssertEqual(self.viewModel.filteredCards.last?.title, "Fix crash on main screen")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testViewSwitching() {
        let newView = ViewMode(name: "Status View", displayType: .board, groupingFieldID: statusDef.id, filters: [:], sortRule: nil)
        viewModel.project.views.append(newView)
        
        viewModel.selectedViewID = newView.id
        
        XCTAssertEqual(viewModel.groupingFieldID, statusDef.id)
        XCTAssertTrue(viewModel.activeFilters.isEmpty)
        XCTAssertNil(viewModel.activeSortRule)
    }

    func testSaveNewView() {
        viewModel.saveNewView(name: "Difficulty View", displayType: .board, groupingFieldID: difficultyDef.id)
        
        XCTAssertEqual(viewModel.project.views.count, 2)
        
        let newView = viewModel.project.views.last
        XCTAssertEqual(newView?.name, "Difficulty View")
        XCTAssertEqual(newView?.groupingFieldID, difficultyDef.id)
    }
    
    func testDeleteView() {
        let viewToDelete = viewModel.project.views.first!
        viewModel.deleteView(at: IndexSet(integer: 0))
        
        XCTAssertEqual(viewModel.project.views.count, 0)
        XCTAssertNil(viewModel.selectedViewID)
    }
    
}
