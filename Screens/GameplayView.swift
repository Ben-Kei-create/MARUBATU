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

                    VStack(spacing: 2) {
                        Text(L.yourTurn)
                            .font(.system(size: 11, weight: .light))
                            .foregroundColor(DesignSystem.colors.textSecondary)
                            .tracking(0.5)

                        Text("●")
                            .font(.system(size: 6))
                            .foregroundColor(DesignSystem.colors.accentBlue)
                    }

                    Spacer()

                    IconButton(
                        iconName: "ellipsis",
                        action: {}
                    )
                }
                .padding(.horizontal, DesignSystem.spacing.lg)
                .padding(.vertical, DesignSystem.spacing.md)

                HStack(spacing: DesignSystem.spacing.md) {
                    PlayerScorePanel(isPlayer: true, score: playerScore, isTurn: true)
                    Spacer()
                    PlayerScorePanel(isPlayer: false, score: aiScore, isTurn: false)
                }
                .padding(.horizontal, DesignSystem.spacing.lg)
                .padding(.bottom, DesignSystem.spacing.md)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DesignSystem.spacing.lg) {
                        GameBoard(marks: boardMarks, selectedIndex: nil) { _ in }
                            .frame(maxHeight: 300)

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 13, weight: .light))
                                    .foregroundColor(DesignSystem.colors.accentBlue)

                                Text(L.energy)
                                    .font(.system(size: 11, weight: .light))
                                    .foregroundColor(DesignSystem.colors.textSecondary)
                                    .tracking(0.5)

                                Spacer()
                            }

                            EnergyBar(current: currentEnergy, max: maxEnergy)

                            GradientButton(label: L.skill, action: {
                                navigationPath.append(.skillSelection)
                            })
                            .frame(height: 42)
                        }
                        .padding(DesignSystem.spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(DesignSystem.colors.glass)
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                        )
                    }
                    .padding(DesignSystem.spacing.lg)
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    GameplayView(navigationPath: .constant([]), mode: .vsAI)
}
