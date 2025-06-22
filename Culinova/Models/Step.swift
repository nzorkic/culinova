import Foundation
import SwiftData

@Model
final class Step: Identifiable {
    @Attribute(.unique) var id: UUID
    var order: Int
    var text: String
    var timerSeconds: Int?

    @Relationship(inverse: \Recipe.steps) var recipe: Recipe?

    init(order: Int, text: String) {
        id = UUID()
        self.order = order
        self.text = text
    }
}
