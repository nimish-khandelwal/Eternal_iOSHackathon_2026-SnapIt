import Foundation

/// The feature's actual insight: frequent purchases minus what's visible this scan,
/// biased by whether a product is already overdue for its usual reorder cadence.
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
            let isOverdue = daysSince >= entry.averageFrequencyDays
            let seen = detectedByProductID[entry.product.id]

            let status: RefillStatus = seen != nil ? .stillAvailable : (isOverdue ? .likelyRunningLow : .notDetected)

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
        case .stillAvailable: return 1
        case .notDetected: return 2
        }
    }
}
