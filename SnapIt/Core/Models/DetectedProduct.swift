import Foundation

/// Raw vision-model output, before `ProductMatcher` resolves it against the catalog.
struct DetectedProduct: Identifiable {
    let id: UUID
    let name: String
    let confidence: Double
    var quantityEstimate: Int?
    var matchedProduct: Product?

    init(name: String, confidence: Double, quantityEstimate: Int? = nil, matchedProduct: Product? = nil) {
        self.id = UUID()
        self.name = name
        self.confidence = confidence
        self.quantityEstimate = quantityEstimate
        self.matchedProduct = matchedProduct
    }
}

extension DetectedProduct: Decodable {
    private enum CodingKeys: String, CodingKey {
        case name, confidence
        case quantityEstimate = "quantity_estimate"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            name: try container.decode(String.self, forKey: .name),
            confidence: try container.decode(Double.self, forKey: .confidence),
            quantityEstimate: try container.decodeIfPresent(Int.self, forKey: .quantityEstimate)
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
