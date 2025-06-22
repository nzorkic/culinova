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
    
    @ObservedObject private var auth = AuthService.shared
    @State private var uid = ""
    
    @State private var recipes: [Recipe] = []
    
    @State private var showAddSheet = false
    @State private var searchText = ""
    @State private var activeTag: Tag?    // single-tag filter
    
    private var filteredRecipes: [Recipe] {
        var set = recipes.filter { $0.owner?.firebaseUID == uid }
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
        filteredRecipes.flatMap(\.tags).forEach { tag in
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Sign Out", role: .destructive) {
                            try? AuthService.shared.signOut()
                        }
                    } label: {
                        Image(systemName: "person.crop.circle")   // profile icon
                    }
                }
            }
            .sheet(isPresented: $showAddSheet, onDismiss: {
                reload()
            }) {
                AddRecipeView()
                    .presentationDetents([.large])
            }
            .searchable(text: $searchText, prompt: "Search recipes")
            .onAppear {
                uid = auth.currentUser?.firebaseUID ?? ""
                // Defer the first fetch so SwiftData has finished opening the store.
                DispatchQueue.main.async {
                    reload()
                }
            }
            .onReceive(auth.$currentUser) { user in
                uid = user?.firebaseUID ?? ""
                reload()                            // refresh for the new user
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        // 1. Map the visible rows (filteredRecipes) back to the actual ones (recipes)
        let toDelete = offsets.map { filteredRecipes[$0] }

        withAnimation {
            // 2. Remove from context
            for recipe in toDelete {
                context.delete(recipe)
            }

            // 3. Remove from the local array immediately
            recipes.removeAll { r in toDelete.contains(where: { $0.id == r.id }) }
        }

        try? context.save()   // flush to disk

        // 4. Reload to be 100 % sure the arrays match SwiftData’s state
        reload()
    }
    
    // MARK: - Helpers
    /// Refreshes the list after an add‑sheet dismissal or user switch.
    private func reload() {
        guard let uid = auth.currentUser?.firebaseUID else {
            recipes = []
            return
        }

        // 1. Fetch ALL recipes (no predicate so we can self‑heal owners).
        let fd = FetchDescriptor<Recipe>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let all = (try? context.fetch(fd)) ?? []

        // 2. Back‑fill any legacy recipes whose owner is the current user
        //    but whose 'firebaseUID' was nil (pre‑migration data).
        for rec in all where rec.owner?.firebaseUID == nil {
            rec.owner?.firebaseUID = uid
        }

        // 3. Keep only the signed‑in user's recipes for display.
        recipes = all.filter { $0.owner?.firebaseUID == uid }
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
