import SwiftUI

struct SkillTargetSelectionView: View {
    @Binding var navigationPath: [NavigationDestination]
    let skillName: String
    @State private var selectedTarget: String?

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
                }
                .padding(DesignSystem.spacing.lg)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Skill: \(skillName)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.colors.textPrimary)
                        .tracking(0.3)

                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 11, weight: .light))
                            .foregroundColor(DesignSystem.colors.accentBlue)

                        Text("3")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DesignSystem.colors.textPrimary)
                    }
                }
                .padding(.horizontal, DesignSystem.spacing.lg)
                .padding(.vertical, DesignSystem.spacing.md)

                Text("Select a target line")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(DesignSystem.colors.textSecondary)
                    .padding(.horizontal, DesignSystem.spacing.lg)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: DesignSystem.spacing.lg) {
                        VStack(alignment: .leading, spacing: DesignSystem.spacing.md) {
                            Text("Horizontal Lines")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(DesignSystem.colors.textSecondary)
                                .tracking(0.3)
                                .padding(.horizontal, DesignSystem.spacing.lg)

                            VStack(spacing: 8) {
                                ForEach(0..<5, id: \.self) { row in
                                    Button(action: { selectedTarget = "h\(row)" }) {
                                        Text("Row \(row + 1)")
                                            .font(.system(size: 13, weight: .light))
                                            .foregroundColor(
                                                selectedTarget == "h\(row)"
                                                    ? .white
                                                    : DesignSystem.colors.accentBlue
                                            )
                                            .frame(maxWidth: .infinity)
                                            .padding(DesignSystem.spacing.sm)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(
                                                        selectedTarget == "h\(row)"
                                                            ? DesignSystem.colors.accentBlue
                                                            : Color.clear
                                                    )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(
                                                        DesignSystem.colors.accentBlue.opacity(0.4),
                                                        lineWidth: 0.5
                                                    )
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, DesignSystem.spacing.lg)
                        }

                        VStack(alignment: .leading, spacing: DesignSystem.spacing.md) {
                            Text("Vertical Lines")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(DesignSystem.colors.textSecondary)
                                .tracking(0.3)
                                .padding(.horizontal, DesignSystem.spacing.lg)

                            VStack(spacing: 8) {
                                ForEach(0..<4, id: \.self) { col in
                                    Button(action: { selectedTarget = "v\(col)" }) {
                                        Text("Column \(col + 1)")
                                            .font(.system(size: 13, weight: .light))
                                            .foregroundColor(
                                                selectedTarget == "v\(col)"
                                                    ? .white
                                                    : DesignSystem.colors.accentBlue
                                            )
                                            .frame(maxWidth: .infinity)
                                            .padding(DesignSystem.spacing.sm)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(
                                                        selectedTarget == "v\(col)"
                                                            ? DesignSystem.colors.accentBlue
                                                            : Color.clear
                                                    )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(
                                                        DesignSystem.colors.accentBlue.opacity(0.4),
                                                        lineWidth: 0.5
                                                    )
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, DesignSystem.spacing.lg)
                        }

                        VStack(alignment: .leading, spacing: DesignSystem.spacing.md) {
                            Text("Diagonal Lines")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(DesignSystem.colors.textSecondary)
                                .tracking(0.3)
                                .padding(.horizontal, DesignSystem.spacing.lg)

                            VStack(spacing: 8) {
                                ForEach(0..<4, id: \.self) { idx in
                                    Button(action: { selectedTarget = "d\(idx)" }) {
                                        Text("Diagonal \(idx + 1)")
                                            .font(.system(size: 13, weight: .light))
                                            .foregroundColor(
                                                selectedTarget == "d\(idx)"
                                                    ? .white
                                                    : DesignSystem.colors.accentBlue
                                            )
                                            .frame(maxWidth: .infinity)
                                            .padding(DesignSystem.spacing.sm)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(
                                                        selectedTarget == "d\(idx)"
                                                            ? DesignSystem.colors.accentBlue
                                                            : Color.clear
                                                    )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(
                                                        DesignSystem.colors.accentBlue.opacity(0.4),
                                                        lineWidth: 0.5
                                                    )
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, DesignSystem.spacing.lg)
                        }
                    }
                    .padding(.vertical, DesignSystem.spacing.lg)
                }

                if selectedTarget != nil {
                    GradientButton(
                        label: "Confirm",
                        action: {
                            navigationPath.removeLast()
                        }
                    )
                    .padding(DesignSystem.spacing.lg)
                } else {
                    GlassButton(
                        label: L.back,
                        action: { navigationPath.removeLast() }
                    )
                    .padding(DesignSystem.spacing.lg)
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SkillTargetSelectionView(navigationPath: .constant([]), skillName: "Line Break")
}
