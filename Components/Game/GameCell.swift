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
    let action: () -> Void
    @State private var isPressed = false
    @State private var markScale: CGFloat = 1
    @State private var rippleScale: CGFloat = 0.84
    @State private var rippleOpacity: Double = 0

    var body: some View {
        Button(action: handleTap) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .fill(cellFill)
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                ringColor,
                                lineWidth: isHighlighted || isFrozen ? 1.6 : 1
                            )
                    )
                    .shadow(color: ringColor.opacity(isHighlighted ? 0.5 : 0.18), radius: isHighlighted ? 12 : 3)
                    .frame(width: 72, height: 72)

                Circle()
                    .stroke(markAccent.opacity(0.7), lineWidth: 2)
                    .frame(width: 72, height: 72)
                    .scaleEffect(rippleScale)
                    .opacity(rippleOpacity)

                if isSelected {
                    Circle()
                        .stroke(DesignSystem.colors.accentBlue, lineWidth: 2)
                        .frame(width: 76, height: 76)
                        .shadow(color: DesignSystem.colors.accentBlue.opacity(0.6), radius: 8)
                }

                switch mark {
                case .x:
                    Text("X")
                        .font(.system(size: 32, weight: .thin))
                        .foregroundColor(DesignSystem.colors.accentBlue)
                        .shadow(color: DesignSystem.colors.accentBlue.opacity(0.8), radius: 12)
                        .scaleEffect(markScale)
                        .transition(.scale(scale: 0.3).combined(with: .opacity))

                case .o:
                    Circle()
                        .stroke(DesignSystem.colors.accentPurple, lineWidth: 3)
                        .frame(width: 40, height: 40)
                        .shadow(color: DesignSystem.colors.accentPurple.opacity(0.8), radius: 12)
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

    private var cellFill: Color {
        if isFrozen {
            return DesignSystem.colors.accentPurple.opacity(0.14)
        }

        if isHighlighted {
            return DesignSystem.colors.accentBlue.opacity(0.18)
        }

        return DesignSystem.colors.glass
    }

    private var ringColor: Color {
        if isFrozen {
            return DesignSystem.colors.accentPurple.opacity(0.55)
        }

        if isHighlighted {
            return DesignSystem.colors.accentBlue.opacity(0.8)
        }

        return DesignSystem.colors.textSecondary.opacity(0.2)
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
