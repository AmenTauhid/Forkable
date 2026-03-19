import Foundation

struct Ingredient: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var amount: Double
    var unit: String
    var percentage: Double?
}

struct RecipeCommit: Identifiable, Codable, Hashable {
    var id: String
    var date: String
    var message: String
    var changes: String
    var result: String
}

struct Branch: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var authorName: String
    var authorAvatar: String
    var message: String
    var createdAt: String
    var ingredients: [Ingredient]
    var tastingNotes: String?
}

struct Recipe: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var image: String
    var lastUpdated: String
    var totalTime: String
    var ingredients: [Ingredient]
    var commits: [RecipeCommit]
    var branches: [Branch]
    var instructions: [String]

    var activeForks: Int { branches.count }

    enum CodingKeys: String, CodingKey {
        case id, name, image, lastUpdated, totalTime
        case ingredients, commits, branches, instructions
    }

    var shareText: String {
        var text = "\(name.replacingOccurrences(of: "_", with: " "))\n"
        text += "Total Time: \(totalTime)\n\n"
        text += "Ingredients:\n"
        for ing in ingredients {
            var line = "- \(ing.name): \(formatAmount(ing.amount))\(ing.unit)"
            if let pct = ing.percentage {
                line += " (\(formatAmount(pct))%)"
            }
            text += line + "\n"
        }
        text += "\nInstructions:\n"
        for (i, step) in instructions.enumerated() {
            text += "\(i + 1). \(step)\n"
        }
        return text
    }

    var ingredientListText: String {
        ingredients.map { ing in
            "\(ing.name): \(formatAmount(ing.amount))\(ing.unit)"
        }.joined(separator: "\n")
    }

    private func formatAmount(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%g", value)
    }
}

struct Activity: Identifiable, Codable, Hashable {
    var id: String
    var type: ActivityType
    var authorName: String
    var authorAvatar: String
    var recipeName: String
    var timestamp: String

    enum ActivityType: String, Codable, Hashable {
        case fork
        case pullRequest
    }
}
