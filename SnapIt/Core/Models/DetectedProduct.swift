import Foundation

/// Raw vision-model output, before `ProductMatcher` resolves it against the catalog.
struct DetectedProduct: Identifiable {
    let id: UUID
    let name: String
    let confidence: Double
    var quantityEstimate: Int?
    /// The model's own best guess at a category (from a closed list we give it
    /// in the prompt) — used to ground the manual-pick shortlist in something
    /// sensible when nothing in the catalog matches the name at all.
    var suggestedCategory: String?
    /// Pantry Scan only — the model's visual read on whether this item looks
    /// nearly empty/low quantity. Drives "Likely Running Low" directly, with
    /// no fallback inference: if nothing is flagged, that section is empty.
    var isLowStock: Bool
    var matchedProduct: Product?

    init(
        name: String,
        confidence: Double,
        quantityEstimate: Int? = nil,
        suggestedCategory: String? = nil,
        isLowStock: Bool = false,
        matchedProduct: Product? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.confidence = confidence
        self.quantityEstimate = quantityEstimate
        self.suggestedCategory = suggestedCategory
        self.isLowStock = isLowStock
        self.matchedProduct = matchedProduct
    }
}

extension DetectedProduct: Decodable {
    private enum CodingKeys: String, CodingKey {
        case name, confidence
        case quantityEstimate = "quantity_estimate"
        case suggestedCategory = "category"
        case isLowStock = "low_stock"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            name: try container.decode(String.self, forKey: .name),
            confidence: try container.decode(Double.self, forKey: .confidence),
            quantityEstimate: try container.decodeIfPresent(Int.self, forKey: .quantityEstimate),
            suggestedCategory: try container.decodeIfPresent(String.self, forKey: .suggestedCategory),
            isLowStock: try container.decodeIfPresent(Bool.self, forKey: .isLowStock) ?? false
        )
    }
}

/// Shape returned by every vision prompt in `VisionPrompt`, regardless of scan mode.
struct VisionDetectionResponse: Decodable {
    let detectedProducts: [DetectedProduct]

    private enum CodingKeys: String, CodingKey {
        case detectedProducts = "detected_products"
    }
}
