import Foundation
import SwiftData

@Model
final class Tag: Identifiable {
    @Attribute(.unique) var id: UUID
    var label: String
    var recipes: [Recipe] = []      // many-to-many

    init(label: String) {
        id = UUID()
        self.label = label.lowercased()
    }
}
