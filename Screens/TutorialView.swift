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
                    lessonPanel

                    Spacer(minLength: DesignSystem.spacing.sm)

                    GameBoard(
                        marks: vm.board,
                        selectedIndex: nil,
                        highlightedIndices: vm.highlightedCells
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
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            IconButton(
                iconName: "chevron.left",
                action: { navigationPath.removeLast() }
            )

            Spacer()

            Text("詰めNEXUS")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(DesignSystem.colors.textPrimary)
                .tracking(0.5)

            Spacer()

            Text(vm.progressText)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DesignSystem.colors.accentBlue)
                .frame(width: 44, height: 44)
        }
        .padding(DesignSystem.spacing.lg)
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
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(DesignSystem.colors.textPrimary)
            }

            Text(vm.currentLesson.subtitle)
                .font(.system(size: 13, weight: .light))
                .foregroundColor(DesignSystem.colors.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            Text(vm.feedbackText)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(vm.isSolved ? DesignSystem.colors.accentBlue : DesignSystem.colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, DesignSystem.spacing.xs)
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

    private var actionArea: some View {
        VStack(spacing: DesignSystem.spacing.md) {
            if vm.canGoNext {
                GradientButton(label: "次の問題", action: vm.goNext)
            } else if vm.isComplete {
                GradientButton(label: "AI対戦へ", action: {
                    navigationPath.append(.gameplay(mode: .vsAI))
                })

                GlassButton(label: "最初から", action: vm.reset)
            } else {
                HStack(spacing: DesignSystem.spacing.sm) {
                    Image(systemName: "scope")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(DesignSystem.colors.accentBlue)

                    Text("青い枠を狙う")
                        .font(.system(size: 14, weight: .medium))
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
