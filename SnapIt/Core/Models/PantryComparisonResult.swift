import Foundation

/// Never "out of stock" — a single frame can't see the whole fridge, so the
/// worst thing `ComparisonEngine` will say is that a refill is likely due.
enum RefillStatus: String {
    case likelyRunningLow = "Likely Running Low"
    case stillAvailable = "Still Available"
    case notDetected = "Not Detected"
}

struct PantryComparisonResult: Identifiable {
    let id = UUID()
    let product: Product
    let status: RefillStatus
    let daysSinceLastOrder: Int?
    let usualFrequencyDays: Int?
    let detectionConfidence: Double?
}
