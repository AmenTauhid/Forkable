import SwiftUI

struct MergeReviewView: View {
    let recipe: Recipe
    let branch: Branch
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                branchInfoCard
                diffSection
                tastingNotesSection
                changeSummarySection
                actionButtons
            }
            .padding()
            .padding(.bottom, 90)
        }
        .background(Color.fSlate)
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

    // MARK: - Branch Info

    private var branchInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: branch.authorAvatar)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Circle().fill(Color.fSlateLighter)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.fAmber.opacity(0.2), lineWidth: 2))

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

    private var diffSection: some View {
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
    private var tastingNotesSection: some View {
        if let notes = branch.tastingNotes {
            VStack(alignment: .leading, spacing: 8) {
                Text("TASTING NOTES")
                    .font(.caption).fontWeight(.medium)
                    .foregroundColor(.fMuted).tracking(1)

                HStack(alignment: .top, spacing: 12) {
                    AsyncImage(url: URL(string: branch.authorAvatar)) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Circle().fill(Color.fSlateLighter)
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.fAmber.opacity(0.2), lineWidth: 2))

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

    private var changeSummarySection: some View {
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

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button { dismiss() } label: {
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

            Button { dismiss() } label: {
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
