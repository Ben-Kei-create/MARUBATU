import SwiftUI

struct IconButton: View {
    let iconName: String
    let action: () -> Void
    var size: CGFloat = 20
    var backgroundColor: Color = DesignSystem.colors.glass
    var foregroundColor: Color = DesignSystem.colors.textSecondary
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: size, weight: .light))
                .foregroundColor(foregroundColor)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .fill(backgroundColor)
                        )
                )
                .overlay(
                    Circle()
                        .stroke(foregroundColor.opacity(0.2), lineWidth: 0.5)
                )
                .scaleEffect(isPressed ? 0.92 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.01, perform: {}) { pressed in
            self.isPressed = pressed
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        IconButton(iconName: "chevron.left", action: {})
        IconButton(iconName: "gearshape.fill", action: {})
        IconButton(iconName: "xmark", action: {})
    }
    .padding(24)
    .background(DesignSystem.colors.darkBg)
    .ignoresSafeArea()
}
