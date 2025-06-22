//
//  IngredientDraft.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//

import SwiftUI
import SwiftData

/// Transient ingredient draft (keeps AddRecipeView decoupled from SwiftData until Save)
private struct IngredientDraft: Identifiable {
    let id = UUID()
    var name = ""
    var qty: Double?
    var unit: UnitOfMeasure?
}

struct AddRecipeView: View {
    @Environment(\.dismiss)           private var dismiss
    @Environment(\.modelContext)      private var context
    
    // Draft fields
    @State private var title = ""
    @State private var notes = ""
    
    @State private var ingredients: [IngredientDraft] = []
    @State private var steps: [String] = []
    
    @State private var draftIng = IngredientDraft()   // footer row
    @State private var draftStep = ""
    
    var body: some View {
        NavigationStack {
            Form {
                // ----- Basic meta -----
                Section("Title") {
                    TextField("Recipe title", text: $title)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                }
                
                // ----- Ingredients -----
                Section(header: Text("Ingredients")) {
                    ForEach($ingredients) { $ing in
                        IngredientDraftRow(draft: $ing)
                    }
                    .onDelete { ingredients.remove(atOffsets: $0) }
                    
                    // Add-new footer
                    IngredientDraftRow(draft: $draftIng)
                    Button {
                        guard !draftIng.name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        ingredients.append(draftIng)
                        draftIng = IngredientDraft()     // reset
                    } label: {
                        Label("Add ingredient", systemImage: "plus.circle.fill")
                    }
                    .disabled(draftIng.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                
                // ----- Steps -----
                Section(header: Text("Steps")) {
                    ForEach(steps.indices, id: \.self) { idx in
                        TextField("Step", text: Binding(
                            get: { steps[idx] },
                            set: { steps[idx] = $0 }
                        ))
                    }
                    .onDelete { steps.remove(atOffsets: $0) }
                    
                    // Add-new footer
                    HStack {
                        TextField("Add step", text: $draftStep)
                        Button {
                            let trimmed = draftStep.trimmingCharacters(in: .whitespaces)
                            guard !trimmed.isEmpty else { return }
                            steps.append(trimmed)
                            draftStep = ""
                        } label: { Image(systemName: "plus.circle.fill") }
                            .disabled(draftStep.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(10)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .navigationTitle("New Recipe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: dismiss.callAsFunction) }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .buttonStyle(AccentButtonStyle())
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    // MARK: - Save
    private func save() {
        // 1. Fold the un-committed rows into the real arrays
        if !draftIng.name.trimmingCharacters(in: .whitespaces).isEmpty {
            ingredients.append(draftIng)
        }
        let trimmedStep = draftStep.trimmingCharacters(in: .whitespaces)
        if !trimmedStep.isEmpty {
            steps.append(trimmedStep)
        }
        
        // 2. Build the SwiftData objects as before
        let recipe = Recipe(title: title)
        recipe.notes = notes
        
        recipe.ingredients = ingredients.map {
            Ingredient(name: $0.name,
                       quantity: $0.qty,
                       unit: $0.unit)
        }
        for (idx, txt) in steps.enumerated() {
            recipe.steps.append(Step(order: idx + 1, text: txt))
        }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            context.insert(recipe)
        }
        
        dismiss()
    }
}

/// Row used both in the ingredient list and add-new footer
private struct IngredientDraftRow: View {
    @Binding var draft: IngredientDraft
    
    var body: some View {
        HStack(spacing: 8) {
            TextField("Name", text: $draft.name)
            Spacer(minLength: 4)
            TextField("Qty",
                      value: $draft.qty,
                      format: .number)
            .frame(maxWidth: 60)
            .keyboardType(.decimalPad)
            Picker("", selection: $draft.unit) {
                Text("—").tag(UnitOfMeasure?.none)
                ForEach(UnitOfMeasure.allCases) { u in
                    Text(u.display).tag(Optional(u))
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
