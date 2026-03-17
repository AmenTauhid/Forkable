import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var expandedCommit: String?
    @State private var showForkSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Recipe Image
                AsyncImage(url: URL(string: recipe.image)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color.fSlateLighter)
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Badges & Fork Button
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.branch").font(.caption2)
                            Text("\(recipe.activeForks) forks").font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.fGreen.opacity(0.2))
                        .foregroundColor(.fGreen)
                        .cornerRadius(6)

                        HStack(spacing: 4) {
                            Image(systemName: "clock").font(.caption)
                            Text(recipe.totalTime).font(.subheadline.monospaced())
                        }
                        .foregroundColor(.fMuted)

                        Spacer()
                    }

                    Button { showForkSheet = true } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.branch")
                            Text("Fork & Tweak")
                        }
                        .font(.headline)
                        .foregroundColor(.fSlate)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.fAmber)
                        .cornerRadius(10)
                    }
                }

                // Ingredients
                ingredientsSection

                // Instructions
                if !recipe.instructions.isEmpty {
                    instructionsSection
                }

                // Commit History
                commitHistorySection

                // Active Branches
                if !recipe.branches.isEmpty {
                    branchesSection
                }
            }
            .padding()
            .padding(.bottom, 90)
        }
        .background(Color.fSlate)
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.fSlate, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showForkSheet) {
            ForkTweakSheet(recipe: recipe)
        }
    }

    // MARK: - Ingredients

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Ingredients (Variables)")

            VStack(spacing: 8) {
                ForEach(recipe.ingredients) { ing in
                    HStack {
                        Text(ing.name).foregroundColor(.fText)
                        Spacer()
                        HStack(spacing: 4) {
                            Text("\(ing.amount, specifier: "%g")\(ing.unit)")
                                .foregroundColor(.fAmber)
                            if let pct = ing.percentage {
                                Text("(\(pct, specifier: "%g")%)")
                                    .foregroundColor(.fMuted)
                            }
                        }
                    }
                    .font(.system(.subheadline, design: .monospaced))
                }
            }
            .padding()
            .background(Color.fSlateLight)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1)))
        }
    }

    // MARK: - Instructions

    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Instructions")

            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { idx, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text(String(format: "%02d.", idx + 1))
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundColor(.fAmber)
                        Text(step)
                            .font(.subheadline)
                            .foregroundColor(.fText)
                    }
                }
            }
            .padding()
            .background(Color.fSlateLight)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1)))
        }
    }

    // MARK: - Commit History

    private var commitHistorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Commit History")

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.fSlateLighter)
                    .frame(width: 2)
                    .padding(.leading, 11)

                VStack(spacing: 16) {
                    ForEach(recipe.commits) { commit in
                        commitRow(commit)
                    }
                }
            }
        }
    }

    private func commitRow(_ commit: RecipeCommit) -> some View {
        HStack(alignment: .top, spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.fSlate)
                    .frame(width: 24, height: 24)
                    .overlay(Circle().stroke(Color.fAmber, lineWidth: 2))
                Circle()
                    .fill(Color.fAmber)
                    .frame(width: 8, height: 8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        expandedCommit = expandedCommit == commit.id ? nil : commit.id
                    }
                } label: {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(commit.message)
                                .font(.subheadline)
                                .foregroundColor(.fText)
                                .multilineTextAlignment(.leading)
                            Text(commit.date)
                                .font(.caption.monospaced())
                                .foregroundColor(.fMuted)
                        }
                        Spacer()
                        Image(systemName: expandedCommit == commit.id ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.fMuted)
                    }
                }

                if expandedCommit == commit.id {
                    VStack(alignment: .leading, spacing: 8) {
                        Divider().background(Color.white.opacity(0.1))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Changes:").font(.caption).foregroundColor(.fMuted)
                            Text(commit.changes).font(.subheadline).foregroundColor(.fGreen)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Result:").font(.caption).foregroundColor(.fMuted)
                            Text(commit.result).font(.subheadline).foregroundColor(.fText)
                        }
                    }
                    .padding(.top, 4)
                    .transition(.opacity)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.fSlateLight)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1)))
        }
    }

    // MARK: - Branches

    private var branchesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Active Branches")

            ForEach(recipe.branches) { branch in
                NavigationLink(destination: MergeReviewView(recipe: recipe, branch: branch)) {
                    branchCard(branch)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func branchCard(_ branch: Branch) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: branch.authorAvatar)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Circle().fill(Color.fSlateLighter)
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.fAmber.opacity(0.2), lineWidth: 2))

                VStack(alignment: .leading) {
                    Text(branch.name)
                        .font(.subheadline).fontWeight(.medium)
                        .foregroundColor(.fText)
                    Text("by \(branch.authorName) \u{2022} \(branch.createdAt)")
                        .font(.caption).foregroundColor(.fMuted)
                }
            }
            Text("\"\(branch.message)\"")
                .font(.subheadline).foregroundColor(.fMuted).italic()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.fSlateLight)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1)))
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption).fontWeight(.medium)
            .foregroundColor(.fMuted).tracking(1)
    }
}
