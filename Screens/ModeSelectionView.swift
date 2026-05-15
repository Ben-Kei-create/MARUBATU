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
                .padding(DesignSystem.spacing.lg)

                Spacer()

                VStack(spacing: DesignSystem.spacing.lg) {
                    Text(L.chooseMode)
                        .font(DesignSystem.typography.titleFont)
                        .tracking(2.5)
                        .foregroundColor(DesignSystem.colors.textPrimary)

                    Spacer()
                        .frame(height: DesignSystem.spacing.lg)

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

                    Spacer()
                }
                .padding(.horizontal, DesignSystem.spacing.lg)

                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ModeSelectionView(navigationPath: .constant([]))
}
