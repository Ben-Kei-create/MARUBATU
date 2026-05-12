import SwiftUI

enum CellMark {
    case empty
    case x
    case o
}

struct GameCell: View {
    let index: Int
    let mark: CellMark
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(
                        DesignSystem.colors.textSecondary.opacity(0.2),
                        lineWidth: 1
                    )
                    .background(
                        Circle()
                            .fill(DesignSystem.colors.glass)
                    )
                    .background(.ultraThinMaterial)
                    .frame(width: 72, height: 72)

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

                case .o:
                    Circle()
                        .stroke(DesignSystem.colors.accentPurple, lineWidth: 3)
                        .frame(width: 40, height: 40)
                        .shadow(color: DesignSystem.colors.accentPurple.opacity(0.8), radius: 12)

                case .empty:
                    EmptyView()
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.01, perform: {}) { pressed in
            withAnimation(.easeInOut(duration: 0.1)) {
                self.isPressed = pressed && mark == .empty
            }
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
