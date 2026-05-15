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
        title: "4x5ボード",
        description: "4列x5行の盤面で、XとOを置いてライン完成を狙います。",
        iconColor: DesignSystem.colors.accentBlue
    ),
    RuleSection(
        icon: "line.3.horizontal.decrease",
        title: "ライン完成",
        description: "横・縦・斜めに3つ以上そろえると得点。複数ラインならボーナスが入ります。",
        iconColor: DesignSystem.colors.accentBlue
    ),
    RuleSection(
        icon: "bolt.fill",
        title: "エネルギー",
        description: "ターンごとにエネルギーが増えます。ためたエネルギーで強力なスキルを使えます。",
        iconColor: Color(red: 1.0, green: 0.6, blue: 0.2)
    ),
    RuleSection(
        icon: "sparkles",
        title: "スキル",
        description: "ライン破壊、色変更、エリア凍結、リセットで盤面を大きく動かせます。",
        iconColor: DesignSystem.colors.accentPurple
    ),
    RuleSection(
        icon: "star.fill",
        title: "エリア効果",
        description: "2x2エリアを狙った効果で、相手の狙いを止めたり形勢を立て直したりできます。",
        iconColor: DesignSystem.colors.accentBlue
    )
]
