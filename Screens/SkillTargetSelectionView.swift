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
                    Text("スキル: \(displaySkillName)")
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
                        label: "決定",
                        action: confirmSelection
                    )
                    .padding(DesignSystem.spacing.lg)
                } else {
                    GlassButton(
                        label: "キャンセル",
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

    private var displaySkillName: String {
        skillsAvailable.first { $0.name == skillName }?.displayName ?? skillName
    }

    private var targetPrompt: String {
        usesAreaTarget ? "2x2エリアを選択" : "対象ラインを選択"
    }

    private var usesAreaTarget: Bool {
        skillName == "Area Freeze" || skillName == "Reset"
    }

    private var allowsDiagonalTargets: Bool {
        skillName == "Color Change"
    }

    private var lineTargetSections: some View {
        VStack(spacing: DesignSystem.spacing.lg) {
            TargetSection(title: "横ライン") {
                ForEach(0..<5, id: \.self) { row in
                    targetButton(
                        label: "\(row + 1)行目",
                        targetIndex: GameViewModel.rowTarget(row)
                    )
                }
            }

            TargetSection(title: "縦ライン") {
                ForEach(0..<4, id: \.self) { column in
                    targetButton(
                        label: "\(column + 1)列目",
                        targetIndex: GameViewModel.columnTarget(column)
                    )
                }
            }

            if allowsDiagonalTargets {
                TargetSection(title: "斜めライン") {
                    ForEach(0..<8, id: \.self) { diagonal in
                        targetButton(
                            label: "斜め \(diagonal + 1)",
                            targetIndex: GameViewModel.diagonalTarget(diagonal)
                        )
                    }
                }
            }
        }
    }

    private var areaTargetSections: some View {
        TargetSection(title: "2x2エリア") {
            ForEach(0..<4, id: \.self) { row in
                ForEach(0..<3, id: \.self) { column in
                    targetButton(
                        label: "\(row + 1)行目・\(column + 1)列目",
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
