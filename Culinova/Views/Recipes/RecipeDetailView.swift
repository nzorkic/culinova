//
//  RecipeDetailView.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//


import SwiftUI
import SwiftData
import PhotosUI

struct RecipeDetailView: View {
    @Bindable var recipe: Recipe
    
    @State private var photoSelection: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 0) {                               // single root view
            header
            formBody
        }
        .navigationTitle(recipe.title.isEmpty ? "Recipe" : recipe.title)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: photoSelection) { _, newItem in
            Task { await handlePhoto(newItem) }
        }
    }
    
    // MARK: - Header
    private var header: some View {
        PhotosPicker(selection: $photoSelection,
                     matching: .images,
                     photoLibrary: .shared()) {
            ZStack(alignment: .bottomTrailing) {
                if let img = recipe.media.first(where: { $0.type == .photo })?.image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Theme.sky
                    Label("Add Photo", systemImage: "photo")
                        .font(.title3).bold()
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            .frame(height: 220)
            .clipped()
        }
                     .buttonStyle(.plain)
    }
    
    // MARK: - Form
    private var formBody: some View {
        Form {
            Section("Title") {
                TextField("Recipe title", text: $recipe.title)
            }
            Section("Notes") {
                TextEditor(text: Binding($recipe.notes))
                    .frame(minHeight: 120)
            }
            IngredientEditorSection(recipe: recipe)
            StepEditorSection(recipe: recipe)
        }
    }
    
    // MARK: - Photo handler
    private func handlePhoto(_ item: PhotosPickerItem?) async {
        guard
            let data = try? await item?.loadTransferable(type: Data.self),
            let uiImage = UIImage(data: data),
            let url     = try? ImageStorage.save(uiImage)
        else { return }
        
        let thumb = ImageStorage.thumbnailData(from: uiImage)
        let media = Media(type: .photo)
        media.localURL = url
        media.thumbData = thumb
        recipe.media.append(media)
    }
}
