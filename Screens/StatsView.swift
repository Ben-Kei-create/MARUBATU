import SwiftUI

struct StatsView: View {
    @Binding var navigationPath: [NavigationDestination]
    @State private var selectedTab: String = "Total"
    @StateObject private var stats = StatsViewModel()
    let tabs = ["Total", "VS AI", "2P Mode"]

    var body: some View {
        ZStack {
            FuturisticBackground()

            VStack(spacing: 0) {
                HStack {
                    IconButton(iconName: "chevron.left", action: { navigationPath.removeLast() })
                    Spacer()
                    Text("Stats")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DesignSystem.colors.textPrimary)
                        .tracking(0.5)
                    Spacer()
                    IconButton(iconName: "xmark", action: { navigationPath.removeLast() })
                }
                .padding(DesignSystem.spacing.lg)

                HStack(spacing: 16) {
                    ForEach(tabs, id: \.self) { tab in
                        TabButton(tab: tab, isSelected: selectedTab == tab, action: { selectedTab = tab })
                    }
                    Spacer()
                }
                .padding(DesignSystem.spacing.lg)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DesignSystem.spacing.xl) {
                        ZStack {
                            Circle()
                                .stroke(
                                    LinearGradient(gradient: Gradient(colors: [DesignSystem.colors.accentBlue, DesignSystem.colors.accentBlue.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 12
                                )
                                .frame(width: 140, height: 140)
                                .shadow(color: DesignSystem.colors.accentBlue.opacity(0.4), radius: 12)

                            VStack(spacing: 4) {
                                Text("Win Rate")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(DesignSystem.colors.textSecondary)
                                Text("\(Int((stats.winRate * 100).rounded()))%")
                                    .font(.system(size: 28, weight: .thin))
                                    .foregroundColor(DesignSystem.colors.accentBlue)
                            }
                        }

                        VStack(spacing: DesignSystem.spacing.md) {
                            StatRow(label: "Total Plays", value: "\(stats.totalPlays)")
                            StatRow(label: "Wins", value: "\(stats.totalWins)", valueColor: DesignSystem.colors.accentBlue)
                            StatRow(label: "Best Score", value: "\(stats.bestScore)")
                            StatRow(label: "Win Streak", value: "\(stats.winStreak)", valueColor: DesignSystem.colors.accentPurple)
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
        .onAppear {
            stats.load(mode: modeForSelectedTab)
        }
        .onChange(of: selectedTab) { _, _ in
            stats.load(mode: modeForSelectedTab)
        }
    }

    private var modeForSelectedTab: GameMode? {
        switch selectedTab {
        case "VS AI":
            .vsAI
        case "2P Mode":
            .twoPlayer
        default:
            nil
        }
    }
}

struct TabButton: View {
    let tab: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tab)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? DesignSystem.colors.accentBlue : DesignSystem.colors.textSecondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
        }
        .if(isSelected) { view in
            view
                .background(DesignSystem.colors.glass)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    var valueColor: Color = DesignSystem.colors.textPrimary
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(DesignSystem.colors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(valueColor)
        }
        .padding(DesignSystem.spacing.md)
        .background(DesignSystem.colors.glass)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    StatsView(navigationPath: .constant([]))
}
