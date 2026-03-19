import SwiftUI

struct ForkTweakSheet: View {
    let recipeId: String
    @Environment(RecipeStore.self) private var store
    @Environment(ToastManager.self) private var toastManager
    @State private var tweakedIngredients: [Ingredient] = []
    @State private var commitMessage = ""
    @State private var branchName = ""
    @Environment(\.dismiss) private var dismiss

    private var recipe: Recipe? {
        store.recipe(for: recipeId)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let recipe {
                    VStack(spacing: 24) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.triangle.branch")
                                .foregroundColor(.fAmber)
                            Text("Fork & Tweak Recipe")
                                .font(.headline)
                                .foregroundColor(.fText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Branch Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("BRANCH NAME")
                                .font(.caption).fontWeight(.medium)
                                .foregroundColor(.fMuted).tracking(1)

                            TextField("e.g., Extra Crispy Version", text: $branchName)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(Color.fSlateLighter)
                                .cornerRadius(8)
                                .foregroundColor(.fText)
                        }

                        // Ingredients
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ADJUST VARIABLES")
                                .font(.caption).fontWeight(.medium)
                                .foregroundColor(.fMuted).tracking(1)

                            ForEach(Array(tweakedIngredients.indices), id: \.self) { idx in
                                ingredientRow(index: idx, recipe: recipe)
                            }
                        }

                        // Commit Message
                        VStack(alignment: .leading, spacing: 8) {
                            Text("COMMIT MESSAGE")
                                .font(.caption).fontWeight(.medium)
                                .foregroundColor(.fMuted).tracking(1)

                            TextField("What's the goal of this tweak?", text: $commitMessage, axis: .vertical)
                                .lineLimit(3...5)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(Color.fSlateLighter)
                                .cornerRadius(8)
                                .foregroundColor(.fText)
                        }

                        Button { createBranch() } label: {
                            Text("Start Bake (Create Branch)")
                                .font(.headline)
                                .foregroundColor(.fSlate)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(branchName.isEmpty ? Color.fSlateLighter : Color.fGreen)
                                .cornerRadius(10)
                        }
                        .disabled(branchName.isEmpty)
                    }
                    .padding()
                }
            }
            .background(Color.fSlateLight.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.fMuted)
                }
            }
        }
        .onAppear {
            if let recipe {
                tweakedIngredients = recipe.ingredients
            }
        }
        .presentationDragIndicator(.visible)
    }

    // MARK: - Ingredient Row

    private func ingredientRow(index idx: Int, recipe: Recipe) -> some View {
        let safeIdx = min(idx, recipe.ingredients.count - 1)
        let originalMax = safeIdx >= 0 ? max(recipe.ingredients[safeIdx].amount * 2.5, 20) : 500
        let step: Double = tweakedIngredients[idx].unit == "whole" ? 1 : 5

        return VStack(spacing: 8) {
            HStack {
                Text(tweakedIngredients[idx].name)
                    .font(.subheadline)
                    .foregroundColor(.fText)

                Spacer()

                HStack(spacing: 8) {
                    Button {
                        tweakedIngredients[idx].amount = max(0, tweakedIngredients[idx].amount - step)
                        recalculatePercentages()
                    } label: {
                        Image(systemName: "minus")
                            .font(.caption)
                            .foregroundColor(.fMuted)
                            .frame(width: 28, height: 28)
                            .background(Color.fSlateLighter)
                            .cornerRadius(6)
                    }

                    HStack(spacing: 2) {
                        Text("\(tweakedIngredients[idx].amount, specifier: "%g")\(tweakedIngredients[idx].unit)")
                            .foregroundColor(.fAmber)
                        if let pct = tweakedIngredients[idx].percentage {
                            Text("(\(pct, specifier: "%.1f")%)")
                                .foregroundColor(.fMuted)
                                .font(.caption)
                        }
                    }
                    .font(.system(.subheadline, design: .monospaced))
                    .frame(minWidth: 90, alignment: .center)

                    Button {
                        tweakedIngredients[idx].amount += step
                        recalculatePercentages()
                    } label: {
                        Image(systemName: "plus")
                            .font(.caption)
                            .foregroundColor(.fMuted)
                            .frame(width: 28, height: 28)
                            .background(Color.fSlateLighter)
                            .cornerRadius(6)
                    }
                }
            }

            Slider(
                value: $tweakedIngredients[idx].amount,
                in: 0...originalMax,
                step: step
            )
            .tint(.fAmber)
            .onChange(of: tweakedIngredients[idx].amount) {
                recalculatePercentages()
            }
        }
    }

    private func recalculatePercentages() {
        guard let flourIdx = tweakedIngredients.firstIndex(where: {
            $0.name.lowercased().contains("flour")
        }) else { return }

        let flourAmount = tweakedIngredients[flourIdx].amount
        guard flourAmount > 0 else { return }

        for i in tweakedIngredients.indices {
            if i != flourIdx && tweakedIngredients[i].percentage != nil {
                tweakedIngredients[i].percentage =
                    (tweakedIngredients[i].amount / flourAmount * 100 * 10).rounded() / 10
            }
        }
    }

    private func createBranch() {
        let branch = Branch(
            id: UUID().uuidString,
            name: branchName,
            authorName: "You",
            authorAvatar: "",
            message: commitMessage.isEmpty ? "Tweaked ingredient amounts" : commitMessage,
            createdAt: "Just now",
            ingredients: tweakedIngredients,
            tastingNotes: nil
        )

        store.addBranch(to: recipeId, branch: branch, commitMessage: commitMessage)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        toastManager.show("Branch created!")
        dismiss()
    }
}
