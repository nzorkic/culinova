//
//  ImageStorage.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//

import SwiftUI

enum ImageStorage {

    /// Saves `UIImage` as PNG, returns file URL.
    static func save(_ image: UIImage) throws -> URL {
        let filename = UUID().uuidString + ".png"
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)

        try image.pngData()?.write(to: url, options: .atomic)
        return url
    }

    /// Tiny square thumb (max 128 px) returned as `Data`.
    static func thumbnailData(from image: UIImage) -> Data? {
        let maxDimension: CGFloat = 128
        let ratio = maxDimension / Swift.max(image.size.width, image.size.height)
        let size  = CGSize(width: image.size.width * ratio,
                           height: image.size.height * ratio)

        return UIGraphicsImageRenderer(size: size).pngData { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    /// Helper to load a `UIImage` from `URL`.
    static func loadImage(at url: URL?) -> UIImage? {
        guard let url, let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
