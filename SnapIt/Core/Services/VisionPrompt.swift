import Foundation

/// One prompt per scan mode, all constrained to the same `detected_products`
/// JSON shape so `VisionDetectionResponse` never has to branch on mode.
enum VisionPrompt {
    static func prompt(for mode: ScanMode) -> String {
        switch mode {
        case .pantryScan: return pantryScan
        case .singleProduct: return singleProduct
        case .shoppingList: return shoppingList
        }
    }

    private static let pantryScan = """
    You are a grocery inventory detector looking at a photo of a fridge, pantry, or kitchen shelf.

    Identify every visible grocery or household product. For packaged items, read the label if
    visible. Group multiples of the same product into one entry with an estimated quantity.

    Ignore: utensils, cookware, appliances, furniture, people, hands, decorations.

    Return ONLY this JSON, no prose:
    {
      "detected_products": [
        { "name": "Milk", "confidence": 0.93, "quantity_estimate": 1 }
      ]
    }

    If nothing qualifies, return { "detected_products": [] }.
    """

    private static let singleProduct = """
    You are looking at a single product held up to the camera. Identify the most likely grocery
    or household product, using visible brand name and packaging as the primary signal.

    Return ONLY this JSON:
    {
      "detected_products": [
        { "name": "Maggi 2-Minute Noodles", "confidence": 0.97 }
      ]
    }

    Return exactly one entry. If no product is identifiable, return { "detected_products": [] }.
    """

    private static let shoppingList = """
    You are reading a handwritten or printed shopping list, or a grocery receipt, from a photo.
    Transcribe each line item as a grocery or household product name. Expand abbreviations
    where obvious (e.g. "brd" -> "Bread"). Ignore prices, totals, store names, and taxes
    unless a line is clearly an item name.

    Return ONLY this JSON:
    {
      "detected_products": [
        { "name": "Bread", "confidence": 0.88 }
      ]
    }
    """
}
