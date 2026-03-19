import SwiftUI

enum AppTab {
    case home, forks
}

struct ContentView: View {
    @Environment(RecipeStore.self) private var store
    @Environment(ToastManager.self) private var toastManager
    @State private var selectedTab: AppTab = .home
    @State private var showNewRecipe = false
    @State private var showProfile = false
    @State private var showSettings = false

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

            tabBar
        }
        .ignoresSafeArea(.keyboard)
        .toastOverlay(toastManager.currentToast)
        .sheet(isPresented: $showNewRecipe) { NewRecipeSheet() }
        .sheet(isPresented: $showProfile) { ProfileSheet() }
        .sheet(isPresented: $showSettings) { SettingsSheet() }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 0.5)

            HStack(alignment: .top, spacing: 0) {
                tabButton(icon: "house.fill", label: "Home", tab: .home)
                tabButton(icon: "arrow.triangle.branch", label: "Forks", tab: .forks)

                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showNewRecipe = true
                } label: {
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

    // MARK: - Tab Bar Buttons

    private func tabButton(icon: String, label: String, tab: AppTab) -> some View {
        Button {
            withAnimation(.spring(duration: 0.3)) {
                selectedTab = tab
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                    .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
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
}
