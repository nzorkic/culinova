//
//  RecipeListView.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//

import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]

    var body: some View {
        NavigationStack {
            List {
                ForEach(recipes) { recipe in
                    NavigationLink(value: recipe) {
                        Text(recipe.title.isEmpty ? "Untitled" : recipe.title)
                            .font(.headline)
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
                    Button(action: add) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    // MARK: - CRUD helpers
    private func add() {
        let new = Recipe(title: "")
        context.insert(new)
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            context.delete(recipes[index])
        }
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
    return RecipeListView().modelContext(ctx)
}
