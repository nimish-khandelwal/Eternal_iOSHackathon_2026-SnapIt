import UIKit

@Observable
final class ShoppingListViewModel {
    struct ChecklistItem: Identifiable {
        let id = UUID()
        let detected: DetectedProduct
        var isIncluded = true
    }

    private let visionService: VisionService
    private let catalogService: CatalogService

    var phase: ScanPhase = .capture
    var capturedImage: UIImage?
    var items: [ChecklistItem] = []

    init(visionService: VisionService, catalogService: CatalogService) {
        self.visionService = visionService
        self.catalogService = catalogService
    }

    var selectedProducts: [Product] {
        items.filter(\.isIncluded).compactMap(\.detected.matchedProduct)
    }

    func analyze(image: UIImage) async {
        capturedImage = image
        phase = .analyzing
        do {
            let catalog = try await catalogService.allProducts()
            let detected = try await visionService.detectProducts(in: image, mode: .shoppingList)

            guard !detected.isEmpty else {
                phase = .error("Couldn't read any items from that photo. Try better lighting or a closer shot.")
                return
            }

            let matcher = ProductMatcher(catalog: catalog)
            items = detected.map { d in
                var enriched = d
                enriched.matchedProduct = matcher.match(d)
                return ChecklistItem(detected: enriched)
            }
            phase = .results
        } catch {
            phase = .error(error.localizedDescription)
        }
    }

    func retry() {
        phase = .capture
        capturedImage = nil
        items = []
    }
}
