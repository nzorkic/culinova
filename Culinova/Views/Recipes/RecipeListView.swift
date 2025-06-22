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
    @Query private var allTags: [Tag]
    
    @State private var showAddSheet = false
    @State private var searchText = ""
    @State private var activeTag: Tag?    // single-tag filter
    
    private var filteredRecipes: [Recipe] {
        var set = recipes
        if let tag = activeTag {
            set = set.filter { $0.tags.contains(where: { $0.label == tag.label }) }
        }
        if !searchText.isEmpty {
            set = set.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        return set
    }
    
    /// Unique tags pulled from the current recipe set
    private var usedTags: [Tag] {
        var dict: [String: Tag] = [:]
        recipes.flatMap(\.tags).forEach { tag in
            if dict[tag.label] == nil { dict[tag.label] = tag }
        }
        return dict.values.sorted { $0.label < $1.label }
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
                ToolbarItem {
                    Menu {
                        Button("All Recipes") { activeTag = nil }
                        ForEach(usedTags.sorted(by: { $0.label < $1.label })) { tag in
                            Button(tag.label.capitalized) { activeTag = tag }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
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
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 4)],
                          alignment: .leading,
                          spacing: 4) {
                    ForEach(recipe.tags.prefix(3)) { tag in
                        TagChip(text: tag.label)
                    }
                }
                          .font(.caption)
                
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
