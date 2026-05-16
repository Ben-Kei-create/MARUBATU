import SwiftUI

struct StatsView: View {
    @Binding var navigationPath: [NavigationDestination]
    @State private var selectedTab: String = "総合"
    @StateObject private var stats = StatsViewModel()
    let tabs = ["総合", "AI対戦", "2人プレイ"]

    var body: some View {
        ZStack {
            FuturisticBackground()

            VStack(spacing: 0) {
                HStack {
                    IconButton(iconName: "chevron.left", action: { navigationPath.removeLast() })
                    Spacer()
                    Text("統計")
                        .font(.app(size: 18, weight: .semibold))
                        .foregroundColor(DesignSystem.colors.textPrimary)
                        .tracking(0.5)
                    Spacer()
                    IconButton(iconName: "xmark", action: { navigationPath.removeLast() })
                }
                .padding(.horizontal, DesignSystem.spacing.xl)
                .padding(.vertical, DesignSystem.spacing.lg)

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
                                Text("勝率")
                                    .font(.app(size: 12, weight: .light))
                                    .foregroundColor(DesignSystem.colors.textSecondary)
                                Text("\(Int((stats.winRate * 100).rounded()))%")
                                    .font(.app(size: 28, weight: .thin))
                                    .foregroundColor(DesignSystem.colors.accentBlue)
                            }
                        }

                        VStack(spacing: DesignSystem.spacing.md) {
                            StatRow(label: "合計プレイ数", value: "\(stats.totalPlays)")
                            StatRow(label: "勝利数", value: "\(stats.totalWins)", valueColor: DesignSystem.colors.accentBlue)
                            StatRow(label: "最高スコア", value: "\(stats.bestScore)")
                            StatRow(label: "連勝数", value: "\(stats.winStreak)", valueColor: DesignSystem.colors.accentPurple)
                            StatRow(label: "最大連勝", value: "\(stats.maxWinStreak)", valueColor: DesignSystem.colors.accentPurple)
                        }
                    }
                    .padding(DesignSystem.spacing.lg)
                }

                HStack(spacing: DesignSystem.spacing.lg) {
                    Button(action: { navigationPath.removeAll() }) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(DesignSystem.colors.textSecondary)
                    }
                    Button(action: { selectedTab = "総合" }) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(DesignSystem.colors.accentBlue)
                    }
                    Spacer()
                    Button(action: { navigationPath.append(.settings) }) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(DesignSystem.colors.textSecondary.opacity(0.5))
                    }
                }
                .padding(DesignSystem.spacing.lg)
            }
        }
        .onAppear {
            stats.load(mode: modeForSelectedTab)
        }
        .onChange(of: selectedTab) { _, _ in
            stats.load(mode: modeForSelectedTab)
        }
    }

    private var modeForSelectedTab: GameMode? {
        switch selectedTab {
        case "AI対戦":
            .vsAI
        case "2人プレイ":
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
                .font(.app(size: 13, weight: .medium))
                .foregroundColor(isSelected ? DesignSystem.colors.accentBlue : DesignSystem.colors.textSecondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
        }
        .if(isSelected) { view in
            view
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(DesignSystem.colors.glass)
                        )
                )
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
                .font(.app(size: 14, weight: .light))
                .foregroundColor(DesignSystem.colors.textSecondary)
            Spacer()
            Text(value)
                .font(.app(size: 16, weight: .medium))
                .foregroundColor(valueColor)
        }
        .padding(DesignSystem.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(DesignSystem.colors.glass)
                )
        )
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
