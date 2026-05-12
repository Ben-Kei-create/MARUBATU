import SwiftUI

struct ParticleField: View {
    var particleCount: Int = 24
    var color: Color = DesignSystem.colors.accentBlue

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<particleCount, id: \.self) { idx in
                    Particle(
                        index: idx,
                        canvas: proxy.size,
                        color: color
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct Particle: View {
    let index: Int
    let canvas: CGSize
    let color: Color

    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 0

    private var size: CGFloat {
        CGFloat([2.0, 2.5, 3.0, 1.5, 2.0][index % 5])
    }

    private var xPosition: CGFloat {
        let seeds: [CGFloat] = [0.1, 0.25, 0.4, 0.55, 0.7, 0.85, 0.95, 0.15, 0.35, 0.5, 0.65, 0.8]
        return canvas.width * seeds[index % seeds.count]
    }

    private var duration: Double {
        let seeds: [Double] = [6, 8, 10, 7, 9, 11, 8.5]
        return seeds[index % seeds.count]
    }

    private var delay: Double {
        Double(index) * 0.3
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .shadow(color: color.opacity(0.8), radius: size * 1.5)
            .position(x: xPosition, y: canvas.height + 20)
            .offset(y: yOffset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.linear(duration: duration).delay(delay).repeatForever(autoreverses: false)) {
                    yOffset = -(canvas.height + 60)
                }
                withAnimation(.easeIn(duration: 0.6).delay(delay)) {
                    opacity = 0.6
                }
                Timer.scheduledTimer(withTimeInterval: duration, repeats: true) { _ in
                    withAnimation(.easeOut(duration: 0.4)) {
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeIn(duration: 0.6)) {
                            opacity = 0.6
                        }
                    }
                }
            }
    }
}

#Preview {
    ZStack {
        DesignSystem.colors.darkBg.ignoresSafeArea()
        ParticleField()
    }
}
