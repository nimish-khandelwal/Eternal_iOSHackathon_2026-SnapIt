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

    Identify every visible grocery or household product using two signals, in this priority order:
    1. Text and branding — read any visible label, printed text, or packaging design.
    2. Visual appearance — for items with no legible text (loose pulses, dals, grains, spices,
       fresh produce, or anything decanted into a plain jar or container), identify the product
       from its shape, color, and texture instead (for example: split orange-yellow lentils are
       "Toor Dal", a pile of reddish-brown bulbs is "Onions").

    For packaged items, read the label if visible. Group multiples of the same product into one
    entry with an estimated quantity. Lower the confidence score when you're relying on visual
    appearance alone rather than a readable label.

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
    or household product using two signals, in this priority order:
    1. Text and branding — read any visible label, printed text, brand name, or packaging design.
    2. Visual appearance — if no legible text is visible (e.g. loose grains, pulses, dals, fresh
       produce, or an unbranded/unpackaged item), identify the product purely from its shape,
       color, and texture (for example: split orange-yellow lentils are "Toor Dal", a bundle of
       long green stalks is "Coriander Leaves").

    Return ONLY this JSON:
    {
      "detected_products": [
        { "name": "Maggi 2-Minute Noodles", "confidence": 0.97 }
      ]
    }

    Return exactly one entry. Lower the confidence score when you're relying on visual appearance
    alone rather than a readable label. If no product is identifiable, return { "detected_products": [] }.
    """

    private static let shoppingList = """
    You are reading a handwritten or printed shopping list, or a grocery receipt, from a photo.
    This is a text-transcription task only — do not try to visually identify any objects or
    products that might also be visible in the photo (a pen, a desk, a mug, etc). Only transcribe
    what is written or printed as text.

    Transcribe each line item as a grocery or household product name. Expand abbreviations
    where obvious (e.g. "brd" -> "Bread"). Ignore prices, totals, store names, and taxes
    unless a line is clearly an item name. If a line is illegible, skip it rather than guessing.

    Return ONLY this JSON:
    {
      "detected_products": [
        { "name": "Bread", "confidence": 0.88 }
      ]
    }
    """
}
