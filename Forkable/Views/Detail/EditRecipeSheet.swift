import SwiftUI

struct EditRecipeSheet: View {
    let recipeId: String
    @Environment(RecipeStore.self) private var store
    @Environment(ToastManager.self) private var toastManager
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var totalTime = ""
    @State private var ingredients: [Ingredient] = []
    @State private var instructions: [String] = []

    var body: some View {
        NavigationStack {
            editForm
                .background(Color.fSlateLight.ignoresSafeArea())
                .navigationTitle("Edit Recipe")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.fSlateLight, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .foregroundColor(.fMuted)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { saveRecipe() }
                            .foregroundColor(.fGreen)
                    }
                }
                .onAppear {
                    if let recipe = store.recipe(for: recipeId) {
                        name = recipe.name.replacingOccurrences(of: "_", with: " ")
                        totalTime = recipe.totalTime
                        ingredients = recipe.ingredients
                        instructions = recipe.instructions
                    }
                }
        }
        .presentationDragIndicator(.visible)
    }

    // MARK: - Form

    private var editForm: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 24) {
                nameField
                timeField
                ingredientsEditor
                instructionsEditor
            }
            .padding()
        }
    }

    // MARK: - Name

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RECIPE NAME")
                .font(.caption).fontWeight(.medium)
                .foregroundColor(.fMuted).tracking(1)
            TextField("Recipe Name", text: $name)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color.fSlateLighter)
                .cornerRadius(8)
                .foregroundColor(.fText)
        }
    }

    // MARK: - Time

    private var timeField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TOTAL TIME")
                .font(.caption).fontWeight(.medium)
                .foregroundColor(.fMuted).tracking(1)
            TextField("e.g., 2 hours", text: $totalTime)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Color.fSlateLighter)
                .cornerRadius(8)
                .foregroundColor(.fText)
        }
    }

    // MARK: - Ingredients Editor

    private var ingredientsEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("INGREDIENTS")
                .font(.caption).fontWeight(.medium)
                .foregroundColor(.fMuted).tracking(1)

            ForEach(Array(ingredients.indices), id: \.self) { idx in
                ingredientEditRow(idx)
            }

            Button {
                withAnimation {
                    ingredients.append(Ingredient(name: "", amount: 0, unit: "g"))
                }
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Ingredient")
                }
                .font(.subheadline)
                .foregroundColor(.fGreen)
            }
        }
    }

    private func ingredientEditRow(_ idx: Int) -> some View {
        HStack(spacing: 8) {
            TextField("Name", text: $ingredients[idx].name)
                .textFieldStyle(.plain)
                .foregroundColor(.fText)

            TextField("Amt", value: $ingredients[idx].amount, format: .number)
                .textFieldStyle(.plain)
                .foregroundColor(.fAmber)
                .frame(width: 60)
                .keyboardType(.decimalPad)

            TextField("Unit", text: $ingredients[idx].unit)
                .textFieldStyle(.plain)
                .foregroundColor(.fMuted)
                .frame(width: 40)

            Button {
                withAnimation { let _ = ingredients.remove(at: idx) }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.fRed.opacity(0.7))
            }
        }
        .padding(10)
        .background(Color.fSlateLighter)
        .cornerRadius(8)
    }

    // MARK: - Instructions Editor

    private var instructionsEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("INSTRUCTIONS")
                .font(.caption).fontWeight(.medium)
                .foregroundColor(.fMuted).tracking(1)

            ForEach(Array(instructions.indices), id: \.self) { idx in
                instructionEditRow(idx)
            }

            Button {
                withAnimation { instructions.append("") }
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Step")
                }
                .font(.subheadline)
                .foregroundColor(.fGreen)
            }
        }
    }

    private func instructionEditRow(_ idx: Int) -> some View {
        HStack(spacing: 8) {
            Text("\(idx + 1).")
                .font(.subheadline.monospaced())
                .foregroundColor(.fAmber)
                .frame(width: 28)

            TextField("Step", text: $instructions[idx], axis: .vertical)
                .textFieldStyle(.plain)
                .foregroundColor(.fText)

            Button {
                withAnimation { let _ = instructions.remove(at: idx) }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.fRed.opacity(0.7))
            }
        }
        .padding(10)
        .background(Color.fSlateLighter)
        .cornerRadius(8)
    }

    // MARK: - Save

    private func saveRecipe() {
        guard var recipe = store.recipe(for: recipeId) else { return }
        recipe.name = name.replacingOccurrences(of: " ", with: "_")
        recipe.totalTime = totalTime
        recipe.ingredients = ingredients.filter { !$0.name.isEmpty }
        recipe.instructions = instructions.filter { !$0.isEmpty }
        recipe.lastUpdated = "Just now"

        let commit = RecipeCommit(
            id: UUID().uuidString,
            date: "Just now",
            message: "Updated recipe",
            changes: "Edited ingredients and instructions",
            result: "Pending results"
        )
        recipe.commits.insert(commit, at: 0)

        store.updateRecipe(recipe)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        toastManager.show("Recipe updated!")
        dismiss()
    }
}
