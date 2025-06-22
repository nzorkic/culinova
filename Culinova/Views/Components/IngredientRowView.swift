//
//  IngredientRowView.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//


import SwiftUI
import SwiftData

struct IngredientRowView: View {
    @Bindable var ingredient: Ingredient

    var body: some View {
        HStack(spacing: 8) {
            TextField("Ingredient", text: $ingredient.name)
            Spacer(minLength: 4)
            TextField("Qty",
                      value: Binding($ingredient.quantity, 0),
                      format: .number)
                .frame(maxWidth: 60)
                .keyboardType(.decimalPad)
            Picker("", selection: Binding($ingredient.unit)) {
                Text("—").tag(UnitOfMeasure?.none)
                ForEach(UnitOfMeasure.allCases) { u in
                    Text(u.display).tag(Optional<UnitOfMeasure>(u))
                }
            }
            .pickerStyle(.menu)
        }
    }
}
