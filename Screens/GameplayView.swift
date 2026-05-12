import SwiftUI

struct GameplayView: View {
    @Binding var navigationPath: [NavigationDestination]
    let mode: GameMode
    @State private var boardMarks: [[CellMark]] = Array(repeating: Array(repeating: CellMark.empty, count: 4), count: 5)
    @State private var playerScore = 7
    @State private var aiScore = 7
    @State private var currentEnergy = 6
    @State private var maxEnergy = 10

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
                        Text("YOUR TURN")
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
                    PlayerScorePanel(isPlayer: true, score: playerScore, isTurn: true)
                    Spacer()
                    PlayerScorePanel(isPlayer: false, score: aiScore, isTurn: false)
                }
                .padding(.horizontal, DesignSystem.spacing.lg)
                .padding(.vertical, DesignSystem.spacing.md)

                Spacer()

                GameBoard(marks: boardMarks, selectedIndex: nil) { _ in }

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

                    EnergyBar(current: currentEnergy, max: maxEnergy)

                    HStack(spacing: 12) {
                        GradientButton(label: "Skill", action: {
                            navigationPath.append(.skillSelection)
                        })
                        .frame(height: 44)
                    }
                }
                .padding(DesignSystem.spacing.lg)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    GameplayView(navigationPath: .constant([]), mode: .vsAI)
}
