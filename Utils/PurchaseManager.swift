import Combine
import Foundation
import StoreKit

@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    static let adFreeProductId = "com.marubatu.nexus.adfree"
    private let adFreeKey = "isAdFree"

    @Published var isAdFree: Bool
    @Published var isLoading = false
    @Published var errorMessage: String?

    private init() {
        isAdFree = UserDefaults.standard.bool(forKey: "isAdFree")
    }

    func purchase() async {
        isLoading = true
        errorMessage = nil
        do {
            let products = try await Product.products(for: [Self.adFreeProductId])
            guard let product = products.first else {
                errorMessage = "商品が見つかりません"
                isLoading = false
                return
            }
            let result = try await product.purchase()
            switch result {
            case .success:
                markAdFree()
            case .userCancelled:
                break
            default:
                errorMessage = "購入に失敗しました"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func restore() async {
        isLoading = true
        errorMessage = nil
        do {
            try await AppStore.sync()
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result,
                   transaction.productID == Self.adFreeProductId {
                    markAdFree()
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func markAdFree() {
        isAdFree = true
        UserDefaults.standard.set(true, forKey: adFreeKey)
    }
}
