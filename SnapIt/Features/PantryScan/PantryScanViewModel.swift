import UIKit

@Observable
final class PantryScanViewModel {
    /// A detection the vision model wasn't confident about, or couldn't map
    /// to any catalog SKU at all — paired with a manual-pick shortlist.
    struct UncertainDetection: Identifiable {
        let id: UUID
        let detected: DetectedProduct
        let candidates: [Product]
    }

    private let visionService: VisionService
    private let catalogService: CatalogService
    private let purchaseHistoryService: PurchaseHistoryService

    var phase: ScanPhase = .capture
    var capturedImage: UIImage?
    var results: [PantryComparisonResult] = []
    var uncertainDetections: [UncertainDetection] = []

    init(visionService: VisionService, catalogService: CatalogService, purchaseHistoryService: PurchaseHistoryService) {
        self.visionService = visionService
        self.catalogService = catalogService
        self.purchaseHistoryService = purchaseHistoryService
    }

    var likelyRunningLow: [PantryComparisonResult] { results.filter { $0.status == .likelyRunningLow } }
    var stillAvailable: [PantryComparisonResult] { results.filter { $0.status == .stillAvailable } }
    var notDetected: [PantryComparisonResult] { results.filter { $0.status == .notDetected } }

    /// Unmatched detections — nothing in the catalog was even a loose fit.
    var unrecognizedDetections: [UncertainDetection] {
        uncertainDetections.filter { $0.detected.matchedProduct == nil }
    }

    /// Candidates for a "Still Available" row — shown regardless of match
    /// confidence, since nothing is auto-selected; this is how the row's
    /// product gets corrected (or just reinforced) by hand.
    func candidates(forMatchedProductID productID: String) -> [Product]? {
        uncertainDetections.first { $0.detected.matchedProduct?.id == productID }?.candidates
    }

    func analyze(image: UIImage) async {
        capturedImage = image
        phase = .analyzing
        do {
            async let catalogTask = catalogService.allProducts()
            async let historyTask = purchaseHistoryService.frequentlyPurchased(forUser: "demo-user")
            async let detectedTask = visionService.detectProducts(in: image, mode: .pantryScan)

            let (catalog, history, detected) = try await (catalogTask, historyTask, detectedTask)

            let matcher = ProductMatcher(catalog: catalog)
            let enrichedDetected = detected.map { d -> DetectedProduct in
                var copy = d
                copy.matchedProduct = matcher.match(d)
                return copy
            }

            uncertainDetections = enrichedDetected
                .map { UncertainDetection(id: $0.id, detected: $0, candidates: matcher.candidates(for: $0)) }

            results = ComparisonEngine().compare(frequent: history, detected: enrichedDetected, today: Date())
            phase = .results
        } catch {
            phase = .error(error.localizedDescription)
        }
    }

    func retry() {
        phase = .capture
        capturedImage = nil
        results = []
        uncertainDetections = []
    }
}
