import SwiftUI

struct AdInterstitialView: View {
    @ObservedObject var adManager = AdManager.shared
    @ObservedObject var purchaseManager = PurchaseManager.shared
    @State private var canClose = false
    @State private var countdown = 5

    var body: some View {
        ZStack {
            Color.black.opacity(0.95).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if canClose {
                        Button(action: { adManager.dismissAd() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color.white.opacity(0.15)))
                        }
                    } else {
                        Text("\(countdown)")
                            .font(.app(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()

                VStack(spacing: 24) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        DesignSystem.colors.accentBlue.opacity(0.3),
                                        DesignSystem.colors.accentPurple.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 280, height: 280)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                DesignSystem.colors.accentBlue.opacity(0.6),
                                                DesignSystem.colors.accentPurple.opacity(0.6)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )

                        VStack(spacing: 12) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 48, weight: .thin))
                                .foregroundColor(DesignSystem.colors.accentBlue)

                            Text("NEXUS")
                                .font(.app(size: 32, weight: .thin))
                                .tracking(3)
                                .foregroundColor(.white)

                            Text("広告を非表示にして\n快適にプレイ")
                                .font(.app(size: 13, weight: .light))
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                    }

                    Text("広告")
                        .font(.app(size: 11, weight: .light))
                        .foregroundColor(.white.opacity(0.3))
                        .tracking(1)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button(action: {
                        Task { await purchaseManager.purchase() }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                            Text("広告を非表示")
                                .font(.app(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [
                                    DesignSystem.colors.accentBlue,
                                    DesignSystem.colors.accentPurple
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                    }

                    if canClose {
                        Button(action: { adManager.dismissAd() }) {
                            Text("続ける")
                                .font(.app(size: 15, weight: .light))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startCountdown()
        }
        .onChange(of: purchaseManager.isAdFree) { _, adFree in
            if adFree { adManager.dismissAd() }
        }
    }

    private func startCountdown() {
        countdown = 5
        canClose = false

        Task { @MainActor in
            for value in stride(from: 4, through: 0, by: -1) {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                countdown = value
            }

            canClose = true
        }
    }
}

#Preview {
    AdInterstitialView()
}
