import SwiftUI

struct StoreView: View {
    @Binding var navigationPath: [NavigationDestination]
    @ObservedObject private var purchaseManager = PurchaseManager.shared

    var body: some View {
        ZStack {
            FuturisticBackground()

            VStack(spacing: 0) {
                HStack {
                    IconButton(
                        iconName: "chevron.left",
                        action: { navigationPath.removeLast() }
                    )

                    Spacer()

                    Text("STORE")
                        .font(.app(size: 15, weight: .medium))
                        .foregroundColor(DesignSystem.colors.textPrimary)
                        .tracking(3.2)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, DesignSystem.spacing.xl)
                .padding(.vertical, DesignSystem.spacing.md)

                Spacer(minLength: 30)

                VStack(spacing: 22) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        DesignSystem.colors.accentBlue.opacity(0.28),
                                        DesignSystem.colors.accentPurple.opacity(0.14),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 4,
                                    endRadius: 120
                                )
                            )
                            .frame(width: 190, height: 190)
                            .blur(radius: 8)

                        Image(systemName: purchaseManager.isAdFree ? "checkmark.seal.fill" : "bolt.slash.fill")
                            .font(.system(size: 54, weight: .thin))
                            .foregroundColor(DesignSystem.colors.accentBlue)
                            .shadow(color: DesignSystem.colors.accentBlue.opacity(0.65), radius: 18)
                    }
                    .frame(height: 154)

                    VStack(spacing: 8) {
                        Text(purchaseManager.isAdFree ? "UNLOCKED" : purchaseManager.purchaseTitle)
                            .font(.app(size: 26, weight: .light))
                            .foregroundColor(DesignSystem.colors.textPrimary)
                            .tracking(3.4)
                            .multilineTextAlignment(.center)

                        Text(purchaseManager.purchaseDescription)
                            .font(.app(size: 13, weight: .light))
                            .foregroundColor(DesignSystem.colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .frame(maxWidth: 270)
                    }

                    VStack(spacing: 10) {
                        StoreBenefitRow(icon: "eye.slash", text: "ゲーム後の広告を非表示")
                        StoreBenefitRow(icon: "sparkles", text: "フッターの没入感を維持")
                        StoreBenefitRow(icon: "arrow.clockwise", text: "購入復元に対応")
                    }
                    .frame(width: 286)

                    VStack(spacing: 12) {
                        if purchaseManager.isAdFree {
                            StoreStatusPill(text: "購入済み", icon: "checkmark")
                        } else {
                            StorePurchaseButton(
                                price: purchaseManager.purchasePrice,
                                isLoading: purchaseManager.isLoading,
                                isUnavailable: purchaseManager.productLoadFailed,
                                action: {
                                    Task { await purchaseManager.purchase() }
                                }
                            )

                            Button(action: {
                                Task { await purchaseManager.restore() }
                            }) {
                                Text("RESTORE")
                                    .font(.app(size: 11, weight: .light))
                                    .tracking(2.2)
                                    .foregroundColor(DesignSystem.colors.textSecondary)
                                    .frame(width: 156, height: 36)
                                    .background(
                                        Capsule()
                                            .stroke(DesignSystem.colors.textSecondary.opacity(0.22), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(purchaseManager.isLoading)
                        }

                        if let message = purchaseManager.purchaseMessage {
                            Text(message)
                                .font(.app(size: 12, weight: .light))
                                .foregroundColor(DesignSystem.colors.accentBlue)
                                .multilineTextAlignment(.center)
                        }

                        if let error = purchaseManager.errorMessage {
                            Text(error)
                                .font(.app(size: 12, weight: .light))
                                .foregroundColor(.red.opacity(0.82))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 286)
                        }
                    }

                    HStack(spacing: 18) {
                        Button("PRIVACY") {
                            navigationPath.append(.legal(kind: .privacyPolicy))
                        }

                        Button("TERMS") {
                            navigationPath.append(.legal(kind: .termsOfUse))
                        }
                    }
                    .font(.app(size: 10, weight: .light))
                    .tracking(2.0)
                    .foregroundColor(DesignSystem.colors.textSecondary.opacity(0.72))
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxWidth: 330)
                .padding(.horizontal, DesignSystem.spacing.lg)

                Spacer(minLength: 36)
            }
        }
        .task {
            await purchaseManager.refreshProducts()
            await purchaseManager.refreshPurchasedProducts()
        }
    }
}

private struct StoreBenefitRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .light))
                .foregroundColor(DesignSystem.colors.accentBlue)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(DesignSystem.colors.accentBlue.opacity(0.1))
                )

            Text(text)
                .font(.app(size: 13, weight: .light))
                .foregroundColor(DesignSystem.colors.textSecondary)

            Spacer()
        }
    }
}

private struct StorePurchaseButton: View {
    let price: String
    let isLoading: Bool
    let isUnavailable: Bool
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .semibold))
                }

                Text(isUnavailable ? "UNAVAILABLE" : "BUY \(price)")
                    .font(.app(size: 13, weight: .medium))
                    .tracking(2.5)
            }
            .foregroundColor(.white)
            .frame(width: 224, height: 48)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.colors.accentBlue,
                                DesignSystem.colors.accentPurple
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(isUnavailable ? 0.45 : 1)
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.28), lineWidth: 0.8)
            )
            .shadow(color: DesignSystem.colors.accentBlue.opacity(isUnavailable ? 0.0 : 0.36), radius: 18, y: 8)
            .scaleEffect(isPressed ? 0.96 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading || isUnavailable)
        .onLongPressGesture(minimumDuration: 0.01, perform: {}) { pressed in
            isPressed = pressed
        }
    }
}

private struct StoreStatusPill: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))

            Text(text)
                .font(.app(size: 13, weight: .medium))
                .tracking(2.4)
        }
        .foregroundColor(DesignSystem.colors.accentBlue)
        .frame(width: 186, height: 44)
        .background(
            Capsule()
                .fill(DesignSystem.colors.accentBlue.opacity(0.09))
        )
        .overlay(
            Capsule()
                .stroke(DesignSystem.colors.accentBlue.opacity(0.28), lineWidth: 1)
        )
    }
}

#Preview {
    StoreView(navigationPath: .constant([]))
}
