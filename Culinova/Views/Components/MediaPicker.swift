//
//  MediaPicker.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//

import SwiftUI
import PhotosUI
import SwiftData

/// Presents PhotosPicker, saves the chosen image to Documents,
/// stores a thumbnail, and appends a Media row to the recipe.
struct MediaPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx

    @Bindable var recipe: Recipe
    @State private var selection: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selection,
                     matching: .images,
                     photoLibrary: .shared()) {
            Label("Add Photo", systemImage: "photo")
                .font(.headline)
        }
        .onChange(of: selection) { _, newItem in
            Task {
                guard
                    let data = try? await newItem?.loadTransferable(type: Data.self),
                    let uiImage = UIImage(data: data)
                else { return }

                // 1. Save full-size PNG to Documents
                guard let fileURL = try? ImageStorage.save(uiImage) else { return }

                // 2. Generate thumbnail
                let thumb = ImageStorage.thumbnailData(from: uiImage)

                // 3. Create Media row & attach
                let media = Media(type: .photo)
                media.localURL = fileURL
                media.thumbData = thumb
                recipe.media.append(media)

                dismiss()
            }
        }
    }
}
