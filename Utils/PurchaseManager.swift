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
    @Published private(set) var adFreeProduct: Product?
    @Published private(set) var purchaseMessage: String?
    @Published private(set) var productLoadFailed = false

    private var transactionListener: Task<Void, Never>?

    private init() {
        isAdFree = UserDefaults.standard.bool(forKey: adFreeKey)
        transactionListener = listenForTransactions()

        Task {
            await refreshProducts()
            await refreshPurchasedProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    var purchaseTitle: String {
        adFreeProduct?.displayName ?? "広告非表示パス"
    }

    var purchaseDescription: String {
        adFreeProduct?.description ?? "広告なしで、NEXUSのプレイ体験に集中できます。"
    }

    var purchasePrice: String {
        adFreeProduct?.displayPrice ?? "価格取得中"
    }

    func refreshProducts() async {
        productLoadFailed = false
        do {
            let products = try await Product.products(for: [Self.adFreeProductId])
            adFreeProduct = products.first
            productLoadFailed = adFreeProduct == nil
        } catch {
            productLoadFailed = true
            errorMessage = "商品情報を取得できませんでした"
        }
    }

    func purchase() async {
        isLoading = true
        errorMessage = nil
        purchaseMessage = nil
        do {
            if adFreeProduct == nil {
                await refreshProducts()
            }

            guard let product = adFreeProduct else {
                errorMessage = "商品が見つかりません。App Store ConnectのIAP設定を確認してください。"
                isLoading = false
                return
            }

            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                let transaction = try checkVerified(verificationResult)
                deliver(transaction)
                await transaction.finish()
                purchaseMessage = "購入が完了しました"
            case .userCancelled:
                purchaseMessage = "購入をキャンセルしました"
            case .pending:
                purchaseMessage = "購入承認待ちです"
            @unknown default:
                errorMessage = "購入状態を確認できませんでした"
            }
        } catch StoreError.failedVerification {
            errorMessage = "購入の検証に失敗しました"
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func restore() async {
        isLoading = true
        errorMessage = nil
        purchaseMessage = nil
        do {
            try await AppStore.sync()
            let restored = await refreshPurchasedProducts()
            purchaseMessage = restored ? "購入を復元しました" : "復元できる購入がありません"
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @discardableResult
    func refreshPurchasedProducts() async -> Bool {
        var foundAdFree = false

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            if transaction.productID == Self.adFreeProductId {
                foundAdFree = true
                deliver(transaction)
            }
        }

        return foundAdFree
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handle(transactionResult: result)
            }
        }
    }

    private func handle(transactionResult: VerificationResult<Transaction>) async {
        do {
            let transaction = try checkVerified(transactionResult)
            deliver(transaction)
            await transaction.finish()
        } catch {
            errorMessage = "購入の検証に失敗しました"
        }
    }

    private func deliver(_ transaction: Transaction) {
        guard transaction.productID == Self.adFreeProductId else { return }
        markAdFree()
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw StoreError.failedVerification
        }
    }

    func markAdFree() {
        isAdFree = true
        UserDefaults.standard.set(true, forKey: adFreeKey)
    }
}

private enum StoreError: Error {
    case failedVerification
}
