import SwiftUI

struct EnergyBar: View {
    let current: Int
    let max: Int

    var body: some View {
        HStack(spacing: DesignSystem.spacing.md) {
            HStack(spacing: 0) {
                ForEach(0..<max, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            index < current
                                ? DesignSystem.colors.accentBlue
                                : DesignSystem.colors.textSecondary.opacity(0.2)
                        )
                        .frame(height: 8)
                        .shadow(
                            color: index < current
                                ? DesignSystem.colors.accentBlue.opacity(0.6)
                                : .clear,
                            radius: 4
                        )

                    if index < max - 1 {
                        Spacer()
                            .frame(width: 2)
                    }
                }
            }

            Text("\(current) / \(max)")
                .font(.app(size: 13, weight: .light))
                .foregroundColor(DesignSystem.colors.textSecondary)
                .frame(width: 50, alignment: .trailing)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(DesignSystem.colors.accentBlue)

                Text("ENERGY")
                    .font(.app(size: 12, weight: .light))
                    .foregroundColor(DesignSystem.colors.textSecondary)
                    .tracking(0.5)
            }

            EnergyBar(current: 6, max: 10)
        }
        .padding(DesignSystem.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(DesignSystem.colors.glass)
        )
        .background(.ultraThinMaterial)
    }
    .padding(DesignSystem.spacing.lg)
    .background(DesignSystem.colors.darkBg)
    .ignoresSafeArea()
}
