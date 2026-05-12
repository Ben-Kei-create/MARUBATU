import SwiftUI

struct FuturisticBackground: View {
    var glowOpacity: Double = 0.18
    var glowBlurRadius: CGFloat = 60
    var animated: Bool = true

    @State private var orbOffset1 = CGSize.zero
    @State private var orbOffset2 = CGSize.zero
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            DesignSystem.colors.darkBg
                .ignoresSafeArea()

            RadialGradient(
                gradient: Gradient(colors: [
                    DesignSystem.colors.accentBlue.opacity(0.10),
                    DesignSystem.colors.darkBg
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 600
            )
            .ignoresSafeArea()

            // ── 紫オーブ（上） ──
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            DesignSystem.colors.accentPurple.opacity(glowOpacity),
                            DesignSystem.colors.accentPurple.opacity(0.0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 420, height: 420)
                .offset(x: orbOffset1.width, y: -150 + orbOffset1.height)
                .scaleEffect(pulseScale)
                .blur(radius: glowBlurRadius)

            // ── 青オーブ（下） ──
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            DesignSystem.colors.accentBlue.opacity(glowOpacity * 0.85),
                            DesignSystem.colors.accentBlue.opacity(0.0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 280
                    )
                )
                .frame(width: 340, height: 340)
                .offset(x: 100 + orbOffset2.width, y: 200 + orbOffset2.height)
                .scaleEffect(2.0 - pulseScale)
                .blur(radius: glowBlurRadius - 8)

            // ── 装飾的なグリッドライン（微細） ──
            GridLinesOverlay()
                .opacity(0.04)
        }
        .onAppear {
            guard animated else { return }
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                orbOffset1 = CGSize(width: 60, height: 40)
            }
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                orbOffset2 = CGSize(width: -80, height: -50)
            }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                pulseScale = 1.08
            }
        }
    }
}

private struct GridLinesOverlay: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<8, id: \.self) { i in
                    Rectangle()
                        .fill(DesignSystem.colors.textSecondary)
                        .frame(width: 0.5)
                        .position(x: CGFloat(i) * (proxy.size.width / 7), y: proxy.size.height / 2)
                        .frame(height: proxy.size.height)
                }
                ForEach(0..<12, id: \.self) { i in
                    Rectangle()
                        .fill(DesignSystem.colors.textSecondary)
                        .frame(height: 0.5)
                        .position(x: proxy.size.width / 2, y: CGFloat(i) * (proxy.size.height / 11))
                        .frame(width: proxy.size.width)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    FuturisticBackground()
        .ignoresSafeArea()
}
