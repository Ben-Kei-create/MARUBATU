import SwiftUI

struct PlayerScorePanel: View {
    let isPlayer: Bool
    let score: Int
    let isTurn: Bool
    var label: String? = nil

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(label ?? (isPlayer ? "YOU" : "AI"))
                .font(.app(size: 12, weight: .light))
                .foregroundColor(isTurn ? accent.opacity(0.9) : DesignSystem.colors.textSecondary)
                .tracking(1.8)
                .shadow(color: accent.opacity(isTurn ? 0.65 : 0.18), radius: isTurn ? 9 : 3)

            ZStack {
                if isPlayer {
                    NeonScoreX(size: 43, color: accent)
                } else {
                    NeonScoreO(size: 43, color: accent)
                }
            }
            .frame(width: 50, height: 42)

            Text("\(score)")
                .font(.app(size: 32, weight: .ultraLight))
                .foregroundColor(accent.opacity(isTurn ? 1 : 0.86))
                .shadow(color: accent.opacity(isTurn ? 0.78 : 0.36), radius: isTurn ? 12 : 6)

            if isTurn {
                Text("●")
                    .font(.app(size: 8))
                    .foregroundColor(DesignSystem.colors.accentBlue)
                    .tracking(0.5)
            }
        }
    }

    private var accent: Color {
        isPlayer ? DesignSystem.colors.accentBlue : DesignSystem.colors.accentPurple
    }
}

private struct NeonScoreX: View {
    let size: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            scoreBars
                .opacity(0.5)
                .blur(radius: 7)
            scoreBars
                .shadow(color: color.opacity(0.95), radius: 10)
                .shadow(color: .white.opacity(0.35), radius: 3)
        }
    }

    private var scoreBars: some View {
        ZStack {
            Capsule()
                .fill(color)
                .frame(width: size, height: 4)
                .rotationEffect(.degrees(45))
            Capsule()
                .fill(color)
                .frame(width: size, height: 4)
                .rotationEffect(.degrees(-45))
        }
    }
}

private struct NeonScoreO: View {
    let size: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.32), lineWidth: 9)
                .frame(width: size, height: size)
                .blur(radius: 6)
            Circle()
                .stroke(color, lineWidth: 4)
                .frame(width: size, height: size)
                .shadow(color: color.opacity(0.95), radius: 10)
            Circle()
                .stroke(.white.opacity(0.58), lineWidth: 1.2)
                .frame(width: size, height: size)
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
