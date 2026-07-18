import UIKit

/// Demo-safety net: replays fixed responses instead of calling out to a real
/// vision API. Swap in `AppState` if venue wifi can't be trusted mid-demo.
final class MockVisionService: VisionService {
    func detectProducts(in image: UIImage, mode: ScanMode) async throws -> [DetectedProduct] {
        try await Task.sleep(nanoseconds: 1_400_000_000)

        switch mode {
        case .pantryScan:
            return [
                DetectedProduct(name: "Amul Butter", confidence: 0.89),     // read from packaging
                DetectedProduct(name: "Onions", confidence: 0.82),          // visual — no label
                DetectedProduct(name: "Fresh Coriander", confidence: 0.71)  // visual — not in catalog, shows up as unrecognized
            ]
        case .singleProduct:
            return [
                DetectedProduct(name: "Amul Milk", confidence: 0.97)  // read from packaging
            ]
        case .shoppingList:
            return [
                DetectedProduct(name: "Amul Milk", confidence: 0.90),
                DetectedProduct(name: "Mother Dairy Toor Dal", confidence: 0.87),
                DetectedProduct(name: "Amul Paratha", confidence: 0.85),
                DetectedProduct(name: "Patanjali Toothpaste", confidence: 0.83)
            ]
        }
    }
}
