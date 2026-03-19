import SwiftUI

struct ProfileSheet: View {
    @Environment(RecipeStore.self) private var store

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.fSlateLighter)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text("HC")
                            .font(.headline)
                            .foregroundColor(.fAmber)
                    )
                    .overlay(Circle().stroke(Color.fAmber.opacity(0.3), lineWidth: 2))

                VStack(alignment: .leading) {
                    Text("Home Chef")
                        .font(.subheadline)
                        .foregroundColor(.fText)
                    Text("@homechef")
                        .font(.caption.monospaced())
                        .foregroundColor(.fMuted)
                }
                Spacer()
            }

            HStack(spacing: 8) {
                statBox(value: "\(store.recipes.count)", label: "Recipes", color: .fAmber)
                statBox(value: "\(store.totalForks)", label: "Forks", color: .fGreen)
                statBox(value: "\(store.totalMerges)", label: "Merges", color: .fRed)
            }

            HStack {
                Text("\(store.recipes.count + store.totalForks) experiments tracked")
                    .font(.caption)
                    .foregroundColor(.fText)
                Spacer()
            }
            .padding(12)
            .background(Color.fSlateLighter)
            .cornerRadius(8)
        }
        .padding(20)
        .background(Color.fSlateLight.ignoresSafeArea())
        .presentationDetents([.height(260)])
        .presentationDragIndicator(.visible)
    }

    private func statBox(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.body.monospaced())
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.fMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.fSlateLighter)
        .cornerRadius(8)
    }
}
