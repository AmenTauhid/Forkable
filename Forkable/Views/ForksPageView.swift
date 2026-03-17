import SwiftUI

private struct ForkWithRecipe: Identifiable {
    var id: String { fork.id }
    let fork: Branch
    let recipeId: String
    let recipeName: String
    let recipeImage: String
}

struct ForksPageView: View {
    @State private var searchQuery = ""
    @State private var selectedFilter = "All"
    private let filters = ["All", "Mine", "Community"]

    private var allForks: [ForkWithRecipe] {
        var forks: [ForkWithRecipe] = []
        for recipe in mockRecipes {
            for branch in recipe.branches {
                forks.append(ForkWithRecipe(
                    fork: branch, recipeId: recipe.id,
                    recipeName: recipe.name, recipeImage: recipe.image))
            }
        }
        // Extra community fork
        forks.append(ForkWithRecipe(
            fork: Branch(
                id: "branch-extra-1", name: "Rosemary & Sea Salt",
                authorName: "Arham",
                authorAvatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Arham",
                message: "Adding rosemary and flaky sea salt topping for extra savory punch",
                createdAt: "3 hours ago",
                ingredients: [
                    Ingredient(name: "All-Purpose Flour", amount: 500, unit: "g", percentage: 100),
                    Ingredient(name: "Water", amount: 350, unit: "g", percentage: 70),
                    Ingredient(name: "Olive Oil", amount: 60, unit: "g", percentage: 12),
                    Ingredient(name: "Yeast", amount: 7, unit: "g", percentage: 1.4),
                    Ingredient(name: "Salt", amount: 10, unit: "g", percentage: 2),
                    Ingredient(name: "Fresh Rosemary", amount: 15, unit: "g", percentage: 3),
                ],
                tastingNotes: "The rosemary adds a wonderful fragrance during baking."),
            recipeId: "classic-focaccia",
            recipeName: "Classic_Focaccia",
            recipeImage: "https://images.unsplash.com/photo-1612267191168-0024fd1b85be?w=800"))
        return forks
    }

    private var filteredForks: [ForkWithRecipe] {
        allForks.filter { item in
            let matchesSearch = searchQuery.isEmpty ||
                item.fork.name.localizedCaseInsensitiveContains(searchQuery) ||
                item.recipeName.localizedCaseInsensitiveContains(searchQuery) ||
                item.fork.authorName.localizedCaseInsensitiveContains(searchQuery)
            switch selectedFilter {
            case "Mine": return matchesSearch && item.fork.authorName == "You"
            case "Community": return matchesSearch && item.fork.authorName != "You"
            default: return matchesSearch
            }
        }
    }

    private var groupedForks: [(recipeId: String, forks: [ForkWithRecipe])] {
        Dictionary(grouping: filteredForks, by: \.recipeId)
            .map { (recipeId: $0.key, forks: $0.value) }
            .sorted { $0.recipeId < $1.recipeId }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search & Filter
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.fMuted)
                    TextField("Search forks, recipes, or authors...", text: $searchQuery)
                        .foregroundColor(.fText)
                }
                .padding(10)
                .background(Color.fSlateLight)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.1)))

                HStack(spacing: 8) {
                    ForEach(filters, id: \.self) { filter in
                        Button { selectedFilter = filter } label: {
                            Text(filter)
                                .font(.caption)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(selectedFilter == filter ? Color.fAmber : Color.fSlateLight)
                                .foregroundColor(selectedFilter == filter ? .fSlate : .fMuted)
                                .cornerRadius(20)
                        }
                    }
                    Spacer()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.fSlate)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if groupedForks.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "arrow.triangle.branch")
                                .font(.largeTitle)
                                .foregroundColor(.fSlateLighter)
                            Text("No forks found")
                                .foregroundColor(.fMuted)
                            Text("Try adjusting your search or filter")
                                .font(.caption)
                                .foregroundColor(.fMuted.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        ForEach(groupedForks, id: \.recipeId) { group in
                            forkGroupSection(group)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 90)
            }
        }
        .background(Color.fSlate)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.branch")
                        .foregroundColor(.fGreen)
                    Text("Forks")
                        .font(.headline).foregroundColor(.fText)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(allForks.count) total")
                    .font(.caption)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.fGreen.opacity(0.2))
                    .foregroundColor(.fGreen)
                    .cornerRadius(6)
            }
        }
        .toolbarBackground(Color.fSlate, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Fork Group

    private func forkGroupSection(_ group: (recipeId: String, forks: [ForkWithRecipe])) -> some View {
        let recipe = mockRecipes.first { $0.id == group.recipeId }

        return VStack(alignment: .leading, spacing: 12) {
            // Recipe header
            if let recipe {
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: group.forks[0].recipeImage)) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle().fill(Color.fSlateLighter)
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading) {
                            Text(group.forks[0].recipeName)
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.fText)
                            Text("\(group.forks.count) fork\(group.forks.count != 1 ? "s" : "")")
                                .font(.caption).foregroundColor(.fMuted)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption).foregroundColor(.fMuted)
                    }
                }
                .buttonStyle(.plain)
            }

            // Fork cards
            VStack(spacing: 12) {
                ForEach(group.forks) { forkItem in
                    if let recipe {
                        NavigationLink(destination: MergeReviewView(recipe: recipe, branch: forkItem.fork)) {
                            forkCard(forkItem, recipe: recipe)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.leading, 20)
            .overlay(
                Rectangle()
                    .fill(Color.fSlateLighter)
                    .frame(width: 2),
                alignment: .leading
            )
        }
    }

    // MARK: - Fork Card

    private func forkCard(_ item: ForkWithRecipe, recipe: Recipe) -> some View {
        let fork = item.fork
        let newCount = fork.ingredients.filter { ing in
            !recipe.ingredients.contains { $0.name == ing.name }
        }.count
        let changedCount = fork.ingredients.filter { ing in
            recipe.ingredients.first { $0.name == ing.name }.map { $0.amount != ing.amount } ?? false
        }.count

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: fork.authorAvatar)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Circle().fill(Color.fSlateLighter)
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.fAmber.opacity(0.2), lineWidth: 2))

                VStack(alignment: .leading) {
                    Text(fork.name)
                        .font(.subheadline).foregroundColor(.fText).lineLimit(1)
                    Text("by \(fork.authorName) \u{2022} \(fork.createdAt)")
                        .font(.caption).foregroundColor(.fMuted)
                }
                Spacer()
                Image(systemName: "arrow.triangle.merge")
                    .font(.caption).foregroundColor(.fGreen)
            }

            Text("\"\(fork.message)\"")
                .font(.subheadline).foregroundColor(.fMuted).italic().lineLimit(2)

            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Text("+\(newCount)").foregroundColor(.fGreen)
                    Text("new").foregroundColor(.fMuted)
                }
                HStack(spacing: 4) {
                    Text("~\(changedCount)").foregroundColor(.fAmber)
                    Text("changed").foregroundColor(.fMuted)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "clock").foregroundColor(.fMuted)
                    Text(fork.createdAt).foregroundColor(.fMuted)
                }
            }
            .font(.caption)

            if let notes = fork.tastingNotes {
                Divider().background(Color.white.opacity(0.05))
                HStack(spacing: 0) {
                    Text("Tasting notes: ").foregroundColor(.fAmber)
                    Text(notes).foregroundColor(.fMuted)
                }
                .font(.caption).lineLimit(2)
            }
        }
        .padding()
        .background(Color.fSlateLight)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1)))
    }
}
