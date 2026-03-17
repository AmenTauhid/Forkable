import SwiftUI

struct ForkTweakSheet: View {
    let recipe: Recipe
    @State private var tweakedIngredients: [Ingredient] = []
    @State private var commitMessage = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.branch")
                            .foregroundColor(.fAmber)
                        Text("Fork & Tweak Recipe")
                            .font(.headline)
                            .foregroundColor(.fText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Ingredients
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ADJUST VARIABLES")
                            .font(.caption).fontWeight(.medium)
                            .foregroundColor(.fMuted).tracking(1)

                        ForEach(Array(tweakedIngredients.indices), id: \.self) { idx in
                            ingredientRow(index: idx)
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

                    Button { dismiss() } label: {
                        Text("Start Bake (Create Branch)")
                            .font(.headline)
                            .foregroundColor(.fSlate)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.fGreen)
                            .cornerRadius(10)
                    }
                }
                .padding()
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
            tweakedIngredients = recipe.ingredients
        }
        .presentationDragIndicator(.visible)
    }

    // MARK: - Ingredient Row

    private func ingredientRow(index idx: Int) -> some View {
        let originalMax = max(recipe.ingredients[idx].amount * 2.5, 20)
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
}
