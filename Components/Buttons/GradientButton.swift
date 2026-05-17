import SwiftUI

struct GradientButton: View {
    let label: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(DesignSystem.typography.buttonFont)
                .tracking(0.5)
                .foregroundColor(.white)
                .frame(maxWidth: 286)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            DesignSystem.colors.accentBlue,
                            DesignSystem.colors.accentPurple
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(13)
                .overlay(
                    RoundedRectangle(cornerRadius: 13)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    DesignSystem.colors.accentBlue.opacity(0.8),
                                    DesignSystem.colors.accentPurple.opacity(0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
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
        GradientButton(label: "Play", action: {})
        GradientButton(label: "Got It", action: {})
    }
    .padding(24)
    .background(DesignSystem.colors.darkBg)
    .ignoresSafeArea()
}
