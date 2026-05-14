import SwiftUI

struct SkillTargetSelectionView: View {
    @Binding var navigationPath: [NavigationDestination]
    let skillName: String
    @EnvironmentObject private var vm: GameViewModel
    @State private var selectedTargetIndex: Int?

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

                VStack(alignment: .leading, spacing: 8) {
                    Text("Skill: \(skillName)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignSystem.colors.textPrimary)
                        .tracking(0.3)

                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(DesignSystem.colors.accentBlue)

                        Text("\(skillCost)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DesignSystem.colors.textPrimary)
                    }
                }
                .padding(DesignSystem.spacing.lg)

                Text(targetPrompt)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(DesignSystem.colors.textSecondary)
                    .padding(.horizontal, DesignSystem.spacing.lg)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DesignSystem.spacing.lg) {
                        if usesAreaTarget {
                            areaTargetSections
                        } else {
                            lineTargetSections
                        }
                    }
                    .padding(.vertical, DesignSystem.spacing.lg)
                }

                if selectedTargetIndex != nil {
                    GradientButton(
                        label: "Confirm",
                        action: confirmSelection
                    )
                    .padding(DesignSystem.spacing.lg)
                } else {
                    GlassButton(
                        label: "Cancel",
                        action: { navigationPath.removeLast() }
                    )
                    .padding(DesignSystem.spacing.lg)
                }
            }
        }
        .ignoresSafeArea()
    }

    private var skillCost: Int {
        skillsAvailable.first { $0.name == skillName }?.cost ?? 0
    }

    private var targetPrompt: String {
        usesAreaTarget ? "Select a 2x2 area" : "Select a target line"
    }

    private var usesAreaTarget: Bool {
        skillName == "Area Freeze" || skillName == "Reset"
    }

    private var allowsDiagonalTargets: Bool {
        skillName == "Color Change"
    }

    private var lineTargetSections: some View {
        VStack(spacing: DesignSystem.spacing.lg) {
            TargetSection(title: "Horizontal Lines") {
                ForEach(0..<5, id: \.self) { row in
                    targetButton(
                        label: "Row \(row + 1)",
                        targetIndex: GameViewModel.rowTarget(row)
                    )
                }
            }

            TargetSection(title: "Vertical Lines") {
                ForEach(0..<4, id: \.self) { column in
                    targetButton(
                        label: "Column \(column + 1)",
                        targetIndex: GameViewModel.columnTarget(column)
                    )
                }
            }

            if allowsDiagonalTargets {
                TargetSection(title: "Diagonal Lines") {
                    ForEach(0..<8, id: \.self) { diagonal in
                        targetButton(
                            label: "Diagonal \(diagonal + 1)",
                            targetIndex: GameViewModel.diagonalTarget(diagonal)
                        )
                    }
                }
            }
        }
    }

    private var areaTargetSections: some View {
        TargetSection(title: "2x2 Areas") {
            ForEach(0..<4, id: \.self) { row in
                ForEach(0..<3, id: \.self) { column in
                    targetButton(
                        label: "Row \(row + 1), Column \(column + 1)",
                        targetIndex: row * 4 + column
                    )
                }
            }
        }
    }

    private func targetButton(label: String, targetIndex: Int) -> some View {
        Button(action: { selectedTargetIndex = targetIndex }) {
            Text(label)
                .font(.system(size: 13, weight: .light))
                .foregroundColor(
                    selectedTargetIndex == targetIndex
                        ? .white
                        : DesignSystem.colors.accentBlue
                )
                .frame(maxWidth: .infinity)
                .padding(DesignSystem.spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            selectedTargetIndex == targetIndex
                                ? DesignSystem.colors.accentBlue
                                : Color.clear
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            DesignSystem.colors.accentBlue.opacity(0.4),
                            lineWidth: 0.5
                        )
                )
        }
    }

    private func confirmSelection() {
        guard let selectedTargetIndex else { return }
        vm.activateSkill(skillName, targetIndex: selectedTargetIndex)

        if navigationPath.count >= 2 {
            navigationPath.removeLast(2)
        } else if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
}

private struct TargetSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing.md) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DesignSystem.colors.textSecondary)
                .tracking(0.3)
                .padding(.horizontal, DesignSystem.spacing.lg)

            VStack(spacing: 8) {
                content
            }
            .padding(.horizontal, DesignSystem.spacing.lg)
        }
    }
}

#Preview {
    SkillTargetSelectionView(navigationPath: .constant([]), skillName: "Line Break")
        .environmentObject(GameViewModel(mode: .vsAI))
}
