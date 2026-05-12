import SwiftUI

struct HowToPlayView: View {
    @Binding var navigationPath: [NavigationDestination]

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

                    Text("How to Play")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DesignSystem.colors.textPrimary)
                        .tracking(0.5)

                    Spacer()

                    IconButton(
                        iconName: "xmark",
                        action: { navigationPath.removeLast() }
                    )
                }
                .padding(DesignSystem.spacing.lg)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(rulesContent) { rule in
                            RuleCard(
                                icon: rule.icon,
                                title: rule.title,
                                description: rule.description,
                                iconColor: rule.iconColor
                            )
                            .padding(.horizontal, DesignSystem.spacing.lg)
                            .padding(.vertical, DesignSystem.spacing.md)

                            if rule.id != rulesContent.last?.id {
                                Divider()
                                    .foregroundColor(DesignSystem.colors.textSecondary.opacity(0.2))
                                    .padding(.horizontal, DesignSystem.spacing.lg)
                            }
                        }
                    }
                    .padding(.vertical, DesignSystem.spacing.md)
                }

                VStack(spacing: DesignSystem.spacing.lg) {
                    GradientButton(
                        label: "Got It",
                        action: { navigationPath.removeLast() }
                    )

                    GlassButton(
                        label: "Back",
                        action: { navigationPath.removeLast() }
                    )
                }
                .padding(DesignSystem.spacing.lg)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HowToPlayView(navigationPath: .constant([]))
}
