import SwiftUI

struct RuleSection: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let iconColor: Color
}

let rulesContent: [RuleSection] = [
    RuleSection(
        icon: "square.grid.4x5.fill",
        title: "4x5 Board",
        description: "Play on a 4-column, 5-row grid. Place X and O to dominate the board.",
        iconColor: DesignSystem.colors.accentBlue
    ),
    RuleSection(
        icon: "line.3.horizontal.decrease",
        title: "Complete Lines",
        description: "Create horizontal, vertical, or diagonal lines to score points and gain bonuses.",
        iconColor: DesignSystem.colors.accentBlue
    ),
    RuleSection(
        icon: "bolt.fill",
        title: "Energy",
        description: "Build energy each turn. Use it to activate powerful skills and special abilities.",
        iconColor: Color(red: 1.0, green: 0.6, blue: 0.2)
    ),
    RuleSection(
        icon: "sparkles",
        title: "Skills",
        description: "Break lines, change marks, freeze cells, or reset sections using energy.",
        iconColor: DesignSystem.colors.accentPurple
    ),
    RuleSection(
        icon: "star.fill",
        title: "Area Effects",
        description: "Certain cells become special zones with unique effects. Plan strategically.",
        iconColor: DesignSystem.colors.accentBlue
    )
]
