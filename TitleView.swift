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
                        action: { navigationPath.append(.settings) }
                    )
                    .padding(.trailing, DesignSystem.spacing.lg)
                    .padding(.top, DesignSystem.spacing.lg)
                }

                Spacer()
                    .frame(minHeight: 80)

                VStack(spacing: DesignSystem.spacing.md) {
                    Text(L.appTitle)
                        .font(DesignSystem.typography.titleFont)
                        .tracking(2.5)
                        .foregroundColor(DesignSystem.colors.textPrimary)
                        .shadow(color: DesignSystem.colors.accentBlue.opacity(0.6), radius: 20)

                    Text(L.appSubtitle)
                        .font(DesignSystem.typography.subtitleFont)
                        .tracking(0.8)
                        .foregroundColor(DesignSystem.colors.textSecondary)
                }
                .padding(.bottom, DesignSystem.spacing.xxl + 20)

                Spacer()

                VStack(spacing: DesignSystem.spacing.lg) {
                    GradientButton(
                        label: L.play,
                        action: { navigationPath.append(.modeSelection) }
                    )

                    GlassButton(
                        label: L.howToPlay,
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
