// Models/Media.swift
import Foundation
import SwiftData

enum MediaType: String, Codable, CaseIterable {
    case photo, video
}

@Model
final class Media: Identifiable {
    @Attribute(.unique) var id: UUID
    var type: MediaType
    var localURL: URL?    // sandbox file
    var remoteURL: URL?   // iCloud or CDN
    var thumbData: Data?  // omit thumbData and derive thumbnails on the fly if storage is a concern.

    @Relationship(inverse: \Recipe.media) var recipe: Recipe?

    init(type: MediaType) {
        id = UUID()
        self.type = type
    }
}
