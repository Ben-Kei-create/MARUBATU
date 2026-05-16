import SwiftUI

struct ResultView: View {
    @Binding var navigationPath: [NavigationDestination]
    let won: Bool
    let score: Int
    let bonus: Int

    var body: some View {
        ZStack {
            FuturisticBackground()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    won
                                        ? DesignSystem.colors.accentBlue.opacity(0.2)
                                        : DesignSystem.colors.accentPurple.opacity(0.15),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)

                    VStack(spacing: DesignSystem.spacing.lg) {
                        Text(won ? L.youWin : L.youLose)
                            .font(.app(size: 48, weight: .thin))
                            .tracking(2.0)
                            .foregroundColor(
                                won
                                    ? DesignSystem.colors.accentBlue
                                    : DesignSystem.colors.accentPurple
                            )
                            .shadow(
                                color: won
                                    ? DesignSystem.colors.accentBlue.opacity(0.6)
                                    : DesignSystem.colors.accentPurple.opacity(0.6),
                                radius: 20
                            )

                        VStack(spacing: 6) {
                            Text("スコア \(score)")
                                .font(.app(size: 20, weight: .light))
                                .foregroundColor(DesignSystem.colors.textPrimary)

                            Text("+\(bonus)")
                                .font(.app(size: 16, weight: .light))
                                .foregroundColor(DesignSystem.colors.accentBlue)
                        }
                    }
                }

                Spacer()

                VStack(spacing: DesignSystem.spacing.lg) {
                    GradientButton(
                        label: L.playAgain,
                        action: {
                            navigationPath.removeLast()
                        }
                    )

                    GlassButton(
                        label: L.backToModeSelect,
                        action: {
                            navigationPath.removeLast()
                            navigationPath.removeLast()
                        }
                    )
                }
                .padding(DesignSystem.spacing.lg)
            }
        }
    }
}

#Preview {
    VStack {
        ResultView(navigationPath: .constant([]), won: true, score: 24, bonus: 14)
    }
}
