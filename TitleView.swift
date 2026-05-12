import SwiftUI

struct TitleView: View {
    @State private var isPlayPressed = false
    @State private var isHowToPlayPressed = false
    @State private var showGlow = false

    var body: some View {
        ZStack {
            // Dark futuristic background with radial gradient
            FuturisticBackground()

            VStack(spacing: 0) {
                // Top spacer with settings icon
                HStack {
                    Spacer()
                    SettingsButton()
                        .padding(.trailing, DesignSystem.spacing.lg)
                        .padding(.top, DesignSystem.spacing.lg)
                }

                Spacer()
                    .frame(minHeight: 80)

                // Main content: Title and subtitle
                VStack(spacing: DesignSystem.spacing.md) {
                    Text("NEXUS")
                        .font(DesignSystem.typography.titleFont)
                        .tracking(2.5)
                        .foregroundColor(DesignSystem.colors.textPrimary)
                        .shadow(color: DesignSystem.colors.accentBlue.opacity(0.6), radius: 20)

                    Text("A new 4x5 strategy game")
                        .font(DesignSystem.typography.subtitleFont)
                        .tracking(0.8)
                        .foregroundColor(DesignSystem.colors.textSecondary)
                }
                .padding(.bottom, DesignSystem.spacing.xxl + 20)

                Spacer()

                // Buttons with glassmorphism
                VStack(spacing: DesignSystem.spacing.lg) {
                    // Primary button: Play
                    Button(action: { isPlayPressed = true }) {
                        Text("Play")
                            .font(DesignSystem.typography.buttonFont)
                            .tracking(0.5)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
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
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
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
                            .scaleEffect(isPlayPressed ? 0.96 : 1.0)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Secondary button: How to Play
                    Button(action: { isHowToPlayPressed = true }) {
                        Text("How to Play")
                            .font(DesignSystem.typography.buttonFont)
                            .tracking(0.5)
                            .foregroundColor(DesignSystem.colors.accentBlue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(DesignSystem.colors.glass)
                                    .backdrop()
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        DesignSystem.colors.accentBlue.opacity(0.4),
                                        lineWidth: 1.0
                                    )
                            )
                            .scaleEffect(isHowToPlayPressed ? 0.96 : 1.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, DesignSystem.spacing.lg)
                .padding(.bottom, DesignSystem.spacing.xxl + 10)
            }
        }
        .ignoresSafeArea()
    }
}

struct FuturisticBackground: View {
    var body: some View {
        ZStack {
            // Base dark color
            DesignSystem.colors.darkBg
                .ignoresSafeArea()

            // Radial gradient from center
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

            // Subtle animated glow orb (top-center offset)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            DesignSystem.colors.accentPurple.opacity(0.15),
                            DesignSystem.colors.accentPurple.opacity(0.0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 400, height: 400)
                .offset(y: -150)
                .blur(radius: 60)

            // Subtle animated glow orb (bottom-right offset)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            DesignSystem.colors.accentBlue.opacity(0.1),
                            DesignSystem.colors.accentBlue.opacity(0.0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: 100, y: 200)
                .blur(radius: 50)
        }
    }
}

struct SettingsButton: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 20, weight: .light))
                .foregroundColor(DesignSystem.colors.textSecondary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(DesignSystem.colors.glass)
                        .backdrop()
                )
                .overlay(
                    Circle()
                        .stroke(
                            DesignSystem.colors.textSecondary.opacity(0.2),
                            lineWidth: 0.5
                        )
                )
        }
    }
}

// Helper for glassmorphism effect
extension View {
    func backdrop() -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(14)
    }
}

#Preview {
    TitleView()
}
