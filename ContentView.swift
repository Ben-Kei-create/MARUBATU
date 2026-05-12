import SwiftUI

struct ContentView: View {
    @State private var navigationPath: [NavigationDestination] = []
    @ObservedObject private var adManager = AdManager.shared

    var body: some View {
        NavigationStack(path: $navigationPath) {
            TitleView(navigationPath: $navigationPath)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .modeSelection:
                        ModeSelectionView(navigationPath: $navigationPath)
                    case .howToPlay:
                        HowToPlayView(navigationPath: $navigationPath)
                    case .gameplay(let mode):
                        GameplayView(navigationPath: $navigationPath, mode: mode)
                    case .skillSelection:
                        SkillSelectionView(navigationPath: $navigationPath)
                    case .skillTargetSelection(let skill):
                        SkillTargetSelectionView(navigationPath: $navigationPath, skillName: skill)
                    case .result(let won, let score, let bonus):
                        ResultView(navigationPath: $navigationPath, won: won, score: score, bonus: bonus)
                    case .stats:
                        StatsView(navigationPath: $navigationPath)
                    case .settings:
                        SettingsView(navigationPath: $navigationPath)
                    }
                }
        }
        .background(DesignSystem.colors.darkBg.ignoresSafeArea())
        .fullScreenCover(isPresented: $adManager.shouldShowAd) {
            AdInterstitialView()
        }
    }
}

#Preview {
    ContentView()
}
