import SwiftUI

struct GlassPanel<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    var borderColor: Color = DesignSystem.colors.textSecondary.opacity(0.2)
    var borderWidth: CGFloat = 0.5

    init(padding: CGFloat = 16, borderColor: Color = DesignSystem.colors.textSecondary.opacity(0.2), borderWidth: CGFloat = 0.5, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(DesignSystem.colors.glass)
                    
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }
}

#Preview {
    VStack(spacing: 16) {
        GlassPanel {
            VStack(alignment: .leading, spacing: 8) {
                Text("Panel Title")
                    .font(.app(size: 16, weight: .medium))
                    .foregroundColor(DesignSystem.colors.textPrimary)
                Text("Panel content goes here")
                    .font(.app(size: 14, weight: .light))
                    .foregroundColor(DesignSystem.colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    .padding(24)
    .background(DesignSystem.colors.darkBg)
    .ignoresSafeArea()
}
