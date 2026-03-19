import SwiftUI

struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Activity Feed
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader("Recent Activity")

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(mockActivities) { activity in
                                activityCard(activity)
                            }
                        }
                    }
                }

                // Repositories
                VStack(alignment: .leading, spacing: 16) {
                    sectionHeader("Your Repositories")

                    ForEach(mockRecipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            recipeCard(recipe)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
            .padding(.bottom, 90)
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
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.fMuted)
            .tracking(1)
    }

    // MARK: - Activity Card

    private func activityCard(_ activity: Activity) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: activity.authorAvatar)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Circle().fill(Color.fSlateLighter)
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.fAmber.opacity(0.2), lineWidth: 2))

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(activity.authorName).fontWeight(.medium)
                    Text(activity.type == .fork ? "forked" : "opened PR on")
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

    // MARK: - Recipe Card

    private func recipeCard(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: recipe.image)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color.fSlateLighter)
                }
                .frame(height: 160)
                .clipped()

                LinearGradient(
                    colors: [Color.fSlateLight, .clear],
                    startPoint: .bottom, endPoint: .top
                )
                .frame(height: 80)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.fText)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.branch").font(.caption2)
                        Text("\(recipe.activeForks) active forks").font(.caption)
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
