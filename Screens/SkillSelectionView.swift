import SwiftUI

struct SkillData: Identifiable {
    let id = UUID()
    let name: String
    let displayName: String
    let description: String
    let cost: Int
    let icon: String
}

let skillsAvailable: [SkillData] = [
    SkillData(name: "Line Break", displayName: "ラインブレイク", description: "選んだ行または列のマークをすべて消します。", cost: 3, icon: "bolt.fill"),
    SkillData(name: "Color Change", displayName: "カラー変更", description: "敵のマークを最大3つ自分のマークに変えます。", cost: 4, icon: "paintbrush.fill"),
    SkillData(name: "Area Freeze", displayName: "エリア凍結", description: "選んだ2x2エリアを2ターン凍結します。", cost: 5, icon: "snowflake"),
    SkillData(name: "Reset", displayName: "リセット", description: "選んだ2x2エリアを空に戻します。", cost: 6, icon: "arrow.clockwise")
]

struct SkillSelectionView: View {
    @Binding var navigationPath: [NavigationDestination]
    @EnvironmentObject private var vm: GameViewModel

    var body: some View {
        ZStack {
            FuturisticBackground()

            VStack(spacing: 0) {
                HStack {
                    IconButton(iconName: "chevron.left", action: { navigationPath.removeLast() })
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(DesignSystem.colors.accentBlue)
                        Text("エネルギー \(vm.energy) / 10")
                            .font(.app(size: 13, weight: .light))
                            .foregroundColor(DesignSystem.colors.textSecondary)
                    }
                }
                .padding(.horizontal, DesignSystem.spacing.xl)
                .padding(.vertical, DesignSystem.spacing.lg)

                Text("スキル選択")
                    .font(.app(size: 18, weight: .semibold))
                    .foregroundColor(DesignSystem.colors.textPrimary)
                    .tracking(0.3)
                    .padding(DesignSystem.spacing.lg)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DesignSystem.spacing.md) {
                        ForEach(skillsAvailable) { skill in
                            SkillRow(skill: skill, currentEnergy: vm.energy, navigationPath: $navigationPath)
                        }
                    }
                    .padding(DesignSystem.spacing.lg)
                }

                GlassButton(label: "キャンセル", action: { navigationPath.removeLast() })
                    .padding(DesignSystem.spacing.lg)
            }
        }
    }
}

struct SkillRow: View {
    let skill: SkillData
    let currentEnergy: Int
    @Binding var navigationPath: [NavigationDestination]
    
    var isAvailable: Bool {
        currentEnergy >= skill.cost
    }
    
    var body: some View {
        Button(action: {
            if isAvailable {
                navigationPath.append(.skillTargetSelection(skill: skill.name))
            }
        }) {
            HStack(spacing: DesignSystem.spacing.md) {
                Image(systemName: skill.icon)
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(isAvailable ? DesignSystem.colors.accentBlue : DesignSystem.colors.unavailable)
                    .frame(width: 36, alignment: .center)

                VStack(alignment: .leading, spacing: 4) {
                    Text(skill.displayName)
                        .font(.app(size: 15, weight: .medium))
                        .foregroundColor(isAvailable ? DesignSystem.colors.textPrimary : DesignSystem.colors.unavailable)
                    Text(skill.description)
                        .font(.app(size: 12, weight: .light))
                        .foregroundColor(DesignSystem.colors.textSecondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(skill.cost)")
                    .font(.app(size: 14, weight: .medium))
                    .foregroundColor(isAvailable ? DesignSystem.colors.accentBlue : DesignSystem.colors.unavailable)
                    .frame(width: 30, alignment: .center)
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
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke((isAvailable ? DesignSystem.colors.accentBlue : DesignSystem.colors.unavailable).opacity(0.3), lineWidth: 0.5)
            )
        }
        .disabled(!isAvailable)
    }
}

#Preview {
    SkillSelectionView(navigationPath: .constant([]))
        .environmentObject(GameViewModel(mode: .vsAI))
}
