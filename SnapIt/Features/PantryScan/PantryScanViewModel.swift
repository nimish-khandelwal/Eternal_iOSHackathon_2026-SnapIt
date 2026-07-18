import UIKit

@Observable
final class PantryScanViewModel {
    private let visionService: VisionService
    private let catalogService: CatalogService
    private let purchaseHistoryService: PurchaseHistoryService

    var phase: ScanPhase = .capture
    var capturedImage: UIImage?
    var results: [PantryComparisonResult] = []

    init(visionService: VisionService, catalogService: CatalogService, purchaseHistoryService: PurchaseHistoryService) {
        self.visionService = visionService
        self.catalogService = catalogService
        self.purchaseHistoryService = purchaseHistoryService
    }

    var likelyRunningLow: [PantryComparisonResult] { results.filter { $0.status == .likelyRunningLow } }
    var stillAvailable: [PantryComparisonResult] { results.filter { $0.status == .stillAvailable } }
    var notDetected: [PantryComparisonResult] { results.filter { $0.status == .notDetected } }

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
    }
}
