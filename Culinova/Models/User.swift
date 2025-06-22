import Foundation
import SwiftData

@Model
final class User: Identifiable {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var username: String
    var displayName: String?
    var avatarURL: URL?

    var recipes: [Recipe] = []
    var following: [Follow] = []
    var followers: [Follow] = []
    var credentials: [AuthCredential] = []

    init(username: String) {
        id = UUID()
        self.username = username.lowercased()
    }
}
