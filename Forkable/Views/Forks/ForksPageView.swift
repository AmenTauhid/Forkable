import SwiftUI

private struct ForkWithRecipe: Identifiable {
    var id: String { fork.id }
    let fork: Branch
    let recipeId: String
    let recipeName: String
    let recipeImage: String
}

struct ForksPageView: View {
    @Environment(RecipeStore.self) private var store
    @State private var searchQuery = ""
    @State private var selectedFilter = "All"
    private let filters = ["All", "Mine", "Community"]

    private var allForks: [ForkWithRecipe] {
        var forks: [ForkWithRecipe] = []
        for recipe in store.recipes {
            for branch in recipe.branches {
                forks.append(ForkWithRecipe(
                    fork: branch, recipeId: recipe.id,
                    recipeName: recipe.name, recipeImage: recipe.image))
            }
        }
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
                        Button {
                            withAnimation(.spring(duration: 0.3)) {
                                selectedFilter = filter
                            }
                        } label: {
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
                    if allForks.isEmpty {
                        emptyForksState
                    } else if groupedForks.isEmpty {
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
                Text("\(allForks.count)")
                    .font(.caption2.weight(.semibold).monospaced())
                    .foregroundColor(.fGreen)
                    .frame(width: 24, height: 24)
                    .background(Color.fGreen.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.fSlate, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Empty State

    private var emptyForksState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 40)

            ZStack {
                Circle()
                    .fill(Color.fSlateLighter.opacity(0.5))
                    .frame(width: 100, height: 100)
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 40))
                    .foregroundColor(.fSlateLighter)
            }

            Text("No forks yet")
                .font(.title3.weight(.medium))
                .foregroundColor(.fText)

            Text("Open a recipe and tap \"Fork & Tweak\"\nto create your first experiment")
                .font(.subheadline)
                .foregroundColor(.fMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Fork Group

    private func forkGroupSection(_ group: (recipeId: String, forks: [ForkWithRecipe])) -> some View {
        let recipe = store.recipe(for: group.recipeId)

        return VStack(alignment: .leading, spacing: 12) {
            // Recipe header
            if let recipe {
                NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                    HStack(spacing: 12) {
                        if group.forks[0].recipeImage.isEmpty {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.fSlateLighter)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "book.closed")
                                        .font(.caption)
                                        .foregroundColor(.fMuted)
                                )
                        } else {
                            AsyncImage(url: URL(string: group.forks[0].recipeImage)) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle().fill(Color.fSlateLighter)
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

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
                        NavigationLink(destination: MergeReviewView(recipeId: recipe.id, branchId: forkItem.fork.id)) {
                            forkCard(forkItem, recipe: recipe)
                        }
                        .buttonStyle(PressableButtonStyle())
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
                initialsAvatar(name: fork.authorName, size: 32)

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
