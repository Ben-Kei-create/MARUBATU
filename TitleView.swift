import SwiftUI

struct TitleView: View {
    @Binding var navigationPath: [NavigationDestination]

    @AppStorage("hasSeenFirstPlayTutorial") private var hasSeenFirstPlayTutorial = false

    @State private var logoScale: CGFloat = 0.94
    @State private var logoGlow: Double = 0.5
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var subtitleOpacity: Double = 0
    @State private var subtitleOffset: CGFloat = 12
    @State private var buttonsOpacity: Double = 0
    @State private var buttonsOffset: CGFloat = 24
    @State private var gearOpacity: Double = 0

    var body: some View {
        ZStack {
            FuturisticBackground()
            ParticleField(particleCount: 18, color: DesignSystem.colors.accentBlue)

            VStack(spacing: 0) {
                // ── 上部ナビゲーション ──
                HStack {
                    Spacer()
                    IconButton(
                        iconName: "gearshape.fill",
                        action: { navigationPath.append(.settings) }
                    )
                    .opacity(gearOpacity)
                }
                .padding(.horizontal, DesignSystem.spacing.xl)
                .padding(.top, DesignSystem.spacing.lg)

                Spacer().frame(minHeight: 80)

                // ── ロゴ部分 ──
                VStack(spacing: DesignSystem.spacing.md) {
                    ZStack {
                        // 背景の脈動グロー
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        DesignSystem.colors.accentBlue.opacity(0.25 * logoGlow),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 180
                                )
                            )
                            .frame(width: 300, height: 300)
                            .blur(radius: 20)

                        VStack(spacing: 10) {
                            Text(L.appTitle)
                                .font(DesignSystem.typography.titleFont)
                                .tracking(2.5)
                                .foregroundColor(DesignSystem.colors.textPrimary)
                                .shadow(color: DesignSystem.colors.accentBlue.opacity(0.6 + 0.3 * logoGlow), radius: 18 + 6 * logoGlow)
                                .scaleEffect(logoScale)
                                .opacity(titleOpacity)
                                .offset(y: titleOffset)

                            // アンダーバーのグラデーション
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            DesignSystem.colors.accentBlue,
                                            DesignSystem.colors.accentPurple
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 90, height: 1.5)
                                .opacity(titleOpacity * 0.8)
                                .shadow(color: DesignSystem.colors.accentBlue.opacity(0.6), radius: 4)
                        }
                    }

                    Text(L.appSubtitle)
                        .font(DesignSystem.typography.subtitleFont)
                        .tracking(0.8)
                        .foregroundColor(DesignSystem.colors.textSecondary)
                        .opacity(subtitleOpacity)
                        .offset(y: subtitleOffset)
                }
                .padding(.bottom, DesignSystem.spacing.xxl + 20)

                Spacer()

                // ── ボタン群 ──
                VStack(spacing: DesignSystem.spacing.lg) {
                    GradientButton(
                        label: L.play,
                        action: startPlayFlow
                    )

                    GlassButton(
                        label: L.howToPlay,
                        action: { navigationPath.append(.howToPlay) }
                    )
                }
                .padding(.horizontal, DesignSystem.spacing.lg)
                .padding(.bottom, DesignSystem.spacing.xxl + 10)
                .opacity(buttonsOpacity)
                .offset(y: buttonsOffset)
            }
        }
        .onAppear {
            // 段階的なフェードイン
            withAnimation(.easeOut(duration: 0.6).delay(0.05)) {
                gearOpacity = 1
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
                logoScale = 1.0
                titleOpacity = 1
                titleOffset = 0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                subtitleOpacity = 1
                subtitleOffset = 0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.7)) {
                buttonsOpacity = 1
                buttonsOffset = 0
            }
            // ロゴの脈動グロー
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                logoGlow = 1.0
            }
        }
    }

    private func startPlayFlow() {
        if hasSeenFirstPlayTutorial {
            navigationPath.append(.modeSelection)
        } else {
            hasSeenFirstPlayTutorial = true
            navigationPath.append(.tutorial)
        }
    }
}

#Preview {
    TitleView(navigationPath: .constant([]))
}
