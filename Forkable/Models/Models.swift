import Foundation

struct Ingredient: Identifiable {
    let id = UUID()
    var name: String
    var amount: Double
    var unit: String
    var percentage: Double?
}

struct RecipeCommit: Identifiable {
    let id: String
    let date: String
    let message: String
    let changes: String
    let result: String
}

struct Branch: Identifiable {
    let id: String
    let name: String
    let authorName: String
    let authorAvatar: String
    let message: String
    let createdAt: String
    var ingredients: [Ingredient]
    var tastingNotes: String?
}

struct Recipe: Identifiable {
    let id: String
    let name: String
    let image: String
    let activeForks: Int
    let lastUpdated: String
    let totalTime: String
    var ingredients: [Ingredient]
    let commits: [RecipeCommit]
    var branches: [Branch]
    var instructions: [String]
}

struct Activity: Identifiable {
    let id: String
    let type: ActivityType
    let authorName: String
    let authorAvatar: String
    let recipeName: String
    let timestamp: String

    enum ActivityType {
        case fork
        case pullRequest
    }
}
