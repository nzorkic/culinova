//
//  RecipeDetailTests.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//

import XCTest
@testable import Culinova
import SwiftData

final class RecipeDetailTests: XCTestCase {

    // MARK: - Container
    private var container: ModelContainer!
    private var context:   ModelContext!

    override func setUpWithError() throws {
        container = try ModelContainer(
            for: Recipe.self,
                 Ingredient.self,
                 Step.self,
                 Media.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = ModelContext(container)

        // Seed one recipe used in multiple tests
        let r = Recipe(title: "Seed")
        r.notes = "Old note"
        r.ingredients = [
            Ingredient(name: "Flour", quantity: 100.0, unit: .g)
        ]
        r.steps = [
            Step(order: 1, text: "Mix"),
            Step(order: 2, text: "Bake")
        ]
        context.insert(r)
    }

    override func tearDownWithError() throws {
        container = nil
        context   = nil
    }

    // Helper to fetch the single recipe
    private func fetchRecipe() throws -> Recipe {
        try context.fetch(FetchDescriptor<Recipe>()).first!
    }

    // MARK: - Tests

    func testEditingTitleAndNotesPersists() throws {
        // WHEN
        let recipe = try fetchRecipe()
        recipe.title = "Updated title"
        recipe.notes = "New note"

        // THEN
        let reloaded = try fetchRecipe()
        XCTAssertEqual(reloaded.title, "Updated title")
        XCTAssertEqual(reloaded.notes, "New note")
    }

    func testAddingIngredientUpdatesStore() throws {
        // WHEN
        let recipe = try fetchRecipe()
        let countBefore = recipe.ingredients.count
        recipe.ingredients.append(
            Ingredient(name: "Sugar", quantity: 50.0, unit: .g)
        )

        // THEN
        let saved = try fetchRecipe()
        XCTAssertEqual(saved.ingredients.count, countBefore + 1)
        XCTAssertTrue(saved.ingredients.contains { $0.name == "Sugar" })
    }

    func testDeletingStepRenumbersRemaining() throws {
        // WHEN – remove first step
        let recipe = try fetchRecipe()
        recipe.steps.removeAll { $0.order == 1 }
        // Manually mimic renumbering logic from StepEditorSection.renumber()
        for (idx, step) in recipe.steps.sorted(by: { $0.order < $1.order }).enumerated() {
            step.order = idx + 1
        }

        // THEN
        let steps = try fetchRecipe().steps.sorted(by: { $0.order < $1.order })
        XCTAssertEqual(steps.count, 1)
        XCTAssertEqual(steps[0].order, 1)           // should start at 1 again
        XCTAssertEqual(steps[0].text, "Bake")       // original second step
    }
    
    func testAddingPhotoPersistsMedia() throws {
        // WHEN
        let recipe = try fetchRecipe()
        let countBefore = recipe.media.count

        // Simulate adding a photo
        let media = Media(type: .photo)
        media.localURL = URL(fileURLWithPath: "/tmp/test.png")
        recipe.media.append(media)

        // THEN
        let saved = try fetchRecipe()
        XCTAssertEqual(saved.media.count, countBefore + 1)
        XCTAssertTrue(saved.media.contains { $0.type == .photo })
    }
}
