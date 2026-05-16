import SwiftUI

struct SplashView: View {
    var onFinish: () -> Void

    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.3
    @State private var ringOpacity: Double = 0
    @State private var glowOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var subtitleOffset: CGFloat = 12
    @State private var exitOpacity: Double = 1

    var body: some View {
        ZStack {
            DesignSystem.colors.darkBg
                .ignoresSafeArea()

            // ── 中央のグロー ──
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            DesignSystem.colors.accentBlue.opacity(0.35),
                            DesignSystem.colors.accentPurple.opacity(0.15),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .opacity(glowOpacity)
                .blur(radius: 30)

            VStack(spacing: 24) {
                // ── 同心円リング ──
                ZStack {
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        DesignSystem.colors.accentBlue.opacity(0.6),
                                        DesignSystem.colors.accentPurple.opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .frame(width: 120 + CGFloat(i) * 40, height: 120 + CGFloat(i) * 40)
                            .scaleEffect(ringScale)
                            .opacity(ringOpacity * (1.0 - Double(i) * 0.25))
                    }

                    // ── ロゴ ──
                    VStack(spacing: 6) {
                        Text("NEXUS")
                            .font(.app(size: 44, weight: .thin))
                            .tracking(3)
                            .foregroundColor(DesignSystem.colors.textPrimary)
                            .shadow(color: DesignSystem.colors.accentBlue.opacity(0.8), radius: 16)
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)

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
                            .frame(width: 60 * logoScale, height: 1)
                            .opacity(logoOpacity)
                    }
                }

                Text(L.appSubtitle)
                    .font(.app(size: 13, weight: .light))
                    .tracking(0.6)
                    .foregroundColor(DesignSystem.colors.textSecondary)
                    .opacity(subtitleOpacity)
                    .offset(y: subtitleOffset)
                    .padding(.top, 40)
            }
        }
        .opacity(exitOpacity)
        .onAppear {
            // リングの拡大
            withAnimation(.easeOut(duration: 1.4)) {
                ringScale = 1.0
                ringOpacity = 0.6
            }
            // グローの登場
            withAnimation(.easeInOut(duration: 1.2)) {
                glowOpacity = 1.0
            }
            // ロゴの登場
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            // サブタイトルの登場
            withAnimation(.easeOut(duration: 0.8).delay(0.9)) {
                subtitleOpacity = 1.0
                subtitleOffset = 0
            }
            // リング消失
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeIn(duration: 0.5)) {
                    ringOpacity = 0
                }
            }
            // フェードアウト → 終了
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    exitOpacity = 0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                onFinish()
            }
        }
    }
}

#Preview {
    SplashView(onFinish: {})
}
