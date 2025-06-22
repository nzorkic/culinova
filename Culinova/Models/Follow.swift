import Foundation
import SwiftData

@Model
final class Follow: Identifiable {
    @Attribute(.unique) var id: UUID
    var createdAt: Date

    @Relationship var follower: User
    @Relationship var followee: User

    init(follower: User, followee: User) {
        id = UUID()
        createdAt = .now
        self.follower = follower
        self.followee = followee
    }
}
