import SwiftUI

struct PlayerScorePanel: View {
    let isPlayer: Bool
    let score: Int
    let isTurn: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(isPlayer ? "YOU" : "AI")
                .font(.system(size: 12, weight: .light))
                .foregroundColor(DesignSystem.colors.textSecondary)
                .tracking(0.8)

            ZStack {
                Circle()
                    .stroke(
                        isPlayer ? DesignSystem.colors.accentBlue : DesignSystem.colors.accentPurple,
                        lineWidth: 3
                    )
                    .frame(width: 60, height: 60)
                    .shadow(
                        color: isPlayer
                            ? DesignSystem.colors.accentBlue.opacity(0.6)
                            : DesignSystem.colors.accentPurple.opacity(0.6),
                        radius: 8
                    )

                if isPlayer {
                    Text("X")
                        .font(.system(size: 28, weight: .thin))
                        .foregroundColor(DesignSystem.colors.accentBlue)
                } else {
                    Circle()
                        .stroke(DesignSystem.colors.accentPurple, lineWidth: 2.5)
                        .frame(width: 26, height: 26)
                }
            }

            Text("\(score)")
                .font(.system(size: 32, weight: .thin))
                .foregroundColor(DesignSystem.colors.textPrimary)

            if isTurn {
                Text("●")
                    .font(.system(size: 8))
                    .foregroundColor(DesignSystem.colors.accentBlue)
                    .tracking(0.5)
            }
        }
    }
}

#Preview {
    HStack(spacing: DesignSystem.spacing.xl) {
        PlayerScorePanel(isPlayer: true, score: 7, isTurn: true)
        Spacer()
        PlayerScorePanel(isPlayer: false, score: 7, isTurn: false)
    }
    .padding(DesignSystem.spacing.lg)
    .background(DesignSystem.colors.darkBg)
    .ignoresSafeArea()
}
