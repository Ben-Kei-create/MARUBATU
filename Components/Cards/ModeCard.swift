import SwiftUI

struct ModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.spacing.lg) {
                VStack(alignment: .leading, spacing: DesignSystem.spacing.sm) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DesignSystem.colors.textPrimary)
                        .tracking(0.3)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(DesignSystem.colors.textSecondary)
                }

                Spacer()

                VStack(spacing: 12) {
                    Circle()
                        .stroke(DesignSystem.colors.accentBlue, lineWidth: 2)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: icon)
                                .font(.system(size: 28, weight: .light))
                                .foregroundColor(DesignSystem.colors.accentBlue)
                        )

                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(DesignSystem.colors.accentBlue)
                }
            }
            .padding(DesignSystem.spacing.lg)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(DesignSystem.colors.glass)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        DesignSystem.colors.accentBlue.opacity(isPressed ? 0.8 : 0.4),
                        lineWidth: 1.5
                    )
                    .shadow(color: DesignSystem.colors.accentBlue.opacity(isPressed ? 0.4 : 0.1), radius: 12)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.01, perform: {}) { pressed in
            withAnimation(.easeInOut(duration: 0.1)) {
                self.isPressed = pressed
            }
        }
    }
}

#Preview {
    VStack(spacing: DesignSystem.spacing.lg) {
        ModeCard(
            icon: "cpu",
            title: "VS AI",
            subtitle: "Play against the computer",
            action: {}
        )

        ModeCard(
            icon: "person.2.fill",
            title: "2P Mode",
            subtitle: "Play with a friend",
            action: {}
        )
    }
    .padding(DesignSystem.spacing.lg)
    .background(DesignSystem.colors.darkBg)
    .ignoresSafeArea()
}
