import SwiftUI

struct ContentView: View {
    @State private var navigationPath: [NavigationDestination] = []
    @State private var showSplash = true
    @StateObject private var gameSession = GameSessionStore()
    @ObservedObject private var adManager = AdManager.shared

    var body: some View {
        ZStack {
            NavigationStack(path: $navigationPath) {
                TitleView(navigationPath: $navigationPath)
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .background(DesignSystem.colors.darkBg.ignoresSafeArea())
            .fullScreenCover(isPresented: $adManager.shouldShowAd) {
                AdInterstitialView()
            }

            if showSplash {
                SplashView(onFinish: {
                    showSplash = false
                })
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showSplash)
    }

    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .modeSelection:
            ModeSelectionView(navigationPath: $navigationPath)
        case .howToPlay:
            HowToPlayView(navigationPath: $navigationPath)
        case .gameplay(let mode):
            let vm = gameSession.viewModel(for: mode)
            GameplayView(navigationPath: $navigationPath, mode: mode, viewModel: vm)
                .environmentObject(vm)
        case .skillSelection:
            let vm = gameSession.activeViewModel
            SkillSelectionView(navigationPath: $navigationPath)
                .environmentObject(vm)
        case .skillTargetSelection(let skill):
            let vm = gameSession.activeViewModel
            SkillTargetSelectionView(navigationPath: $navigationPath, skillName: skill)
                .environmentObject(vm)
        case .result(let won, let score, let bonus):
            ResultView(navigationPath: $navigationPath, won: won, score: score, bonus: bonus)
        case .stats:
            StatsView(navigationPath: $navigationPath)
        case .settings:
            SettingsView(navigationPath: $navigationPath)
        }
    }
}

#Preview {
    ContentView()
}
