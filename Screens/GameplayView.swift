import SwiftUI

struct GameplayView: View {
    @Binding var navigationPath: [NavigationDestination]
    let mode: GameMode
    @StateObject private var vm: GameViewModel

    init(
        navigationPath: Binding<[NavigationDestination]>,
        mode: GameMode,
        viewModel: GameViewModel? = nil
    ) {
        _navigationPath = navigationPath
        self.mode = mode
        _vm = StateObject(wrappedValue: viewModel ?? GameViewModel(mode: mode))
    }

    var body: some View {
        ZStack {
            FuturisticBackground()

            VStack(spacing: 0) {
                HStack {
                    IconButton(
                        iconName: "chevron.left",
                        action: { navigationPath.removeLast() }
                    )

                    Spacer()

                    VStack(spacing: 4) {
                        Text(vm.turnLabel)
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(DesignSystem.colors.textSecondary)
                            .tracking(0.5)

                        Text("●")
                            .font(.system(size: 8))
                            .foregroundColor(DesignSystem.colors.accentBlue)
                    }

                    Spacer()

                    IconButton(
                        iconName: "ellipsis",
                        action: {}
                    )
                }
                .padding(DesignSystem.spacing.lg)

                HStack(spacing: DesignSystem.spacing.xl) {
                    PlayerScorePanel(isPlayer: true, score: vm.playerScore, isTurn: vm.currentPlayer == .x)
                    Spacer()
                    PlayerScorePanel(isPlayer: false, score: vm.opponentScore, isTurn: vm.currentPlayer == .o)
                }
                .padding(.horizontal, DesignSystem.spacing.lg)
                .padding(.vertical, DesignSystem.spacing.md)

                Spacer()

                GameBoard(marks: vm.board, selectedIndex: nil) { index in
                    vm.placeMark(at: index)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(DesignSystem.colors.accentBlue)

                        Text("ENERGY")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(DesignSystem.colors.textSecondary)
                            .tracking(0.5)

                        Spacer()
                    }

                    EnergyBar(current: vm.energy, max: 10)

                    HStack(spacing: 12) {
                        GradientButton(label: "Skill", action: {
                            guard !vm.isAITurn else { return }
                            navigationPath.append(.skillSelection)
                        })
                        .frame(height: 44)
                    }
                }
                .padding(DesignSystem.spacing.lg)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            if vm.isGameOver {
                vm.resetGame()
            }
        }
        .onChange(of: vm.isGameOver) { _, isGameOver in
            guard isGameOver else { return }
            navigateToResultIfNeeded()
        }
    }

    private func navigateToResultIfNeeded() {
        let result = NavigationDestination.result(
            won: vm.resultWon,
            score: vm.resultScore,
            bonus: vm.totalBonus
        )

        if navigationPath.last != result {
            navigationPath.append(result)
        }
    }
}

#Preview {
    GameplayView(navigationPath: .constant([]), mode: .vsAI)
}
