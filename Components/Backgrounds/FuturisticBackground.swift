import SwiftUI

struct FuturisticBackground: View {
    var glowOpacity: Double = 0.15
    var glowBlurRadius: CGFloat = 60

    var body: some View {
        ZStack {
            DesignSystem.colors.darkBg
                .ignoresSafeArea()

            RadialGradient(
                gradient: Gradient(colors: [
                    DesignSystem.colors.accentBlue.opacity(0.08),
                    DesignSystem.colors.darkBg
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 600
            )
            .ignoresSafeArea()

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
                .frame(width: 400, height: 400)
                .offset(y: -150)
                .blur(radius: glowBlurRadius)

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            DesignSystem.colors.accentBlue.opacity(glowOpacity * 0.67),
                            DesignSystem.colors.accentBlue.opacity(0.0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: 100, y: 200)
                .blur(radius: glowBlurRadius - 10)
        }
    }
}

#Preview {
    FuturisticBackground()
        .ignoresSafeArea()
}
