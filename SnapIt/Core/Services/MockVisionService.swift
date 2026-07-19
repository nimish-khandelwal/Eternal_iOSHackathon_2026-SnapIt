import UIKit

/// Demo-safety net: replays fixed responses instead of calling out to a real
/// vision API. Swap in `AppState` if venue wifi can't be trusted mid-demo.
final class MockVisionService: VisionService {
    func detectProducts(in image: UIImage, mode: ScanMode) async throws -> [DetectedProduct] {
        try await Task.sleep(nanoseconds: 1_400_000_000)

        switch mode {
        case .pantryScan:
            return [
                DetectedProduct(name: "Amul Butter", confidence: 0.89, suggestedCategory: "Dairy"),
                DetectedProduct(name: "Onions", confidence: 0.82, suggestedCategory: "Vegetables"),
                // Not in the generated catalog at all — demonstrates the
                // category fallback: no product matches "coriander", but the
                // picker still shows relevant Vegetables instead of a random list.
                DetectedProduct(name: "Fresh Coriander", confidence: 0.71, suggestedCategory: "Vegetables")
            ]
        case .singleProduct:
            return [
                DetectedProduct(name: "Amul Milk", confidence: 0.97, suggestedCategory: "Dairy")
            ]
        case .shoppingList:
            return [
                DetectedProduct(name: "Amul Milk", confidence: 0.90, suggestedCategory: "Dairy"),
                DetectedProduct(name: "Mother Dairy Toor Dal", confidence: 0.87, suggestedCategory: "Staples"),
                DetectedProduct(name: "Amul Paratha", confidence: 0.85, suggestedCategory: "Frozen Food"),
                DetectedProduct(name: "Patanjali Toothpaste", confidence: 0.83, suggestedCategory: "Personal Care")
            ]
        }
    }
}
