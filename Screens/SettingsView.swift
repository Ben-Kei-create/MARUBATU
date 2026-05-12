import SwiftUI

struct SettingsView: View {
    @Binding var navigationPath: [NavigationDestination]
    @ObservedObject var purchaseManager = PurchaseManager.shared

    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true

    @State private var headerOpacity: Double = 0
    @State private var headerOffset: CGFloat = -8
    @State private var section1Opacity: Double = 0
    @State private var section2Opacity: Double = 0
    @State private var section3Opacity: Double = 0
    @State private var section4Opacity: Double = 0
    @State private var sectionsOffset: CGFloat = 24
    @State private var purchaseHighlight: Bool = false

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
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, DesignSystem.spacing.lg)
                .padding(.vertical, DesignSystem.spacing.md)
                .opacity(headerOpacity)
                .offset(y: headerOffset)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DesignSystem.spacing.lg) {

                        // ── サウンド・バイブ ──
                        SettingsSectionView(title: String(localized: "Sound & Feedback")) {
                            SettingsToggleRow(
                                icon: "speaker.wave.2.fill",
                                label: String(localized: "Sound Effects"),
                                isOn: $soundEnabled
                            )
                            SectionDivider()
                            SettingsToggleRow(
                                icon: "iphone.radiowaves.left.and.right",
                                label: String(localized: "Vibration"),
                                isOn: $vibrationEnabled
                            )
                        }
                        .opacity(section1Opacity)
                        .offset(y: section1Opacity == 0 ? sectionsOffset : 0)

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
                                        ZStack {
                                            Circle()
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
                                                .frame(width: 32, height: 32)
                                                .scaleEffect(purchaseHighlight ? 1.1 : 1.0)
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 14, weight: .light))
                                                .foregroundColor(DesignSystem.colors.accentBlue)
                                        }
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

                                SectionDivider()

                                Button(action: {
                                    Task { await purchaseManager.restore() }
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 16, weight: .light))
                                            .foregroundColor(DesignSystem.colors.textSecondary)
                                            .frame(width: 32, height: 32)
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
                        .opacity(section2Opacity)
                        .offset(y: section2Opacity == 0 ? sectionsOffset : 0)

                        // ── 言語 ──
                        SettingsSectionView(title: String(localized: "Language")) {
                            HStack(spacing: 12) {
                                Image(systemName: "globe")
                                    .font(.system(size: 18, weight: .light))
                                    .foregroundColor(DesignSystem.colors.textSecondary)
                                    .frame(width: 32, height: 32)
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
                        .opacity(section3Opacity)
                        .offset(y: section3Opacity == 0 ? sectionsOffset : 0)

                        // ── アプリ情報 ──
                        SettingsSectionView(title: String(localized: "About")) {
                            SettingsInfoRow(
                                icon: "info.circle",
                                label: String(localized: "Version"),
                                value: appVersion
                            )
                            SectionDivider()
                            SettingsLinkRow(
                                icon: "hand.raised",
                                label: String(localized: "Privacy Policy")
                            )
                            SectionDivider()
                            SettingsLinkRow(
                                icon: "doc.text",
                                label: String(localized: "Terms of Service")
                            )
                        }
                        .opacity(section4Opacity)
                        .offset(y: section4Opacity == 0 ? sectionsOffset : 0)

                        Text("NEXUS © 2025")
                            .font(.system(size: 11, weight: .light))
                            .foregroundColor(DesignSystem.colors.textSecondary.opacity(0.4))
                            .padding(.top, DesignSystem.spacing.sm)
                            .padding(.bottom, DesignSystem.spacing.xl)
                            .opacity(section4Opacity)
                    }
                    .padding(DesignSystem.spacing.lg)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { animateIn() }
    }

    private func animateIn() {
        withAnimation(.easeOut(duration: 0.4)) {
            headerOpacity = 1
            headerOffset = 0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.10)) {
            section1Opacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.20)) {
            section2Opacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.30)) {
            section3Opacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.40)) {
            section4Opacity = 1
        }
        // 購入ボタンの強調パルス
        if !purchaseManager.isAdFree {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true).delay(1.0)) {
                purchaseHighlight = true
            }
        }
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
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DesignSystem.colors.textSecondary)
                .tracking(0.8)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(DesignSystem.colors.glass)
            )
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DesignSystem.colors.textSecondary.opacity(0.12), lineWidth: 0.5)
            )
        }
    }
}

// ── 仕切り線 ──
private struct SectionDivider: View {
    var body: some View {
        Rectangle()
            .fill(DesignSystem.colors.textSecondary.opacity(0.12))
            .frame(height: 0.5)
            .padding(.leading, DesignSystem.spacing.md + 32 + 12)
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
                .font(.system(size: 16, weight: .light))
                .foregroundColor(isOn ? DesignSystem.colors.accentBlue : DesignSystem.colors.textSecondary)
                .frame(width: 32, height: 32)
                .animation(.easeInOut(duration: 0.2), value: isOn)
            Text(label)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(DesignSystem.colors.textPrimary)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(DesignSystem.colors.accentBlue)
        }
        .padding(DesignSystem.spacing.md)
    }
}

// ── 情報行 ──
private struct SettingsInfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .light))
                .foregroundColor(DesignSystem.colors.textSecondary)
                .frame(width: 32, height: 32)
            Text(label)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(DesignSystem.colors.textPrimary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(DesignSystem.colors.textSecondary)
        }
        .padding(DesignSystem.spacing.md)
    }
}

// ── リンク行 ──
private struct SettingsLinkRow: View {
    let icon: String
    let label: String

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(DesignSystem.colors.textSecondary)
                    .frame(width: 32, height: 32)
                Text(label)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(DesignSystem.colors.textPrimary)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(DesignSystem.colors.textSecondary)
            }
            .padding(DesignSystem.spacing.md)
        }
    }
}

#Preview {
    SettingsView(navigationPath: .constant([]))
}
