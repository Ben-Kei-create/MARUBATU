import CoreText
import SwiftUI

enum AppFont {
    static let postScriptName = "WDXLLubrifontJPN-Regular"
    static let displayName = "WDXL Lubrifont JP N"

    static func register() {
        fontURLs.forEach { url in
            var error: Unmanaged<CFError>?
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        }
    }

    private static var fontURLs: [URL] {
        [
            Bundle.main.url(
                forResource: "WDXLLubrifontJPN-Regular",
                withExtension: "ttf",
                subdirectory: "Fonts"
            ),
            Bundle.main.url(
                forResource: "WDXLLubrifontJPN-Regular",
                withExtension: "ttf"
            )
        ]
        .compactMap { $0 }
    }
}

extension Font {
    static func app(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(AppFont.postScriptName, size: size)
    }
}
