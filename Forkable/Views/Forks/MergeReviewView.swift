import SwiftUI

struct MergeReviewView: View {
    let recipeId: String
    let branchId: String
    @Environment(RecipeStore.self) private var store
    @Environment(ToastManager.self) private var toastManager
    @Environment(\.dismiss) private var dismiss

    private var recipe: Recipe? {
        store.recipe(for: recipeId)
    }

    private var branch: Branch? {
        recipe?.branches.first { $0.id == branchId }
    }

    var body: some View {
        Group {
            if let recipe, let branch {
                mergeContent(recipe: recipe, branch: branch)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(.fGreen)
                    Text("Branch merged or not found")
                        .foregroundColor(.fMuted)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.fSlate)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.fSlate, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.merge")
                        .foregroundColor(.fAmber)
                    Text("Merge Review")
                        .font(.headline)
                        .foregroundColor(.fText)
                }
            }
        }
    }

    private func mergeContent(recipe: Recipe, branch: Branch) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                branchInfoCard(branch)
                diffSection(recipe: recipe, branch: branch)
                tastingNotesSection(branch)
                changeSummarySection(recipe: recipe, branch: branch)
                actionButtons(recipe: recipe, branch: branch)
            }
            .padding()
            .padding(.bottom, 90)
        }
        .background(Color.fSlate)
    }

    // MARK: - Branch Info

    private func branchInfoCard(_ branch: Branch) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                initialsAvatar(name: branch.authorName, size: 40)

                VStack(alignment: .leading) {
                    Text(branch.name)
                        .font(.headline).foregroundColor(.fText)
                    Text("by \(branch.authorName) \u{2022} \(branch.createdAt)")
                        .font(.caption).foregroundColor(.fMuted)
                }
            }

            Text("\"\(branch.message)\"")
                .font(.subheadline).foregroundColor(.fMuted).italic()

            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill").font(.caption)
                Text("Ready to merge").font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.fGreen.opacity(0.2))
            .foregroundColor(.fGreen)
            .cornerRadius(6)
        }
        .padding()
        .background(Color.fSlateLight)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1)))
    }

    // MARK: - Side-by-Side Diff

    private func diffSection(recipe: Recipe, branch: Branch) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("VISUAL DIFF: INGREDIENTS")
                .font(.caption).fontWeight(.medium)
                .foregroundColor(.fMuted).tracking(1)

            HStack(alignment: .top, spacing: 8) {
                diffColumn(
                    title: "MASTER",
                    ingredients: recipe.ingredients,
                    compareAgainst: branch.ingredients,
                    isMaster: true
                )

                diffColumn(
                    title: "\(branch.authorName.uppercased())'S FORK",
                    ingredients: branch.ingredients,
                    compareAgainst: recipe.ingredients,
                    isMaster: false
                )
            }
        }
    }

    private func diffColumn(title: String, ingredients: [Ingredient],
                            compareAgainst: [Ingredient], isMaster: Bool) -> some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.fMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color.fSlateLighter)

            VStack(spacing: 4) {
                ForEach(ingredients) { ing in
                    let counterpart = compareAgainst.first { $0.name == ing.name }
                    let isDifferent = counterpart != nil && counterpart!.amount != ing.amount
                    let isNew = counterpart == nil && !isMaster
                    let isRemoved = counterpart == nil && isMaster

                    HStack(spacing: 2) {
                        Text(ing.name)
                            .foregroundColor(isRemoved ? .fMuted : .fText)
                            .lineLimit(1)
                            .strikethrough(isRemoved)

                        if isNew {
                            Text("NEW")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundColor(.fSlate)
                                .padding(.horizontal, 3)
                                .padding(.vertical, 1)
                                .background(Color.fGreen)
                                .cornerRadius(2)
                        }

                        Spacer()

                        Text("\(ing.amount, specifier: "%g")\(ing.unit)")
                            .foregroundColor(
                                isDifferent || isNew ? (isMaster ? .fAmber : .fGreen) : .fAmber
                            )
                    }
                    .font(.system(.caption2, design: .monospaced))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 6)
                    .background(
                        isDifferent ? (isMaster ? Color.fRed.opacity(0.1) : Color.fGreen.opacity(0.1)) :
                            isNew ? Color.fGreen.opacity(0.2) : .clear
                    )
                    .cornerRadius(4)
                }
            }
            .padding(8)
        }
        .background(Color.fSlateLight)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.1)))
    }

    // MARK: - Tasting Notes

    @ViewBuilder
    private func tastingNotesSection(_ branch: Branch) -> some View {
        if let notes = branch.tastingNotes {
            VStack(alignment: .leading, spacing: 8) {
                Text("TASTING NOTES")
                    .font(.caption).fontWeight(.medium)
                    .foregroundColor(.fMuted).tracking(1)

                HStack(alignment: .top, spacing: 12) {
                    initialsAvatar(name: branch.authorName, size: 32)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(branch.authorName)
                            .font(.subheadline).fontWeight(.medium)
                            .foregroundColor(.fText)
                        Text(notes)
                            .font(.subheadline).foregroundColor(.fMuted)
                    }
                }
                .padding()
                .background(Color.fSlateLight)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1)))
            }
        }
    }

    // MARK: - Change Summary

    private func changeSummarySection(recipe: Recipe, branch: Branch) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CHANGE SUMMARY")
                .font(.caption).fontWeight(.medium)
                .foregroundColor(.fMuted).tracking(1)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(branch.ingredients) { branchIng in
                    let masterIng = recipe.ingredients.first { $0.name == branchIng.name }
                    if masterIng == nil {
                        Text("+ Added \(branchIng.name): \(branchIng.amount, specifier: "%g")\(branchIng.unit)")
                            .foregroundColor(.fGreen)
                    } else if masterIng!.amount != branchIng.amount {
                        Text("~ Modified \(branchIng.name): \(masterIng!.amount, specifier: "%g")\(masterIng!.unit) \u{2192} \(branchIng.amount, specifier: "%g")\(branchIng.unit)")
                            .foregroundColor(.fAmber)
                    }
                }
                ForEach(recipe.ingredients) { masterIng in
                    if !branch.ingredients.contains(where: { $0.name == masterIng.name }) {
                        Text("- Removed \(masterIng.name)")
                            .foregroundColor(.fRed)
                    }
                }
            }
            .font(.system(.caption, design: .monospaced))
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.fSlateLight)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1)))
        }
    }

    // MARK: - Action Buttons

    private func actionButtons(recipe: Recipe, branch: Branch) -> some View {
        VStack(spacing: 12) {
            Button {
                store.mergeBranch(branchId, into: recipeId)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                toastManager.show("Merged into master!")
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "checkmark")
                    Text("Merge into Master")
                }
                .font(.headline)
                .foregroundColor(.fSlate)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.fGreen)
                .cornerRadius(10)
            }

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                toastManager.show("Kept as separate fork")
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "xmark")
                    Text("Keep as Separate Fork")
                }
                .font(.headline)
                .foregroundColor(.fText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.2)))
            }
        }
    }
}
