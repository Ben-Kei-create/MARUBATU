import SwiftUI

struct ModeSelectionView: View {
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
                }
                .padding(.horizontal, DesignSystem.spacing.xl)
                .padding(.vertical, DesignSystem.spacing.lg)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DesignSystem.spacing.lg) {
                        Text(L.chooseMode)
                            .font(DesignSystem.typography.titleFont)
                            .tracking(2.5)
                            .foregroundColor(DesignSystem.colors.textPrimary)
                            .padding(.bottom, DesignSystem.spacing.sm)

                        ModeCard(
                            icon: "sparkles",
                            title: "詰めNEXUS",
                            subtitle: "◯×から始める戦術チュートリアル",
                            action: {
                                navigationPath.append(.tutorial)
                            }
                        )

                        ModeCard(
                            icon: "cpu",
                            title: L.vsAI,
                            subtitle: L.vsAIDesc,
                            action: {
                                navigationPath.append(.gameplay(mode: .vsAI))
                            }
                        )

                        ModeCard(
                            icon: "person.2.fill",
                            title: L.twoPlayerMode,
                            subtitle: L.twoPlayerDesc,
                            action: {
                                navigationPath.append(.gameplay(mode: .twoPlayer))
                            }
                        )
                    }
                    .frame(maxWidth: 322)
                    .frame(maxWidth: .infinity)
                    .padding(.top, DesignSystem.spacing.xl)
                    .padding(.bottom, DesignSystem.spacing.xxl)
                }
            }
        }
    }
}

#Preview {
    ModeSelectionView(navigationPath: .constant([]))
}
