import Foundation

/// Persists placed orders on-device (UserDefaults) so quantity recommendations
/// come from what this user actually ordered before.
@Observable
final class LocalOrderHistoryStore {

    /// productID -> quantities from each past order, oldest first.
    private(set) var pastOrderQuantities: [String: [Int]] = [:]

    private static let storageKey = "snapit.localOrderHistory"
    private static let maxOrdersPerProduct = 10

    /// SwiftUI previews get an in-memory store so preview taps never
    /// pollute the real on-device history.
    private let persists = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1"

    init() {
        guard persists,
              let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let decoded = try? JSONDecoder().decode([String: [Int]].self, from: data) else {
            return
        }
        pastOrderQuantities = decoded
    }

    func recordOrder(items: [CartItem]) {
        for item in items where item.quantity > 0 {
            var history = pastOrderQuantities[item.product.id, default: []]
            history.append(item.quantity)
            pastOrderQuantities[item.product.id] = Array(history.suffix(Self.maxOrdersPerProduct))
        }
        save()
    }

    /// Average of this user's past order quantities for the product, rounded.
    /// nil when the product has never been ordered locally.
    func usualQuantity(for product: Product) -> Int? {
        guard let quantities = pastOrderQuantities[product.id], !quantities.isEmpty else {
            return nil
        }
        let average = Double(quantities.reduce(0, +)) / Double(quantities.count)
        return max(1, Int(average.rounded()))
    }

    private func save() {
        guard persists else { return }
        if let data = try? JSONEncoder().encode(pastOrderQuantities) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}

extension Product {
    /// Recommended amount from this user's real local order history.
    /// nil until the product has actually been purchased at least once.
    func recommendedQuantity(using history: LocalOrderHistoryStore?) -> Int? {
        history?.usualQuantity(for: self)
    }
}
