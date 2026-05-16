import SwiftUI

struct RuleCard: View {
    let icon: String
    let title: String
    let description: String
    var iconColor: Color = DesignSystem.colors.accentBlue

    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .light))
                .foregroundColor(iconColor)
                .frame(width: 40, alignment: .center)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.app(size: 16, weight: .medium))
                    .foregroundColor(DesignSystem.colors.textPrimary)
                    .tracking(0.3)

                Text(description)
                    .font(.app(size: 14, weight: .light))
                    .foregroundColor(DesignSystem.colors.textSecondary)
                    .lineSpacing(1.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(DesignSystem.spacing.md)
    }
}

#Preview {
    VStack(spacing: DesignSystem.spacing.lg) {
        RuleCard(
            icon: "square.grid.4x5.fill",
            title: "4x5 Board",
            description: "Play on a 4-column, 5-row grid. Place X and O to dominate the board.",
            iconColor: DesignSystem.colors.accentBlue
        )

        Divider()
            .foregroundColor(DesignSystem.colors.textSecondary.opacity(0.2))

        RuleCard(
            icon: "bolt.fill",
            title: "Energy",
            description: "Build energy each turn. Use it to activate powerful skills and special abilities.",
            iconColor: Color(red: 1.0, green: 0.6, blue: 0.2)
        )
    }
    .padding(DesignSystem.spacing.lg)
    .background(DesignSystem.colors.darkBg)
    .ignoresSafeArea()
}
