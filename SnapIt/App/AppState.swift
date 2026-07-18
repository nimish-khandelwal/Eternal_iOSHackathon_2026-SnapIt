import Foundation

@Observable
final class AppState {
    let visionService: VisionService
    let catalogService: CatalogService
    let purchaseHistoryService: PurchaseHistoryService
    let cartStore: CartStore
    let localOrders = LocalOrderHistoryStore()
    let subscriptionStore: SubscriptionStore

    /// Set by any screen that wants `HomeView` to pop every pushed screen and
    /// switch to a specific bottom tab — e.g. tab 0 after an order is placed,
    /// or tab 4 (Cart) after adding items from a scan result. `HomeView` clears
    /// this back to nil once it's handled the request.
    var requestedTabAfterAction: Int?

    init(cartStore: CartStore = CartStore(), subscriptionStore: SubscriptionStore = SubscriptionStore()) {
        // Swap point: flip to OpenAIVisionService() or GeminiVisionService()
        // once a real key is set in Core/Networking/Secrets.swift.
        self.visionService = GeminiVisionService()
        let catalog = MockCatalogService()
        self.catalogService = catalog
        self.purchaseHistoryService = catalog
        self.cartStore = cartStore
        self.subscriptionStore = subscriptionStore
    }
}
