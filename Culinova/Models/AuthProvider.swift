import Foundation
import SwiftData
import AuthenticationServices

enum AuthProvider: String, Codable {
    case password, passkey, apple, google
}

@Model
final class AuthCredential: Identifiable {
    @Attribute(.unique) var id: UUID
    var provider: AuthProvider
    var externalUserID: String?      // Apple/Google sub
    var credentialID: Data?          // Passkey
    var createdAt: Date

    @Relationship var user: User

    init(provider: AuthProvider, user: User) {
        id = UUID()
        self.provider = provider
        self.createdAt = .now
        self.user = user
    }
}
