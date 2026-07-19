import UIKit

enum ScanMode {
    case singleProduct
    case shoppingList
    case pantryScan
}

protocol VisionService {
    func detectProducts(in image: UIImage, mode: ScanMode) async throws -> [DetectedProduct]
}

enum VisionServiceError: LocalizedError {
    case invalidImage
    case invalidResponse
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Couldn't read the captured image."
        case .invalidResponse:
            return "The vision model returned something unexpected."
        case .apiError(let message):
            return message
        }
    }
}
