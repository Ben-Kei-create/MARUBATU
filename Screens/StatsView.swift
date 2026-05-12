import SwiftUI

struct StatsView: View {
    @Binding var navigationPath: [NavigationDestination]
    @State private var selectedTab: String = "Total"
    let tabs = ["Total", "VS AI", "2P Mode"]

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

                    Text("Stats")
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

                HStack(spacing: 16) {
                    ForEach(tabs, id: \.self) { tab in
                        Button(action: { selectedTab = tab }) {
                            Text(tab)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(
                                    selectedTab == tab
                                        ? DesignSystem.colors.accentBlue
                                        : DesignSystem.colors.textSecondary
                                )
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    selectedTab == tab
                                        ? RoundedRectangle(cornerRadius: 8)
                                            .fill(DesignSystem.colors.glass)
                                            .backdrop(cornerRadius: 8)
                                        : nil
                                )
                        }
                    }
                    Spacer()
                }
                .padding(DesignSystem.spacing.lg)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DesignSystem.spacing.xl) {
                        ZStack {
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            DesignSystem.colors.accentBlue,
                                            DesignSystem.colors.accentBlue.opacity(0.3)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 12
                                )
                                .frame(width: 140, height: 140)
                                .shadow(color: DesignSystem.colors.accentBlue.opacity(0.4), radius: 12)

                            VStack(spacing: 4) {
                                Text("Win Rate")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(DesignSystem.colors.textSecondary)

                                Text("62%")
                                    .font(.system(size: 28, weight: .thin))
                                    .foregroundColor(DesignSystem.colors.accentBlue)
                            }
                        }

                        VStack(spacing: DesignSystem.spacing.md) {
                            HStack {
                                Text("Total Plays")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(DesignSystem.colors.textSecondary)
                                Spacer()
                                Text("48")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(DesignSystem.colors.textPrimary)
                            }
                            .padding(DesignSystem.spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(DesignSystem.colors.glass)
                                    .backdrop(cornerRadius: 12)
                            )

                            HStack {
                                Text("Wins")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(DesignSystem.colors.textSecondary)
                                Spacer()
                                Text("30")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(DesignSystem.colors.accentBlue)
                            }
                            .padding(DesignSystem.spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(DesignSystem.colors.glass)
                                    .backdrop(cornerRadius: 12)
                            )

                            HStack {
                                Text("Best Score")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(DesignSystem.colors.textSecondary)
                                Spacer()
                                Text("38")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(DesignSystem.colors.textPrimary)
                            }
                            .padding(DesignSystem.spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(DesignSystem.colors.glass)
                                    .backdrop(cornerRadius: 12)
                            )

                            HStack {
                                Text("Win Streak")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(DesignSystem.colors.textSecondary)
                                Spacer()
                                Text("5")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(DesignSystem.colors.accentPurple)
                            }
                            .padding(DesignSystem.spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(DesignSystem.colors.glass)
                                    .backdrop(cornerRadius: 12)
                            )
                        }
                    }
                    .padding(DesignSystem.spacing.lg)
                }

                HStack(spacing: DesignSystem.spacing.lg) {
                    Button(action: {}) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(DesignSystem.colors.textSecondary)
                    }

                    Button(action: {}) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(DesignSystem.colors.accentBlue)
                    }

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(DesignSystem.colors.textSecondary.opacity(0.5))
                    }
                }
                .padding(DesignSystem.spacing.lg)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    StatsView(navigationPath: .constant([]))
}
