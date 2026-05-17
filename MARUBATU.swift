import SwiftUI

@main
struct MAARUBATUApp: App {
    init() {
        AppFont.register()
        _ = PurchaseManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
