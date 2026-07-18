import Foundation

@Observable
final class AppState {
    let visionService: VisionService
    let catalogService: CatalogService
    let purchaseHistoryService: PurchaseHistoryService
    let cartStore: CartStore
    let localOrders = LocalOrderHistoryStore()

    init(cartStore: CartStore = CartStore()) {
        // Swap point: flip to OpenAIVisionService() or GeminiVisionService()
        // once a real key is set in Core/Networking/Secrets.swift.
        self.visionService = GeminiVisionService()
        let catalog = MockCatalogService()
        self.catalogService = catalog
        self.purchaseHistoryService = catalog
        self.cartStore = cartStore
    }
}
