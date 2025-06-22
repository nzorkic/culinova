// Models/Recipe.swift
import Foundation
import SwiftData

@Model
final class Recipe: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var summary: String?
    var createdAt: Date
    var updatedAt: Date
    var servings: Int?
    var prepTime: Int?
    var cookTime: Int?
    var notes: String?

    // Relationships
    var ingredients: [Ingredient] = []
    var steps: [Step] = []
    var tags: [Tag] = []
    var media: [Media] = []

    @Relationship(inverse: \User.recipes)
    var owner: User? // keep optional for migration safety

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.createdAt = .now
        self.updatedAt = .now
    }
}
