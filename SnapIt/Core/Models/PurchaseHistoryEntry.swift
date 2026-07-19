import Foundation

/// One line of a user's Blinkit order history, pre-aggregated into a reorder cadence.
struct PurchaseHistoryEntry: Codable, Identifiable {
    var id: String { product.id }
    let product: Product
    let averageFrequencyDays: Int
    let lastOrderedDate: Date
}
