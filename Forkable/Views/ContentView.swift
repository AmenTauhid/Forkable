import SwiftUI

enum AppTab {
    case home, forks
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var showNewRecipe = false
    @State private var showProfile = false
    @State private var showSettings = false
    @State private var newRecipeName = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    NavigationStack {
                        DashboardView()
                    }
                case .forks:
                    NavigationStack {
                        ForksPageView()
                    }
                }
            }

            // Custom Tab Bar
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 0.5)

                HStack(alignment: .top, spacing: 0) {
                    tabButton(icon: "house.fill", label: "Home", tab: .home)
                    tabButton(icon: "arrow.triangle.branch", label: "Forks", tab: .forks)

                    Button { showNewRecipe = true } label: {
                        ZStack {
                            Circle()
                                .fill(Color.fAmber)
                                .frame(width: 56, height: 56)
                                .shadow(color: .fAmber.opacity(0.3), radius: 8, y: 2)
                            Image(systemName: "plus")
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.fSlate)
                        }
                    }
                    .offset(y: -20)
                    .frame(maxWidth: .infinity)

                    sheetButton(icon: "person.fill", label: "Profile") {
                        showProfile = true
                    }

                    sheetButton(icon: "gearshape.fill", label: "Settings") {
                        showSettings = true
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 10)
            }
            .padding(.bottom, 4)
            .background(Color.fSlate.opacity(0.97))
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showNewRecipe) { newRecipeSheet }
        .sheet(isPresented: $showProfile) { profileSheet }
        .sheet(isPresented: $showSettings) { settingsSheet }
    }

    // MARK: - Tab Bar Buttons

    private func tabButton(icon: String, label: String, tab: AppTab) -> some View {
        Button { selectedTab = tab } label: {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.title3)
                Text(label).font(.caption2)
            }
            .foregroundColor(selectedTab == tab ? .fAmber : .fMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private func sheetButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.title3)
                Text(label).font(.caption2)
            }
            .foregroundColor(.fMuted)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - New Recipe Sheet

    private var newRecipeSheet: some View {
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

                TextField("e.g., Cinnamon Rolls", text: $newRecipeName)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color.fSlateLighter)
                    .cornerRadius(8)
                    .foregroundColor(.fText)

                Text("\u{2192} \(newRecipeName.isEmpty ? "Recipe_Name" : newRecipeName.replacingOccurrences(of: " ", with: "_"))")
                    .font(.caption.monospaced())
                    .foregroundColor(.fMuted)
            }

            Button {
                showNewRecipe = false
                newRecipeName = ""
            } label: {
                Text("Initialize Repository")
                    .font(.headline)
                    .foregroundColor(.fSlate)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.fGreen)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .background(Color.fSlateLight.ignoresSafeArea())
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Profile Sheet

    private var profileSheet: some View {
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
                statBox(value: "4", label: "Recipes", color: .fAmber)
                statBox(value: "14", label: "Forks", color: .fGreen)
                statBox(value: "7", label: "Merges", color: .fRed)
            }

            HStack {
                Text("12 days of baking")
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

    // MARK: - Settings Sheet

    private var settingsSheet: some View {
        VStack(spacing: 0) {
            Text("Settings")
                .font(.headline)
                .foregroundColor(.fText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            ForEach([
                ("Default Unit System", "Metric (g)"),
                ("Auto-calculate Baker's %", "Enabled"),
                ("Theme", "Dark"),
                ("Notifications", "On"),
                ("Export Format", "JSON"),
            ], id: \.0) { setting in
                HStack {
                    Text(setting.0)
                        .font(.subheadline)
                        .foregroundColor(.fText)
                    Spacer()
                    Text(setting.1)
                        .font(.subheadline.monospaced())
                        .foregroundColor(.fMuted)
                }
                .padding(.horizontal)
                .padding(.vertical, 14)

                Divider().background(Color.white.opacity(0.05))
                    .padding(.horizontal)
            }

            Text("Forkable v2.0.1")
                .font(.caption.monospaced())
                .foregroundColor(.fMuted)
                .padding(.top, 16)

            Spacer()
        }
        .background(Color.fSlateLight.ignoresSafeArea())
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
