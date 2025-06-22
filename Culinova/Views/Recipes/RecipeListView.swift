//
//  RecipeListView.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//

import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Namespace private var heroNS
    @Namespace private var recipeNS
    @Environment(\.modelContext) private var context
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]
    
    @State private var showAddSheet = false
    @State private var searchText = ""

    /// Returns full list or subset that matches the search text (case‑insensitive)
    private var filteredRecipes: [Recipe] {
        guard !searchText.isEmpty else { return recipes }
        return recipes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredRecipes) { recipe in
                    NavigationLink(value: recipe) {
                        RecipeRowView(recipe: recipe)
                            .cardStyle()
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { EditButton() }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddSheet = true }) { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddRecipeView()
                    .presentationDetents([.large])
            }
            .searchable(text: $searchText, prompt: "Search recipes")
        }
    }
    
    private func delete(at offsets: IndexSet) {
        for index in offsets {
            context.delete(recipes[index])
        }
    }
}

private struct RecipeRowView: View {
    let recipe: Recipe
    
    var body: some View {
        let thumb = recipe.media.first(where: { $0.type == .photo })?.thumbData

        HStack {
            if let data = thumb, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title.isEmpty ? "Untitled" : recipe.title)
                    .font(.headline)
                    .foregroundStyle(Theme.navy)
                
                // Optional subtitle
                if let firstIng = recipe.ingredients.first?.name {
                    Text(firstIng)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    let previewContainer = try! ModelContainer(
        for: Recipe.self,
        Ingredient.self,
        Step.self,
        Tag.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let ctx = ModelContext(previewContainer)
    ctx.insert(Recipe(title: "Preview Pancakes"))
    return RecipeListView()
        .searchable(text: .constant(""), prompt: "Search")
        .modelContext(ctx)
}
