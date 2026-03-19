import SwiftUI

struct DashboardView: View {
    @Environment(RecipeStore.self) private var store
    @Environment(ToastManager.self) private var toastManager
    @State private var searchText = ""
    @State private var recipeToDelete: Recipe?

    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty { return store.recipes }
        return store.recipes.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if store.recipes.isEmpty {
                emptyState
            } else {
                recipeList
            }
        }
        .background(Color.fSlate)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.branch")
                        .foregroundColor(.fAmber)
                    Text("Forkable")
                        .font(.headline)
                        .foregroundColor(.fText)
                }
            }
        }
        .toolbarBackground(Color.fSlate, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search recipes...")
        .confirmationDialog(
            "Delete Recipe",
            isPresented: .init(
                get: { recipeToDelete != nil },
                set: { if !$0 { recipeToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let recipe = recipeToDelete {
                    withAnimation {
                        store.deleteRecipe(id: recipe.id)
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                    toastManager.show("Recipe deleted", type: .error)
                    recipeToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                recipeToDelete = nil
            }
        } message: {
            if let recipe = recipeToDelete {
                Text("Are you sure you want to delete \"\(recipe.name)\"? This cannot be undone.")
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.fSlateLighter.opacity(0.5))
                    .frame(width: 100, height: 100)
                Image(systemName: "book.closed")
                    .font(.system(size: 40))
                    .foregroundColor(.fSlateLighter)
            }

            Text("No recipes yet")
                .font(.title3.weight(.medium))
                .foregroundColor(.fText)

            Text("Tap the + button to initialize\nyour first recipe repository")
                .font(.subheadline)
                .foregroundColor(.fMuted)
                .multilineTextAlignment(.center)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Recipe List

    private var recipeList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if !store.activities.isEmpty {
                    activityFeed
                }

                repositoriesSection
            }
            .padding()
            .padding(.bottom, 90)
        }
    }

    // MARK: - Activity Feed

    private var activityFeed: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Recent Activity")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.activities.prefix(10)) { activity in
                        activityCard(activity)
                    }
                }
            }
        }
    }

    private func activityCard(_ activity: Activity) -> some View {
        HStack(spacing: 12) {
            initialsAvatar(name: activity.authorName, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(activity.authorName).fontWeight(.medium)
                    Text(activity.type == .fork ? "forked" : "merged")
                }
                .font(.subheadline)
                .foregroundColor(.fText)

                Text(activity.recipeName)
                    .font(.subheadline)
                    .foregroundColor(.fAmber)
                    .lineLimit(1)

                Text(activity.timestamp)
                    .font(.caption2)
                    .foregroundColor(.fMuted)
            }
        }
        .padding(12)
        .background(Color.fSlateLight)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1)))
        .frame(minWidth: 240)
    }

    // MARK: - Repositories

    private var repositoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Your Repositories")

            if filteredRecipes.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundColor(.fSlateLighter)
                    Text("No recipes match \"\(searchText)\"")
                        .font(.subheadline)
                        .foregroundColor(.fMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else {
                ForEach(filteredRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                        recipeCard(recipe)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .contextMenu {
                        Button(role: .destructive) {
                            recipeToDelete = recipe
                        } label: {
                            Label("Delete Recipe", systemImage: "trash")
                        }

                        ShareLink(item: recipe.shareText) {
                            Label("Share Recipe", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Recipe Card

    private func recipeCard(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottom) {
                if recipe.image.isEmpty {
                    Rectangle().fill(Color.fSlateLighter)
                        .overlay(
                            Image(systemName: "book.closed")
                                .font(.system(size: 40))
                                .foregroundColor(.fSlateLighter.opacity(0.5))
                        )
                } else {
                    AsyncImage(url: URL(string: recipe.image)) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle().fill(Color.fSlateLighter)
                    }
                }

                LinearGradient(
                    colors: [Color.fSlateLight, .clear],
                    startPoint: .bottom, endPoint: .top
                )
                .frame(height: 80)
            }
            .frame(height: 160)
            .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.fText)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.branch").font(.caption2)
                        Text("\(recipe.activeForks) active fork\(recipe.activeForks == 1 ? "" : "s")").font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.fGreen.opacity(0.2))
                    .foregroundColor(.fGreen)
                    .cornerRadius(6)

                    HStack(spacing: 4) {
                        Image(systemName: "clock").font(.caption2)
                        Text(recipe.totalTime).font(.caption)
                    }
                    .foregroundColor(.fMuted)
                }

                Text("Last commit \(recipe.lastUpdated)")
                    .font(.caption.monospaced())
                    .foregroundColor(.fMuted)
            }
            .padding()
        }
        .background(Color.fSlateLight)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1)))
    }
}
