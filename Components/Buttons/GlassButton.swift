import SwiftUI

struct GlassButton: View {
    let label: String
    let action: () -> Void
    var textColor: Color = DesignSystem.colors.accentBlue
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(DesignSystem.typography.buttonFont)
                .tracking(0.5)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(DesignSystem.colors.glass)
                        .backdrop(cornerRadius: 14)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(textColor.opacity(0.4), lineWidth: 1.0)
                )
                .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.01, perform: {}) { pressed in
            self.isPressed = pressed
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        GlassButton(label: "How to Play", action: {})
        GlassButton(label: "Back", action: {}, textColor: DesignSystem.colors.textSecondary)
    }
    .padding(24)
    .background(DesignSystem.colors.darkBg)
    .ignoresSafeArea()
}
