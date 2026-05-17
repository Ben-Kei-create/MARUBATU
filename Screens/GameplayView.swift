import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct GameplayView: View {
    @Binding var navigationPath: [NavigationDestination]
    let mode: GameMode
    @StateObject private var vm: GameViewModel
    @State private var energyPulse = false
    @State private var armedSkill: SkillData?

    init(
        navigationPath: Binding<[NavigationDestination]>,
        mode: GameMode,
        viewModel: GameViewModel? = nil
    ) {
        _navigationPath = navigationPath
        self.mode = mode
        _vm = StateObject(wrappedValue: viewModel ?? GameViewModel(mode: mode))
    }

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

                    IconButton(
                        iconName: "ellipsis",
                        action: { navigationPath.append(.settings) }
                    )
                }
                .padding(.horizontal, DesignSystem.spacing.xl)
                .padding(.top, DesignSystem.spacing.sm)
                .padding(.bottom, DesignSystem.spacing.sm)

                ZStack(alignment: .top) {
                    HStack(alignment: .top, spacing: DesignSystem.spacing.xl) {
                        PlayerScorePanel(
                            isPlayer: true,
                            score: vm.playerScore,
                            isTurn: vm.currentPlayer == .x && !vm.isAITurn,
                            label: mode == .twoPlayer ? "P1" : "YOU"
                        )

                        Spacer()

                        PlayerScorePanel(
                            isPlayer: false,
                            score: vm.opponentScore,
                            isTurn: vm.currentPlayer == .o,
                            label: mode == .twoPlayer ? "P2" : "AI"
                        )
                    }

                    TurnStatusView(title: turnStatusTitle, accent: currentTurnAccent)
                        .accessibilityLabel(vm.turnLabel)
                }
                .padding(.horizontal, DesignSystem.spacing.lg)
                .padding(.top, 2)
                .padding(.bottom, DesignSystem.spacing.md)

                Spacer(minLength: DesignSystem.spacing.xs)

                GameBoard(
                    marks: vm.board,
                    selectedIndex: nil,
                    highlightedIndices: boardHighlightCells,
                    frozenIndices: vm.frozenCells,
                    scoringLines: vm.scoringLineSegments,
                    scoringPlayer: vm.scoringLinePlayer,
                    scoringAnimationID: vm.scoringPulseID,
                    cellSize: 70,
                    spacing: 12,
                    boardPadding: 0
                ) { index in
                    handleBoardTap(at: index)
                }

                Spacer(minLength: DesignSystem.spacing.xs)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(DesignSystem.colors.accentBlue)

                        Text(L.energy)
                            .font(.app(size: 12, weight: .light))
                            .foregroundColor(DesignSystem.colors.textSecondary)
                            .tracking(0.5)

                        Spacer()

                        Text("\(vm.energy) / 10")
                            .font(.app(size: 12, weight: .medium))
                            .foregroundColor(DesignSystem.colors.textPrimary.opacity(0.72))
                            .monospacedDigit()
                    }

                    EnergyBar(current: vm.energy, max: 10)
                        .scaleEffect(energyPulse ? 1.045 : 1)
                        .animation(.spring(response: 0.18, dampingFraction: 0.55), value: energyPulse)

                    SkillDockView(
                        energy: vm.energy,
                        isAITurn: vm.isAITurn,
                        armedSkill: armedSkill,
                        onSelect: selectSkill
                    )
                }
                .frame(width: 292)
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(DesignSystem.colors.darkBgSecondary.opacity(0.74))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            DesignSystem.colors.accentBlue.opacity(0.1),
                                            DesignSystem.colors.glass.opacity(0.54),
                                            DesignSystem.colors.accentPurple.opacity(0.08)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            DesignSystem.colors.accentBlue.opacity(0.34),
                                            DesignSystem.colors.textSecondary.opacity(0.16),
                                            DesignSystem.colors.accentPurple.opacity(0.26)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: DesignSystem.colors.accentBlue.opacity(0.15), radius: 20, y: 8)
                )
                .frame(maxWidth: .infinity)
                .padding(.top, DesignSystem.spacing.sm)
                .padding(.bottom, DesignSystem.spacing.md)
            }

            if let event = vm.scoringEvent {
                ScoreBurstView(event: event)
                    .id(event.id)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .allowsHitTesting(false)
                    .transition(.scale(scale: 0.82).combined(with: .opacity))
                    .zIndex(5)
            }
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: vm.scoringEvent?.id)
        .onAppear {
            if vm.isGameOver {
                vm.resetGame()
            }
        }
        .onChange(of: vm.isGameOver) { _, isGameOver in
            guard isGameOver else { return }
            navigateToResultIfNeeded()
        }
        .onChange(of: vm.energyPulseID) { _, _ in
            pulseEnergy()
        }
        .onChange(of: vm.scoringEvent?.id) { _, _ in
            guard let event = vm.scoringEvent else { return }
            playScoreFeedback(for: event)
        }
    }

    private func navigateToResultIfNeeded() {
        let result = NavigationDestination.result(
            won: vm.resultWon,
            score: vm.resultScore,
            bonus: vm.totalBonus
        )

        if navigationPath.last != result {
            navigationPath.append(result)
        }
    }

    private var turnStatusTitle: String {
        if vm.isGameOver {
            return vm.resultWon ? "YOU WIN" : "YOU LOSE"
        }

        if vm.isAITurn {
            return "AI TURN"
        }

        switch mode {
        case .vsAI:
            return vm.currentPlayer == .x ? "YOUR TURN" : "AI TURN"
        case .twoPlayer:
            return vm.currentPlayer == .x ? "P1 TURN" : "P2 TURN"
        }
    }

    private var currentTurnAccent: Color {
        vm.currentPlayer == .o ? DesignSystem.colors.accentPurple : DesignSystem.colors.accentBlue
    }

    private var boardHighlightCells: Set<Int> {
        armedSkill == nil ? vm.scoringHighlightCells : []
    }

    private func selectSkill(_ skill: SkillData) {
        guard !vm.isAITurn else { return }
        guard vm.canActivateSkill(skill.name) else {
            pulseEnergy()
            return
        }

        withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
            armedSkill = armedSkill?.name == skill.name ? nil : skill
        }
    }

    private func handleBoardTap(at index: Int) {
        if let armedSkill {
            vm.activateSkill(armedSkill.name, boardIndex: index)
            withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
                self.armedSkill = nil
            }
        } else {
            vm.placeMark(at: index)
        }
    }

    private func pulseEnergy() {
        energyPulse = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 180_000_000)
            energyPulse = false
        }
    }

    private func playScoreFeedback(for event: ScoringEvent) {
        #if canImport(UIKit)
        if event.lineCount >= 2 {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        } else {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        #endif
    }
}

private struct SkillDockView: View {
    let energy: Int
    let isAITurn: Bool
    let armedSkill: SkillData?
    let onSelect: (SkillData) -> Void

    private var dockSkills: [SkillData] {
        skillsAvailable.filter { $0.name == "Line Break" || $0.name == "Area Freeze" }
    }

    var body: some View {
        HStack(spacing: 10) {
            ForEach(dockSkills) { skill in
                FooterSkillButton(
                    icon: iconName(for: skill),
                    cost: skill.cost,
                    isAvailable: energy >= skill.cost && !isAITurn,
                    isArmed: armedSkill?.name == skill.name,
                    label: skill.displayName,
                    action: { onSelect(skill) }
                )
            }

            LockedSkillSlot()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func iconName(for skill: SkillData) -> String {
        switch skill.name {
        case "Line Break":
            return "sparkles"
        case "Area Freeze":
            return "shield"
        default:
            return skill.icon
        }
    }
}

private struct FooterSkillButton: View {
    let icon: String
    let cost: Int?
    let isAvailable: Bool
    let isArmed: Bool
    let label: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(DesignSystem.colors.darkBgSecondary.opacity(0.86))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        accent.opacity(isArmed ? 0.22 : 0.08),
                                        DesignSystem.colors.glass.opacity(0.62)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                accent.opacity(isAvailable ? (isArmed ? 0.78 : 0.38) : 0.14),
                                lineWidth: isArmed ? 1.4 : 1
                            )
                    )
                    .shadow(color: accent.opacity(isArmed ? 0.42 : 0.12), radius: isArmed ? 18 : 8)

                VStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 25, weight: .light))
                        .foregroundColor(isAvailable ? accent : DesignSystem.colors.textSecondary.opacity(0.42))
                        .shadow(color: accent.opacity(isAvailable ? 0.7 : 0), radius: 10)

                    if cost == nil {
                        Text(label)
                            .font(.app(size: 10, weight: .light))
                            .tracking(2.4)
                            .foregroundColor(DesignSystem.colors.textSecondary.opacity(0.48))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if let cost {
                    Text("\(cost)")
                        .font(.app(size: 14, weight: .medium))
                        .foregroundColor(isAvailable ? .white : DesignSystem.colors.textSecondary.opacity(0.55))
                        .frame(width: 31, height: 28)
                        .background(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 13,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 12
                            )
                            .fill(accent.opacity(isAvailable ? 0.55 : 0.16))
                        )
                        .shadow(color: accent.opacity(isAvailable ? 0.42 : 0), radius: 10)
                }
            }
            .frame(width: 78, height: 54)
            .scaleEffect(isPressed ? 0.97 : 1)
            .opacity(isAvailable || cost == nil ? 1 : 0.56)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(label)
        .onLongPressGesture(minimumDuration: 0.01, perform: {}) { pressed in
            isPressed = pressed
        }
    }

    private var accent: Color {
        icon == "shield" ? DesignSystem.colors.accentPurple : DesignSystem.colors.accentBlue
    }
}

private struct LockedSkillSlot: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignSystem.colors.darkBgSecondary.opacity(0.64))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DesignSystem.colors.textSecondary.opacity(0.14), lineWidth: 1)
                )

            VStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 23, weight: .light))
                    .foregroundColor(DesignSystem.colors.textSecondary.opacity(0.36))

                Text("LOCKED")
                    .font(.app(size: 10, weight: .light))
                    .tracking(2.4)
                    .foregroundColor(DesignSystem.colors.textSecondary.opacity(0.44))
            }
        }
        .frame(width: 78, height: 54)
        .accessibilityHidden(true)
    }
}

private struct TurnStatusView: View {
    let title: String
    let accent: Color
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.app(size: 16, weight: .light))
                .foregroundColor(DesignSystem.colors.textPrimary)
                .tracking(4.6)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .shadow(color: accent.opacity(0.82), radius: 13)
                .shadow(color: .white.opacity(0.24), radius: 3)

            Circle()
                .fill(.white.opacity(0.86))
                .frame(width: 7, height: 7)
                .shadow(color: accent.opacity(0.95), radius: pulse ? 16 : 8)
                .scaleEffect(pulse ? 1.24 : 0.86)
        }
        .frame(maxWidth: 170)
        .padding(.top, 3)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

private struct ScoreBurstView: View {
    let event: ScoringEvent
    @State private var lift: CGFloat = 18
    @State private var glow = false

    var body: some View {
        VStack(spacing: 8) {
            Text(event.title)
                .font(.app(size: event.lineCount >= 2 ? 24 : 18, weight: .thin))
                .tracking(1.6)
                .foregroundColor(.white)
                .shadow(color: accent.opacity(0.9), radius: 16)

            HStack(spacing: 8) {
                Image(systemName: event.lineCount >= 2 ? "bolt.badge.clock.fill" : "plus")
                    .font(.system(size: 13, weight: .medium))

                Text("+\(event.totalPoints)")
                    .font(.app(size: 20, weight: .semibold))

                Text(event.subtitle)
                    .font(.app(size: 12, weight: .light))
                    .opacity(0.72)
            }
            .foregroundColor(.white)
            .padding(.vertical, 9)
            .padding(.horizontal, 14)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .fill(accent.opacity(glow ? 0.26 : 0.14))
                    )
            )
            .overlay(
                Capsule()
                    .stroke(accent.opacity(0.75), lineWidth: 1)
            )
        }
        .padding(.horizontal, 18)
        .offset(y: lift)
        .onAppear {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.76)) {
                lift = -8
            }

            withAnimation(.easeInOut(duration: 0.42).repeatCount(2, autoreverses: true)) {
                glow = true
            }
        }
    }

    private var accent: Color {
        event.player == .x ? DesignSystem.colors.accentBlue : DesignSystem.colors.accentPurple
    }
}

#Preview {
    GameplayView(navigationPath: .constant([]), mode: .vsAI)
}
