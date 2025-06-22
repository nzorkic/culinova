import SwiftUI
import SwiftData

/// Form section that lets the user add, edit, delete, and reorder recipe steps.
struct StepEditorSection: View {
    @Bindable var recipe: Recipe
    @State private var draftText = ""

    var body: some View {
        Section(header: header) {
            ForEach(recipe.steps.sorted(by: { $0.order < $1.order })) { step in
                TextField(
                    "Step",
                    text: Binding(
                        get: { step.text },
                        set: { step.text = $0 }
                    )
                )
            }
            .onDelete(perform: delete)
            .onMove(perform: move)

            // Add-new row
            HStack {
                TextField("Add step", text: $draftText)
                Button {
                    addStep()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(draftText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(10)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    // MARK: - Private helpers
    private var header: some View {
        HStack {
            Text("Steps")
            Spacer()
            if !recipe.steps.isEmpty { EditButton().labelStyle(.iconOnly) }
        }
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func addStep() {
        let text = draftText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        let newOrder = (recipe.steps.map(\.order).max() ?? 0) + 1
        recipe.steps.append(Step(order: newOrder, text: text))
        draftText = ""
    }

    private func delete(at offsets: IndexSet) {
        let sorted = recipe.steps.sorted(by: { $0.order < $1.order })
        for index in offsets {
            let stepToRemove = sorted[index]
            recipe.steps.removeAll { $0.id == stepToRemove.id }
        }
        renumber()
    }

    private func move(from source: IndexSet, to destination: Int) {
        var sorted = recipe.steps.sorted(by: { $0.order < $1.order })
        sorted.move(fromOffsets: source, toOffset: destination)
        recipe.steps = sorted
        renumber()
    }

    private func renumber() {
        for (idx, step) in recipe.steps.sorted(by: { $0.order < $1.order }).enumerated() {
            step.order = idx + 1
        }
    }
}
