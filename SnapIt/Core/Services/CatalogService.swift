import Foundation

protocol CatalogService {
    func allProducts() async throws -> [Product]
}

protocol PurchaseHistoryService {
    func frequentlyPurchased(forUser userId: String) async throws -> [PurchaseHistoryEntry]
}

/// One line of `MockPurchaseHistory.json` — references a catalog product by id
/// rather than embedding a copy, so it can never drift out of sync with the
/// catalog the way a duplicated `Product` snapshot could.
private struct PurchaseHistoryRecord: Decodable {
    let productId: String
    let averageFrequencyDays: Int
    let daysSinceLastOrder: Int
}

/// Stands in for Blinkit's catalog + order-history APIs — no backend needed for the demo.
final class MockCatalogService: CatalogService, PurchaseHistoryService {
    func allProducts() async throws -> [Product] {
        try Bundle.main.decodeJSON([Product].self, from: "MockCatalog.json")
    }

    func frequentlyPurchased(forUser userId: String) async throws -> [PurchaseHistoryEntry] {
        let records = try Bundle.main.decodeJSON([PurchaseHistoryRecord].self, from: "MockPurchaseHistory.json")
        let catalog = try await allProducts()
        let productsByID = Dictionary(uniqueKeysWithValues: catalog.map { ($0.id, $0) })

        let today = Calendar.current.startOfDay(for: Date())

        return records.compactMap { record in
            guard let product = productsByID[record.productId] else { return nil }
            let lastOrderedDate = Calendar.current.date(byAdding: .day, value: -record.daysSinceLastOrder, to: today) ?? today
            return PurchaseHistoryEntry(
                product: product,
                averageFrequencyDays: record.averageFrequencyDays,
                lastOrderedDate: lastOrderedDate
            )
        }
    }
}
