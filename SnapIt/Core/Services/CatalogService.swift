import Foundation

protocol CatalogService {
    func allProducts() async throws -> [Product]
}

protocol PurchaseHistoryService {
    func frequentlyPurchased(forUser userId: String) async throws -> [PurchaseHistoryEntry]
}

/// Stands in for Blinkit's catalog + order-history APIs — no backend needed for the demo.
final class MockCatalogService: CatalogService, PurchaseHistoryService {
    func allProducts() async throws -> [Product] {
        try Bundle.main.decodeJSON([Product].self, from: "MockCatalog.json")
    }

    func frequentlyPurchased(forUser userId: String) async throws -> [PurchaseHistoryEntry] {
        try Bundle.main.decodeJSON([PurchaseHistoryEntry].self, from: "MockPurchaseHistory.json")
    }
}
