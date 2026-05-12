import SwiftUI

struct TitleView: View {
    @Binding var navigationPath: [NavigationDestination]

    var body: some View {
        ZStack {
            FuturisticBackground()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    IconButton(
                        iconName: "gearshape.fill",
                        action: {}
                    )
                    .padding(.trailing, DesignSystem.spacing.lg)
                    .padding(.top, DesignSystem.spacing.lg)
                }

                Spacer()
                    .frame(minHeight: 80)

                VStack(spacing: DesignSystem.spacing.md) {
                    Text("NEXUS")
                        .font(DesignSystem.typography.titleFont)
                        .tracking(2.5)
                        .foregroundColor(DesignSystem.colors.textPrimary)
                        .shadow(color: DesignSystem.colors.accentBlue.opacity(0.6), radius: 20)

                    Text("A new 4x5 strategy game")
                        .font(DesignSystem.typography.subtitleFont)
                        .tracking(0.8)
                        .foregroundColor(DesignSystem.colors.textSecondary)
                }
                .padding(.bottom, DesignSystem.spacing.xxl + 20)

                Spacer()

                VStack(spacing: DesignSystem.spacing.lg) {
                    GradientButton(
                        label: "Play",
                        action: { navigationPath.append(.modeSelection) }
                    )

                    GlassButton(
                        label: "How to Play",
                        action: { navigationPath.append(.howToPlay) }
                    )
                }
                .padding(.horizontal, DesignSystem.spacing.lg)
                .padding(.bottom, DesignSystem.spacing.xxl + 10)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    TitleView(navigationPath: .constant([]))
}
