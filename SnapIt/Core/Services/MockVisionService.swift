import UIKit

/// Demo-safety net: replays fixed responses instead of calling out to a real
/// vision API. Swap in `AppState` if venue wifi can't be trusted mid-demo.
final class MockVisionService: VisionService {
    func detectProducts(in image: UIImage, mode: ScanMode) async throws -> [DetectedProduct] {
        try await Task.sleep(nanoseconds: 1_400_000_000)

        switch mode {
        case .pantryScan:
            return [
                DetectedProduct(name: "Eggs", confidence: 0.94),
                DetectedProduct(name: "Amul Butter", confidence: 0.89),
                DetectedProduct(name: "Tomatoes", confidence: 0.91)
            ]
        case .singleProduct:
            return [
                DetectedProduct(name: "Maggi 2-Minute Noodles", confidence: 0.97)
            ]
        case .shoppingList:
            return [
                DetectedProduct(name: "Milk", confidence: 0.90),
                DetectedProduct(name: "Bread", confidence: 0.87),
                DetectedProduct(name: "Basmati Rice", confidence: 0.85),
                DetectedProduct(name: "Colgate Toothpaste", confidence: 0.83)
            ]
        }
    }
}
