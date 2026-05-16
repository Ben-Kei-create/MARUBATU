import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum CellMark {
    case empty
    case x
    case o
}

struct GameCell: View {
    let index: Int
    let mark: CellMark
    let isSelected: Bool
    var isHighlighted: Bool = false
    var isFrozen: Bool = false
    var size: CGFloat = 72
    let action: () -> Void
    @State private var isPressed = false
    @State private var markScale: CGFloat = 1
    @State private var rippleScale: CGFloat = 0.84
    @State private var rippleOpacity: Double = 0

    var body: some View {
        Button(action: handleTap) {
            ZStack {
                Circle()
                    .fill(DesignSystem.colors.darkBgSecondary.opacity(mark == .empty ? 0.7 : 0.86))
                    .overlay(
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        markAccent.opacity(mark == .empty ? 0.12 : 0.28),
                                        DesignSystem.colors.textSecondary.opacity(mark == .empty ? 0.07 : 0.03),
                                        DesignSystem.colors.glass.opacity(0.68),
                                        Color.black.opacity(0.22)
                                    ],
                                    center: .center,
                                    startRadius: 1,
                                    endRadius: size * 0.62
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                AngularGradient(
                                    colors: [
                                        ringColor.opacity(0.18),
                                        ringColor.opacity(0.92),
                                        DesignSystem.colors.textPrimary.opacity(isHighlighted ? 0.55 : 0.18),
                                        ringColor.opacity(0.34),
                                        ringColor.opacity(0.18)
                                    ],
                                    center: .center
                                ),
                                lineWidth: ringWidth
                            )
                    )
                    .shadow(color: ringColor.opacity(isHighlighted ? 0.82 : glowOpacity), radius: isHighlighted ? 22 : 11)
                    .shadow(color: markAccent.opacity(mark == .empty ? 0.16 : 0.28), radius: mark == .empty ? 9 : 18)
                    .frame(width: size, height: size)

                CellTicks(color: ringColor, size: size, isActive: mark != .empty || isHighlighted || isSelected)

                Circle()
                    .stroke(markAccent.opacity(mark == .empty ? 0.28 : 0.74), lineWidth: 2)
                    .frame(width: size, height: size)
                    .scaleEffect(rippleScale)
                    .opacity(rippleOpacity)

                if isSelected {
                    Circle()
                        .stroke(DesignSystem.colors.accentBlue, lineWidth: 2)
                        .frame(width: size + 4, height: size + 4)
                        .shadow(color: DesignSystem.colors.accentBlue.opacity(0.6), radius: 8)
                }

                switch mark {
                case .x:
                    NeonXMark(size: size, color: DesignSystem.colors.accentBlue)
                        .scaleEffect(markScale)
                        .transition(.scale(scale: 0.3).combined(with: .opacity))

                case .o:
                    NeonOMark(size: size, color: DesignSystem.colors.accentPurple)
                        .scaleEffect(markScale)
                        .transition(.scale(scale: 0.3).combined(with: .opacity))

                case .empty:
                    EmptyView()
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: mark)
        }
        .disabled(isFrozen)
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.01, perform: {}) { pressed in
            withAnimation(.easeInOut(duration: 0.1)) {
                self.isPressed = pressed && mark == .empty && !isFrozen
            }
        }
        .onChange(of: mark) { _, newMark in
            guard newMark != .empty else { return }
            playPlacementAnimation()
        }
    }

    private var ringColor: Color {
        if isFrozen {
            return DesignSystem.colors.accentPurple.opacity(0.55)
        }

        if isHighlighted {
            return mark == .o
                ? DesignSystem.colors.accentPurple.opacity(0.92)
                : DesignSystem.colors.accentBlue.opacity(0.92)
        }

        return mark == .empty
            ? DesignSystem.colors.accentBlue.opacity(0.42)
            : DesignSystem.colors.textSecondary.opacity(0.26)
    }

    private var ringWidth: CGFloat {
        if isHighlighted || isFrozen {
            return 1.8
        }

        return mark == .empty ? 1.45 : 1.15
    }

    private var glowOpacity: Double {
        switch mark {
        case .empty:
            0.18
        case .x, .o:
            0.52
        }
    }

    private var markAccent: Color {
        switch mark {
        case .x:
            return DesignSystem.colors.accentBlue
        case .o:
            return DesignSystem.colors.accentPurple
        case .empty:
            return isHighlighted ? DesignSystem.colors.accentBlue : DesignSystem.colors.textSecondary
        }
    }

    private func handleTap() {
        guard !isFrozen else { return }

        #if canImport(UIKit)
        if mark == .empty {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        #endif

        action()
    }

    private func playPlacementAnimation() {
        markScale = 0.24
        rippleScale = 0.82
        rippleOpacity = 0.9

        withAnimation(.spring(response: 0.28, dampingFraction: 0.58)) {
            markScale = 1
        }

        withAnimation(.easeOut(duration: 0.38)) {
            rippleScale = 1.46
            rippleOpacity = 0
        }
    }
}

private struct CellTicks: View {
    let color: Color
    let size: CGFloat
    let isActive: Bool

    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(color.opacity(isActive ? 0.72 : 0.34))
                    .frame(width: 1.1, height: size * 0.075)
                    .offset(y: -size * 0.5)
                    .rotationEffect(.degrees(Double(index) * 90))
            }

            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(color.opacity(isActive ? 0.34 : 0.18))
                    .frame(width: 1, height: size * 0.08)
                    .offset(y: -size * 0.61)
                    .rotationEffect(.degrees(45 + Double(index) * 90))
            }
        }
        .shadow(color: color.opacity(isActive ? 0.52 : 0.16), radius: isActive ? 5 : 2)
    }
}

private struct NeonXMark: View {
    let size: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            xBars
                .opacity(0.48)
                .blur(radius: 8)
                .shadow(color: color.opacity(0.95), radius: 18)

            xBars
                .shadow(color: color.opacity(0.95), radius: 12)
                .shadow(color: .white.opacity(0.45), radius: 4)
        }
    }

    private var xBars: some View {
        ZStack {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.92), color, color.opacity(0.82)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: size * 0.62, height: max(3.4, size * 0.06))
                .rotationEffect(.degrees(45))

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.82), color, .white.opacity(0.9)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: size * 0.62, height: max(3.4, size * 0.06))
                .rotationEffect(.degrees(-45))
        }
    }
}

private struct NeonOMark: View {
    let size: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.32), lineWidth: size * 0.14)
                .frame(width: size * 0.56, height: size * 0.56)
                .blur(radius: 9)

            Circle()
                .stroke(color.opacity(0.94), lineWidth: max(4.2, size * 0.07))
                .frame(width: size * 0.56, height: size * 0.56)
                .shadow(color: color.opacity(0.95), radius: 14)

            Circle()
                .stroke(.white.opacity(0.68), lineWidth: 1.4)
                .frame(width: size * 0.56, height: size * 0.56)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 12) {
            GameCell(index: 0, mark: .empty, isSelected: false, action: {})
            GameCell(index: 1, mark: .x, isSelected: false, action: {})
            GameCell(index: 2, mark: .o, isSelected: false, action: {})
            GameCell(index: 3, mark: .empty, isSelected: true, action: {})
        }
    }
    .padding(24)
    .background(DesignSystem.colors.darkBg)
    .ignoresSafeArea()
}
