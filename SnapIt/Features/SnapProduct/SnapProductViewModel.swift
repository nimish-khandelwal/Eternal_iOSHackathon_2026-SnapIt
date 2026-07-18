import UIKit

@Observable
final class SnapProductViewModel {
    private let visionService: VisionService
    private let catalogService: CatalogService

    var phase: ScanPhase = .capture
    var capturedImage: UIImage?
    var detectedProduct: DetectedProduct?
    /// Populated only when the match is missing or under-confident — drives
    /// the manual "pick the actual product" picker under the result.
    var candidateProducts: [Product] = []

    init(visionService: VisionService, catalogService: CatalogService) {
        self.visionService = visionService
        self.catalogService = catalogService
    }

    func analyze(image: UIImage) async {
        capturedImage = image
        phase = .analyzing
        do {
            let catalog = try await catalogService.allProducts()
            let detected = try await visionService.detectProducts(in: image, mode: .singleProduct)

            guard var first = detected.first else {
                phase = .error("Couldn't recognize that product. Try moving closer or improving lighting.")
                return
            }
            let matcher = ProductMatcher(catalog: catalog)
            first.matchedProduct = matcher.match(first)
            detectedProduct = first

            if first.matchedProduct == nil || first.confidence < ProductMatcher.lowConfidenceThreshold {
                candidateProducts = matcher.candidates(for: first)
            } else {
                candidateProducts = []
            }
            phase = .results
        } catch {
            phase = .error(error.localizedDescription)
        }
    }

    func retry() {
        phase = .capture
        capturedImage = nil
        detectedProduct = nil
        candidateProducts = []
    }
}
