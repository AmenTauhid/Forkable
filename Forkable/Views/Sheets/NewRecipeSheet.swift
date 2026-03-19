import SwiftUI

struct NewRecipeSheet: View {
    @Environment(RecipeStore.self) private var store
    @Environment(ToastManager.self) private var toastManager
    @Environment(\.dismiss) private var dismiss

    @State private var recipeName = ""
    @State private var totalTime = ""

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.fAmber)
                Text("New Recipe Repository")
                    .font(.headline)
                    .foregroundColor(.fText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: 8) {
                Text("Recipe Name")
                    .font(.subheadline)
                    .foregroundColor(.fMuted)

                TextField("e.g., Cinnamon Rolls", text: $recipeName)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color.fSlateLighter)
                    .cornerRadius(8)
                    .foregroundColor(.fText)

                Text("\u{2192} \(recipeName.isEmpty ? "Recipe_Name" : recipeName.replacingOccurrences(of: " ", with: "_"))")
                    .font(.caption.monospaced())
                    .foregroundColor(.fMuted)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Total Time")
                    .font(.subheadline)
                    .foregroundColor(.fMuted)

                TextField("e.g., 2 hours", text: $totalTime)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color.fSlateLighter)
                    .cornerRadius(8)
                    .foregroundColor(.fText)
            }

            Button {
                createRecipe()
            } label: {
                Text("Initialize Repository")
                    .font(.headline)
                    .foregroundColor(.fSlate)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(recipeName.isEmpty ? Color.fSlateLighter : Color.fGreen)
                    .cornerRadius(10)
            }
            .disabled(recipeName.isEmpty)

            Spacer()
        }
        .padding()
        .background(Color.fSlateLight.ignoresSafeArea())
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func createRecipe() {
        let formatted = recipeName.replacingOccurrences(of: " ", with: "_")
        let recipe = Recipe(
            id: UUID().uuidString,
            name: formatted,
            image: "",
            lastUpdated: "Just now",
            totalTime: totalTime.isEmpty ? "TBD" : totalTime,
            ingredients: [],
            commits: [
                RecipeCommit(
                    id: UUID().uuidString,
                    date: "Just now",
                    message: "Initial recipe",
                    changes: "Repository initialized",
                    result: "Ready for ingredients"
                )
            ],
            branches: [],
            instructions: []
        )
        store.addRecipe(recipe)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        toastManager.show("Repository initialized!")
        dismiss()
    }
}
