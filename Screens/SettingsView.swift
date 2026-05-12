import SwiftUI

struct SettingsView: View {
    @Binding var navigationPath: [NavigationDestination]
    @ObservedObject var purchaseManager = PurchaseManager.shared

    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true

    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

    var body: some View {
        ZStack {
            FuturisticBackground()

            VStack(spacing: 0) {
                // ── ナビゲーションバー ──
                HStack {
                    IconButton(
                        iconName: "chevron.left",
                        action: { navigationPath.removeLast() }
                    )
                    Spacer()
                    Text(String(localized: "Settings"))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignSystem.colors.textPrimary)
                        .tracking(0.5)
                    Spacer()
                    // バランス用
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, DesignSystem.spacing.lg)
                .padding(.vertical, DesignSystem.spacing.md)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DesignSystem.spacing.lg) {

                        // ── サウンド・バイブ ──
                        SettingsSectionView(title: String(localized: "Sound & Feedback")) {
                            SettingsToggleRow(
                                icon: "speaker.wave.2.fill",
                                label: String(localized: "Sound Effects"),
                                isOn: $soundEnabled
                            )
                            Divider()
                                .background(DesignSystem.colors.textSecondary.opacity(0.15))
                            SettingsToggleRow(
                                icon: "iphone.radiowaves.left.and.right",
                                label: String(localized: "Vibration"),
                                isOn: $vibrationEnabled
                            )
                        }

                        // ── 広告・購入 ──
                        SettingsSectionView(title: String(localized: "Purchase")) {
                            if purchaseManager.isAdFree {
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 18, weight: .light))
                                        .foregroundColor(DesignSystem.colors.accentBlue)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(String(localized: "Ad-Free Purchased"))
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(DesignSystem.colors.textPrimary)
                                        Text(String(localized: "Enjoy uninterrupted gameplay"))
                                            .font(.system(size: 12, weight: .light))
                                            .foregroundColor(DesignSystem.colors.textSecondary)
                                    }
                                    Spacer()
                                }
                                .padding(DesignSystem.spacing.md)
                            } else {
                                Button(action: {
                                    Task { await purchaseManager.purchase() }
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 18, weight: .light))
                                            .foregroundColor(DesignSystem.colors.accentBlue)
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(String(localized: "Remove All Ads"))
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(DesignSystem.colors.textPrimary)
                                            Text(String(localized: "One-time purchase"))
                                                .font(.system(size: 12, weight: .light))
                                                .foregroundColor(DesignSystem.colors.textSecondary)
                                        }
                                        Spacer()
                                        if purchaseManager.isLoading {
                                            ProgressView()
                                                .tint(DesignSystem.colors.accentBlue)
                                        } else {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 13, weight: .light))
                                                .foregroundColor(DesignSystem.colors.textSecondary)
                                        }
                                    }
                                    .padding(DesignSystem.spacing.md)
                                }
                                .disabled(purchaseManager.isLoading)

                                Divider()
                                    .background(DesignSystem.colors.textSecondary.opacity(0.15))

                                Button(action: {
                                    Task { await purchaseManager.restore() }
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 18, weight: .light))
                                            .foregroundColor(DesignSystem.colors.textSecondary)
                                        Text(String(localized: "Restore Purchase"))
                                            .font(.system(size: 14, weight: .light))
                                            .foregroundColor(DesignSystem.colors.textSecondary)
                                        Spacer()
                                    }
                                    .padding(DesignSystem.spacing.md)
                                }
                                .disabled(purchaseManager.isLoading)
                            }

                            if let error = purchaseManager.errorMessage {
                                Text(error)
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.red.opacity(0.8))
                                    .padding(.horizontal, DesignSystem.spacing.md)
                                    .padding(.bottom, DesignSystem.spacing.sm)
                            }
                        }

                        // ── 言語 ──
                        SettingsSectionView(title: String(localized: "Language")) {
                            HStack(spacing: 12) {
                                Image(systemName: "globe")
                                    .font(.system(size: 18, weight: .light))
                                    .foregroundColor(DesignSystem.colors.textSecondary)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(String(localized: "App Language"))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(DesignSystem.colors.textPrimary)
                                    Text(String(localized: "Change in iOS Settings → NEXUS"))
                                        .font(.system(size: 12, weight: .light))
                                        .foregroundColor(DesignSystem.colors.textSecondary)
                                }
                                Spacer()
                                Button(action: {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Text(String(localized: "Open"))
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(DesignSystem.colors.accentBlue)
                                }
                            }
                            .padding(DesignSystem.spacing.md)
                        }

                        // ── アプリ情報 ──
                        SettingsSectionView(title: String(localized: "About")) {
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 18, weight: .light))
                                    .foregroundColor(DesignSystem.colors.textSecondary)
                                Text(String(localized: "Version"))
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(DesignSystem.colors.textPrimary)
                                Spacer()
                                Text(appVersion)
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(DesignSystem.colors.textSecondary)
                            }
                            .padding(DesignSystem.spacing.md)

                            Divider()
                                .background(DesignSystem.colors.textSecondary.opacity(0.15))

                            Button(action: {}) {
                                HStack(spacing: 12) {
                                    Image(systemName: "hand.raised")
                                        .font(.system(size: 18, weight: .light))
                                        .foregroundColor(DesignSystem.colors.textSecondary)
                                    Text(String(localized: "Privacy Policy"))
                                        .font(.system(size: 14, weight: .light))
                                        .foregroundColor(DesignSystem.colors.textPrimary)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 13, weight: .light))
                                        .foregroundColor(DesignSystem.colors.textSecondary)
                                }
                                .padding(DesignSystem.spacing.md)
                            }

                            Divider()
                                .background(DesignSystem.colors.textSecondary.opacity(0.15))

                            Button(action: {}) {
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 18, weight: .light))
                                        .foregroundColor(DesignSystem.colors.textSecondary)
                                    Text(String(localized: "Terms of Service"))
                                        .font(.system(size: 14, weight: .light))
                                        .foregroundColor(DesignSystem.colors.textPrimary)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 13, weight: .light))
                                        .foregroundColor(DesignSystem.colors.textSecondary)
                                }
                                .padding(DesignSystem.spacing.md)
                            }
                        }

                        Text("NEXUS © 2025")
                            .font(.system(size: 11, weight: .light))
                            .foregroundColor(DesignSystem.colors.textSecondary.opacity(0.4))
                            .padding(.bottom, DesignSystem.spacing.xl)
                    }
                    .padding(DesignSystem.spacing.lg)
                }
            }
        }
        .ignoresSafeArea()
    }
}

// ── セクションコンテナ ──
private struct SettingsSectionView<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing.sm) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DesignSystem.colors.textSecondary)
                .tracking(0.5)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(DesignSystem.colors.glass)
                    .background(.ultraThinMaterial)
                    .cornerRadius(14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(DesignSystem.colors.textSecondary.opacity(0.15), lineWidth: 0.5)
            )
        }
    }
}

// ── トグル行 ──
private struct SettingsToggleRow: View {
    let icon: String
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .light))
                .foregroundColor(isOn ? DesignSystem.colors.accentBlue : DesignSystem.colors.textSecondary)
                .frame(width: 24)
            Text(label)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(DesignSystem.colors.textPrimary)
            Spacer()
            Toggle("", isOn: $isOn)
                .tint(DesignSystem.colors.accentBlue)
        }
        .padding(DesignSystem.spacing.md)
    }
}

#Preview {
    SettingsView(navigationPath: .constant([]))
}
