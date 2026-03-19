import SwiftUI

@main
struct ForkableApp: App {
    @State private var store = RecipeStore()
    @State private var toastManager = ToastManager()
    @State private var showLaunch = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environment(store)
                    .environment(toastManager)

                if showLaunch {
                    launchScreen
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        showLaunch = false
                    }
                }
            }
        }
    }

    private var launchScreen: some View {
        ZStack {
            Color.fSlate.ignoresSafeArea()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.fAmber.opacity(0.15))
                        .frame(width: 120, height: 120)

                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(.fAmber)
                }

                Text("Forkable")
                    .font(.system(.largeTitle, design: .monospaced).weight(.bold))
                    .foregroundColor(.fText)

                Text("version control for recipes")
                    .font(.subheadline)
                    .foregroundColor(.fMuted)
            }
        }
    }
}
