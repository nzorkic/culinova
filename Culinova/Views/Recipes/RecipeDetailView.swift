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
    
    @State private var draftTag = ""
    
    private let tagColumns = [GridItem(.adaptive(minimum: 80), spacing: 8)]
    
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
            Section("Tags") {
                LazyVGrid(columns: tagColumns, alignment: .leading, spacing: 8) {
                    ForEach(recipe.tags) { tag in
                        HStack(spacing: 4) {
                            TagChip(text: tag.label)
                            Button(action: {
                                recipe.tags.removeAll { $0.id == tag.id }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // quick add
                HStack {
                    TextField("New tag", text: $draftTag)
                        .textInputAutocapitalization(.never)
                    Button("Add") {
                        addTag()
                    }
                    .disabled(draftTag.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            IngredientEditorSection(recipe: recipe)
            StepEditorSection(recipe: recipe)
        }
    }
    
    private func addTag() {
        let clean = draftTag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !clean.isEmpty,
              !recipe.tags.contains(where: { $0.label == clean }) else { return }
        recipe.tags.append(Tag(label: clean))
        draftTag = ""
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
