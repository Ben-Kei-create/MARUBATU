import SwiftUI

struct SkillData: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let cost: Int
    let icon: String
}

let skillsAvailable: [SkillData] = [
    SkillData(
        name: "Line Break",
        description: "Remove all marks from a selected line.",
        cost: 3,
        icon: "bolt.fill"
    ),
    SkillData(
        name: "Color Change",
        description: "Convert selected enemy marks into your marks.",
        cost: 4,
        icon: "paintbrush.fill"
    ),
    SkillData(
        name: "Area Freeze",
        description: "Freeze selected cells for one turn.",
        cost: 5,
        icon: "snowflake"
    ),
    SkillData(
        name: "Reset",
        description: "Reset part of the board.",
        cost: 6,
        icon: "arrow.clockwise"
    )
]

struct SkillSelectionView: View {
    @Binding var navigationPath: [NavigationDestination]
    @State private var currentEnergy = 6

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

                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(DesignSystem.colors.accentBlue)

                        Text("Energy \(currentEnergy) / 10")
                            .font(.system(size: 13, weight: .light))
                            .foregroundColor(DesignSystem.colors.textSecondary)
                    }

                    Spacer()
                }
                .padding(DesignSystem.spacing.lg)

                Text(L.selectSkill)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DesignSystem.colors.textPrimary)
                    .tracking(0.3)
                    .padding(.horizontal, DesignSystem.spacing.lg)
                    .padding(.vertical, DesignSystem.spacing.md)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DesignSystem.spacing.md) {
                        ForEach(skillsAvailable) { skill in
                            Button(action: {
                                navigationPath.append(.skillTargetSelection(skill: skill.name))
                            }) {
                                HStack(spacing: DesignSystem.spacing.md) {
                                    Image(systemName: skill.icon)
                                        .font(.system(size: 20, weight: .light))
                                        .foregroundColor(currentEnergy >= skill.cost ? DesignSystem.colors.accentBlue : DesignSystem.colors.unavailable)
                                        .frame(width: 36, alignment: .center)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(skill.name)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(currentEnergy >= skill.cost ? DesignSystem.colors.textPrimary : DesignSystem.colors.unavailable)

                                        Text(skill.description)
                                            .font(.system(size: 12, weight: .light))
                                            .foregroundColor(DesignSystem.colors.textSecondary)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                    Text("\(skill.cost)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(currentEnergy >= skill.cost ? DesignSystem.colors.accentBlue : DesignSystem.colors.unavailable)
                                        .frame(width: 30, alignment: .center)
                                }
                                .padding(DesignSystem.spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(DesignSystem.colors.glass)
                                        .background(.ultraThinMaterial)
                                    .cornerRadius(12)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            (currentEnergy >= skill.cost ? DesignSystem.colors.accentBlue : DesignSystem.colors.unavailable).opacity(0.3),
                                            lineWidth: 0.5
                                        )
                                )
                            }
                            .disabled(currentEnergy < skill.cost)
                        }
                    }
                    .padding(DesignSystem.spacing.lg)
                }

                GlassButton(
                    label: L.back,
                    action: { navigationPath.removeLast() }
                )
                .padding(DesignSystem.spacing.lg)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SkillSelectionView(navigationPath: .constant([]))
}
