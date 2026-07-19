import Foundation

enum RefillStatus: String {
    /// Detected in the photo AND the vision model flagged it as visually low/nearly empty.
    case likelyRunningLow = "Likely Running Low"
    /// Detected in the photo, no low-stock signal.
    case stillAvailable = "Still Available"
    /// Not detected in the photo at all — this frequent product simply didn't show up.
    case outOfStock = "Out of Stock"
}

struct PantryComparisonResult: Identifiable {
    let id = UUID()
    let product: Product
    let status: RefillStatus
    let daysSinceLastOrder: Int?
    let usualFrequencyDays: Int?
    let detectionConfidence: Double?
}
