//
//  AddRecipeTests.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//

import XCTest
@testable import Culinova
import SwiftData

final class AddRecipeTests: XCTestCase {

    // MARK: - Test-scoped container / context
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        container = try ModelContainer(
            for: Recipe.self,
                 Ingredient.self,
                 Step.self,
                 Tag.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = ModelContext(container)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    // MARK: - Helpers
    /// Mimics the save() method in `AddRecipeView`.
    private func insertRecipe(title: String,
                              notes: String = "",
                              ingredients: [(String, Double?, UnitOfMeasure?)] = [],
                              steps: [String] = []) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let recipe = Recipe(title: title)
        recipe.notes = notes

        recipe.ingredients = ingredients.map {
            Ingredient(name: $0.0, quantity: $0.1, unit: $0.2)
        }
        for (idx, txt) in steps.enumerated() {
            recipe.steps.append(Step(order: idx + 1, text: txt))
        }
        context.insert(recipe)
    }

    // MARK: - Tests
    func testSuccessfulAddPersistsRecipe() throws {
        // GIVEN
        let ingredientDrafts = [
            ("Flour", 250.0, UnitOfMeasure.g),
            ("Milk", 300.0, UnitOfMeasure.ml)
        ]
        let stepDrafts = ["Mix dry ingredients", "Add milk", "Bake"]

        // WHEN
        insertRecipe(title: "Test Cake",
                     notes: "Yummy",
                     ingredients: ingredientDrafts,
                     steps: stepDrafts)

        // THEN
        let fetchDescriptor = FetchDescriptor<Recipe>()
        let stored = try context.fetch(fetchDescriptor)
        XCTAssertEqual(stored.count, 1, "Exactly one recipe should be saved")

        let saved = stored.first!
        XCTAssertEqual(saved.title, "Test Cake")
        XCTAssertEqual(saved.ingredients.count, 2)
        XCTAssertEqual(saved.steps.count, 3)

        // Ingredient fields
        if let flour = saved.ingredients.first(where: { $0.name == "Flour" }) {
            XCTAssertEqual(flour.quantity, 250)
            XCTAssertEqual(flour.unit, .g)
        } else {
            XCTFail("Flour not saved")
        }
    }

    func testBlankTitleDoesNotInsert() throws {
        // WHEN
        insertRecipe(title: "    ")    // only spaces

        // THEN
        let stored = try context.fetch(FetchDescriptor<Recipe>())
        XCTAssertTrue(stored.isEmpty, "Recipe with blank title should not be inserted")
    }
}
