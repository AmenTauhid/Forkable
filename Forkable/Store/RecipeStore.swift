import Foundation
import Observation

@Observable
class RecipeStore {
    var recipes: [Recipe]
    var activities: [Activity]

    private static var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("forkable_data.json")
    }

    struct StoredData: Codable {
        var recipes: [Recipe]
        var activities: [Activity]
    }

    init() {
        let url = Self.fileURL
        if let data = try? Data(contentsOf: url),
           let saved = try? JSONDecoder().decode(StoredData.self, from: data) {
            self.recipes = saved.recipes
            self.activities = saved.activities
        } else {
            self.recipes = createMockRecipes()
            self.activities = createMockActivities()
        }
    }

    func save() {
        let stored = StoredData(recipes: recipes, activities: activities)
        if let data = try? JSONEncoder().encode(stored) {
            try? data.write(to: Self.fileURL, options: .atomic)
        }
    }

    // MARK: - Recipes

    func addRecipe(_ recipe: Recipe) {
        recipes.insert(recipe, at: 0)
        addActivity(Activity(
            id: UUID().uuidString, type: .fork,
            authorName: "You", authorAvatar: "",
            recipeName: recipe.name, timestamp: "Just now"
        ))
        save()
    }

    func deleteRecipe(id: String) {
        recipes.removeAll { $0.id == id }
        save()
    }

    func updateRecipe(_ recipe: Recipe) {
        if let idx = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[idx] = recipe
            save()
        }
    }

    func recipe(for id: String) -> Recipe? {
        recipes.first { $0.id == id }
    }

    // MARK: - Branches

    func addBranch(to recipeId: String, branch: Branch, commitMessage: String) {
        guard let idx = recipes.firstIndex(where: { $0.id == recipeId }) else { return }

        recipes[idx].branches.append(branch)
        recipes[idx].lastUpdated = "Just now"

        addActivity(Activity(
            id: UUID().uuidString, type: .fork,
            authorName: branch.authorName, authorAvatar: branch.authorAvatar,
            recipeName: recipes[idx].name, timestamp: "Just now"
        ))
        save()
    }

    func mergeBranch(_ branchId: String, into recipeId: String) {
        guard let recipeIdx = recipes.firstIndex(where: { $0.id == recipeId }),
              let branchIdx = recipes[recipeIdx].branches.firstIndex(where: { $0.id == branchId })
        else { return }

        let branch = recipes[recipeIdx].branches[branchIdx]

        // Update master ingredients with branch ingredients
        recipes[recipeIdx].ingredients = branch.ingredients

        // Add a merge commit
        let commit = RecipeCommit(
            id: UUID().uuidString,
            date: "Just now",
            message: "Merged '\(branch.name)' by \(branch.authorName)",
            changes: buildChangeDescription(
                master: recipes[recipeIdx].ingredients,
                fork: branch.ingredients
            ),
            result: branch.tastingNotes ?? "Pending tasting results"
        )
        recipes[recipeIdx].commits.insert(commit, at: 0)
        recipes[recipeIdx].lastUpdated = "Just now"

        // Remove the merged branch
        recipes[recipeIdx].branches.remove(at: branchIdx)

        addActivity(Activity(
            id: UUID().uuidString, type: .pullRequest,
            authorName: "You", authorAvatar: "",
            recipeName: recipes[recipeIdx].name, timestamp: "Just now"
        ))
        save()
    }

    // MARK: - Activities

    func addActivity(_ activity: Activity) {
        activities.insert(activity, at: 0)
        if activities.count > 30 {
            activities = Array(activities.prefix(30))
        }
    }

    // MARK: - Stats

    var totalForks: Int {
        recipes.reduce(0) { $0 + $1.branches.count }
    }

    var totalMerges: Int {
        activities.filter { $0.type == .pullRequest }.count
    }

    // MARK: - Helpers

    private func buildChangeDescription(master: [Ingredient], fork: [Ingredient]) -> String {
        var changes: [String] = []
        for forkIng in fork {
            if let masterIng = master.first(where: { $0.name == forkIng.name }) {
                if masterIng.amount != forkIng.amount {
                    changes.append("\(forkIng.name): \(formatAmt(masterIng.amount))\(masterIng.unit) \u{2192} \(formatAmt(forkIng.amount))\(forkIng.unit)")
                }
            } else {
                changes.append("Added \(forkIng.name): \(formatAmt(forkIng.amount))\(forkIng.unit)")
            }
        }
        for masterIng in master {
            if !fork.contains(where: { $0.name == masterIng.name }) {
                changes.append("Removed \(masterIng.name)")
            }
        }
        return changes.isEmpty ? "No changes" : changes.joined(separator: ", ")
    }

    private func formatAmt(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%g", value)
    }
}
