import SwiftUI

struct RecipeDetailView: View {
    let recipeId: String
    @Environment(RecipeStore.self) private var store
    @Environment(ToastManager.self) private var toastManager
    @Environment(\.dismiss) private var dismiss
    @State private var expandedCommit: String?
    @State private var showForkSheet = false
    @State private var showEditSheet = false
    @State private var showDeleteConfirm = false

    private var recipe: Recipe? {
        store.recipe(for: recipeId)
    }

    var body: some View {
        Group {
            if let recipe {
                recipeContent(recipe)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "xmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(.fMuted)
                    Text("Recipe not found")
                        .foregroundColor(.fMuted)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.fSlate)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.fSlate, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Content

    private func recipeContent(_ recipe: Recipe) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                recipeImage(recipe)
                badgesAndActions(recipe)
                ingredientsSection(recipe)

                if !recipe.instructions.isEmpty {
                    instructionsSection(recipe)
                }

                commitHistorySection(recipe)

                if !recipe.branches.isEmpty {
                    branchesSection(recipe)
                }
            }
            .padding()
            .padding(.bottom, 90)
        }
        .background(Color.fSlate)
        .navigationTitle(recipe.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                recipeMenu(recipe)
            }
        }
        .sheet(isPresented: $showForkSheet) {
            ForkTweakSheet(recipeId: recipeId)
        }
        .sheet(isPresented: $showEditSheet) {
            EditRecipeSheet(recipeId: recipeId)
        }
        .confirmationDialog("Delete Recipe", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                store.deleteRecipe(id: recipeId)
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                toastManager.show("Recipe deleted", type: .error)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(recipe.name)\"? This cannot be undone.")
        }
    }

    // MARK: - Image

    private func recipeImage(_ recipe: Recipe) -> some View {
        Group {
            if recipe.image.isEmpty {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.fSlateLighter)
                    .frame(height: 220)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 36))
                                .foregroundColor(.fMuted)
                            Text("No image yet")
                                .font(.caption)
                                .foregroundColor(.fMuted)
                        }
                    )
            } else {
                AsyncImage(url: URL(string: recipe.image)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color.fSlateLighter)
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    // MARK: - Badges & Actions

    private func badgesAndActions(_ recipe: Recipe) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.branch").font(.caption2)
                    Text("\(recipe.activeForks) fork\(recipe.activeForks == 1 ? "" : "s")").font(.caption)
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

            HStack(spacing: 12) {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showForkSheet = true
                } label: {
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

                ShareLink(item: recipe.shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundColor(.fText)
                        .frame(width: 50, height: 48)
                        .background(Color.fSlateLight)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.15)))
                }
            }
        }
    }

    // MARK: - Menu

    private func recipeMenu(_ recipe: Recipe) -> some View {
        Menu {
            Button { showEditSheet = true } label: {
                Label("Edit Recipe", systemImage: "pencil")
            }

            Button {
                UIPasteboard.general.string = recipe.ingredientListText
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                toastManager.show("Ingredients copied!")
            } label: {
                Label("Copy Ingredients", systemImage: "doc.on.doc")
            }

            Divider()

            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("Delete Recipe", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundColor(.fMuted)
        }
    }

    // MARK: - Ingredients

    private func ingredientsSection(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Ingredients (Variables)")

            if recipe.ingredients.isEmpty {
                emptySection(
                    icon: "list.bullet",
                    message: "No ingredients yet",
                    hint: "Tap edit to add ingredients"
                )
            } else {
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
    }

    // MARK: - Instructions

    private func instructionsSection(_ recipe: Recipe) -> some View {
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

    private func commitHistorySection(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Commit History")

            if recipe.commits.isEmpty {
                emptySection(
                    icon: "clock.arrow.circlepath",
                    message: "No commits yet",
                    hint: "Fork and tweak to create history"
                )
            } else {
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
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
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

    private func branchesSection(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Active Branches")

            ForEach(recipe.branches) { branch in
                NavigationLink(destination: MergeReviewView(recipeId: recipeId, branchId: branch.id)) {
                    branchCard(branch)
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }

    private func branchCard(_ branch: Branch) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                initialsAvatar(name: branch.authorName, size: 32)

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

    // MARK: - Empty Section

    private func emptySection(icon: String, message: String, hint: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.fSlateLighter)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.fMuted)
            Text(hint)
                .font(.caption)
                .foregroundColor(.fMuted.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.fSlateLight)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1)))
    }
}
