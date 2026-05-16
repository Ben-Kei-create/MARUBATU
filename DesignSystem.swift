import SwiftUI

struct DesignSystem {
    static let colors = ColorPalette()
    static let spacing = Spacing()
    static let typography = Typography()
}

struct ColorPalette {
    let darkBg = Color(red: 0.05, green: 0.05, blue: 0.08)
    let darkBgSecondary = Color(red: 0.08, green: 0.08, blue: 0.12)
    let accentBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
    let accentPurple = Color(red: 0.7, green: 0.3, blue: 1.0)
    let textPrimary = Color(red: 0.95, green: 0.95, blue: 0.98)
    let textSecondary = Color(red: 0.7, green: 0.7, blue: 0.75)
    let glass = Color(red: 0.15, green: 0.15, blue: 0.2).opacity(0.4)
    let glassHover = Color(red: 0.2, green: 0.2, blue: 0.25).opacity(0.6)
    let markBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
    let markPurple = Color(red: 0.7, green: 0.3, blue: 1.0)
    let energyBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
    let unavailable = Color(red: 0.4, green: 0.4, blue: 0.45)
}

struct Spacing {
    let xs: CGFloat = 4
    let sm: CGFloat = 8
    let md: CGFloat = 16
    let lg: CGFloat = 24
    let xl: CGFloat = 32
    let xxl: CGFloat = 48
}

struct Typography {
    let titleFont: Font = .app(size: 54, weight: .thin)
    let subtitleFont: Font = .app(size: 16, weight: .light)
    let buttonFont: Font = .app(size: 17, weight: .medium)
    let smallFont: Font = .app(size: 12, weight: .light)
    let sectionTitleFont: Font = .app(size: 16, weight: .medium)
    let descriptionFont: Font = .app(size: 14, weight: .light)
    let cardTitleFont: Font = .app(size: 18, weight: .semibold)
    let scoreLargeFont: Font = .app(size: 36, weight: .light)
    let turnLabelFont: Font = .app(size: 12, weight: .light)
}
