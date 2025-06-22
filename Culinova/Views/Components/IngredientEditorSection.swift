//
//  IngredientEditorSection.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//


import SwiftUI
import SwiftData

struct IngredientEditorSection: View {
    @Bindable var recipe: Recipe
    @State private var draftName = ""
    @State private var draftQty: Double?
    @State private var draftUnit: UnitOfMeasure?

    var body: some View {
        Section(header: header) {
            ForEach(recipe.ingredients) { ingredient in
                IngredientRowView(ingredient: ingredient)
            }
            .onDelete { offsets in recipe.ingredients.remove(atOffsets: offsets) }

            //  Add-new row
            HStack {
                TextField("Add ingredient", text: $draftName)
                TextField("Qty",
                          value: $draftQty,
                          format: .number)
                    .frame(maxWidth: 60)
                    .keyboardType(.decimalPad)
                Picker("", selection: $draftUnit) {
                    Text("—").tag(UnitOfMeasure?.none)
                    ForEach(UnitOfMeasure.allCases) { u in
                        Text(u.display).tag(Optional(u))
                    }
                }
                .pickerStyle(.menu)

                Button {
                    addIngredient()
                } label: { Image(systemName: "plus.circle.fill") }
                .disabled(draftName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(10)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private var header: some View {
        HStack {
            Text("Ingredients")
            Spacer()
            if !recipe.ingredients.isEmpty { EditButton().labelStyle(.iconOnly) }
        }
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func addIngredient() {
        let name = draftName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let ing = Ingredient(name: name,
                             quantity: draftQty,
                             unit: draftUnit)
        recipe.ingredients.append(ing)
        draftName = ""
        draftQty = nil
        draftUnit = nil
    }
}
