import Foundation
import SwiftData

@Model
final class Ingredient: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var quantity: Double?
    var unit: UnitOfMeasure?
    var note: String?

    @Relationship(inverse: \Recipe.ingredients) var recipe: Recipe?

    init(name: String,
         quantity: Double? = nil,
         unit: UnitOfMeasure? = nil,
         note: String? = nil) {
        id = UUID()
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.note = note
    }
}
