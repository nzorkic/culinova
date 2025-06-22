//
//  RecipeDetailView.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//


import SwiftUI

struct RecipeDetailView: View {
    @Bindable var recipe: Recipe

    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Recipe title", text: $recipe.title)
            }

            Section(header: Text("Notes")) {
                TextEditor(text: Binding($recipe.notes))
                    .frame(minHeight: 120)
            }

            IngredientEditorSection(recipe: recipe)
            StepEditorSection(recipe: recipe)
        }
        .navigationTitle(recipe.title.isEmpty ? "Recipe" : recipe.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
