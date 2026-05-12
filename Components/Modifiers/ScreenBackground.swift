import SwiftUI

struct ScreenBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            FuturisticBackground()
                .ignoresSafeArea()

            content
        }
        .ignoresSafeArea()
    }
}

extension View {
    func screenBackground() -> some View {
        modifier(ScreenBackgroundModifier())
    }
}
