import SwiftUI

struct ModeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.spacing.md) {
                VStack(alignment: .leading, spacing: DesignSystem.spacing.sm) {
                    Text(title)
                        .font(.app(size: 17, weight: .medium))
                        .foregroundColor(DesignSystem.colors.textPrimary)
                        .tracking(0.3)

                    Text(subtitle)
                        .font(.app(size: 14, weight: .light))
                        .foregroundColor(DesignSystem.colors.textSecondary)
                }

                Spacer()

                VStack(spacing: 10) {
                    Circle()
                        .stroke(DesignSystem.colors.accentBlue, lineWidth: 2)
                        .frame(width: 54, height: 54)
                        .overlay(
                            Image(systemName: icon)
                                .font(.system(size: 23, weight: .light))
                                .foregroundColor(DesignSystem.colors.accentBlue)
                        )

                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(DesignSystem.colors.accentBlue)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(height: 112)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(DesignSystem.colors.glass)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
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
