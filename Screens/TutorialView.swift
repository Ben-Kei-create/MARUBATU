import SwiftUI

struct TutorialView: View {
    @Binding var navigationPath: [NavigationDestination]
    @StateObject private var vm = TutorialViewModel()

    var body: some View {
        ZStack {
            FuturisticBackground()

            VStack(spacing: 0) {
                header

                VStack(spacing: DesignSystem.spacing.md) {
                    packTabs
                    lessonPanel

                    Spacer(minLength: DesignSystem.spacing.sm)

                    GameBoard(
                        marks: vm.board,
                        selectedIndex: nil,
                        highlightedIndices: vm.highlightedCells,
                        frozenIndices: vm.frozenCells,
                        cellSize: 62,
                        spacing: 10,
                        boardPadding: 8
                    ) { index in
                        vm.placeMark(at: index)
                    }
                    .scaleEffect(vm.mistakePulse ? 0.985 : 1)
                    .animation(.spring(response: 0.18, dampingFraction: 0.55), value: vm.mistakePulse)

                    Spacer(minLength: DesignSystem.spacing.sm)

                    actionArea
                }
                .padding(.horizontal, DesignSystem.spacing.lg)
                .padding(.bottom, DesignSystem.spacing.lg)
            }
        }
    }

    private var header: some View {
        HStack {
            IconButton(
                iconName: "chevron.left",
                action: { navigationPath.removeLast() }
            )

            Spacer()

            Text("詰めNEXUS")
                .font(.app(size: 18, weight: .semibold))
                .foregroundColor(DesignSystem.colors.textPrimary)
                .tracking(0.5)

            Spacer()

            Text(vm.progressText)
                .font(.app(size: 13, weight: .medium))
                .foregroundColor(DesignSystem.colors.accentBlue)
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, DesignSystem.spacing.xl)
        .padding(.vertical, DesignSystem.spacing.lg)
        .padding(.top, DesignSystem.spacing.md)
    }

    private var lessonPanel: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing.md) {
            HStack(spacing: DesignSystem.spacing.sm) {
                Circle()
                    .fill(DesignSystem.colors.accentBlue)
                    .frame(width: 8, height: 8)
                    .shadow(color: DesignSystem.colors.accentBlue.opacity(0.8), radius: 8)

                Text(vm.currentLesson.title)
                    .font(.app(size: 17, weight: .semibold))
                    .foregroundColor(DesignSystem.colors.textPrimary)
            }

            Text(vm.currentLesson.subtitle)
                .font(.app(size: 13, weight: .light))
                .foregroundColor(DesignSystem.colors.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            Text(vm.feedbackText)
                .font(.app(size: 13, weight: .medium))
                .foregroundColor(vm.isSolved ? DesignSystem.colors.accentBlue : DesignSystem.colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, DesignSystem.spacing.xs)

            if vm.isSkillLesson {
                skillStrip
            }
        }
        .padding(DesignSystem.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(DesignSystem.colors.glass)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DesignSystem.colors.accentBlue.opacity(vm.isSolved ? 0.55 : 0.22), lineWidth: 1)
        )
    }

    private var packTabs: some View {
        HStack(spacing: DesignSystem.spacing.sm) {
            ForEach(Array(vm.packs.enumerated()), id: \.element.id) { index, pack in
                Button(action: { vm.selectPack(at: index) }) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(pack.title)
                            .font(.app(size: 13, weight: .semibold))
                            .foregroundColor(index == vm.packIndex ? .white : DesignSystem.colors.textSecondary)

                        Text(pack.subtitle)
                            .font(.app(size: 10, weight: .light))
                            .foregroundColor(index == vm.packIndex ? .white.opacity(0.7) : DesignSystem.colors.textSecondary.opacity(0.75))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 9)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(index == vm.packIndex ? DesignSystem.colors.accentBlue.opacity(0.72) : DesignSystem.colors.glass)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(DesignSystem.colors.accentBlue.opacity(index == vm.packIndex ? 0.55 : 0.18), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var skillStrip: some View {
        HStack(spacing: DesignSystem.spacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .light))
                .foregroundColor(DesignSystem.colors.accentBlue)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(DesignSystem.colors.accentBlue.opacity(0.14))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(vm.skillTitle)
                    .font(.app(size: 13, weight: .medium))
                    .foregroundColor(DesignSystem.colors.textPrimary)

                Text(vm.skillCostText)
                    .font(.app(size: 11, weight: .light))
                    .foregroundColor(DesignSystem.colors.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignSystem.colors.accentBlue.opacity(0.08))
        )
    }

    private var actionArea: some View {
        VStack(spacing: DesignSystem.spacing.md) {
            if vm.canGoNext {
                GradientButton(label: "次の問題", action: vm.goNext)
            } else if vm.canGoNextPack {
                GradientButton(label: "スキル問題へ", action: vm.goNextPack)
            } else if vm.isComplete {
                GradientButton(label: "AI対戦へ", action: {
                    navigationPath.append(.gameplay(mode: .vsAI))
                })

                GlassButton(label: "最初から", action: vm.reset)
            } else if vm.isSkillLesson {
                GradientButton(label: "スキル発動", action: vm.performSkill)
            } else {
                HStack(spacing: DesignSystem.spacing.sm) {
                    Image(systemName: "scope")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(DesignSystem.colors.accentBlue)

                    Text("青い枠を狙う")
                        .font(.app(size: 14, weight: .medium))
                        .foregroundColor(DesignSystem.colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            }
        }
    }
}

#Preview {
    TutorialView(navigationPath: .constant([]))
}
