import Foundation

/// The feature's actual insight: frequent purchases against what's visible this
/// scan. Status comes straight from the vision model's own read on each frame —
/// no inference from order-history dates. Not detected at all → Out of Stock.
/// Detected but flagged as visually low → Likely Running Low. Otherwise → Still
/// Available.
struct ComparisonEngine {
    func compare(frequent: [PurchaseHistoryEntry], detected: [DetectedProduct], today: Date) -> [PantryComparisonResult] {
        let detectedByProductID = Dictionary(
            detected.compactMap { d -> (String, DetectedProduct)? in
                guard let product = d.matchedProduct else { return nil }
                return (product.id, d)
            },
            uniquingKeysWith: { first, _ in first }
        )

        let results = frequent.map { entry -> PantryComparisonResult in
            let daysSince = Calendar.current.dateComponents(
                [.day], from: entry.lastOrderedDate, to: today
            ).day ?? 0
            let seen = detectedByProductID[entry.product.id]

            let status: RefillStatus
            if let seen {
                status = seen.isLowStock ? .likelyRunningLow : .stillAvailable
            } else {
                status = .outOfStock
            }

            return PantryComparisonResult(
                product: entry.product,
                status: status,
                daysSinceLastOrder: daysSince,
                usualFrequencyDays: entry.averageFrequencyDays,
                detectionConfidence: seen?.confidence
            )
        }

        return results.sorted { statusOrder($0.status) < statusOrder($1.status) }
    }

    private func statusOrder(_ status: RefillStatus) -> Int {
        switch status {
        case .likelyRunningLow: return 0
        case .outOfStock: return 1
        case .stillAvailable: return 2
        }
    }
}
