import Foundation
import SwiftUI

@MainActor
class AdManager: ObservableObject {
    static let shared = AdManager()

    @Published var shouldShowAd = false

    private var playsSinceLastAd = 0
    private let minPlaysBeforeAd = 1

    private init() {}

    func recordGameEnd() {
        guard !PurchaseManager.shared.isAdFree else { return }
        playsSinceLastAd += 1
        if playsSinceLastAd >= minPlaysBeforeAd {
            let roll = Double.random(in: 0...1)
            if roll < 0.7 {
                shouldShowAd = true
                playsSinceLastAd = 0
            }
        }
    }

    func dismissAd() {
        shouldShowAd = false
    }
}
