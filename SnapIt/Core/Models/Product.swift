import Foundation

/// A single Blinkit catalog SKU. `synonyms` absorbs the messy names a vision
/// model or a handwritten list will actually produce ("coke", "cola bottle").
struct Product: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let synonyms: [String]
    let category: String
    let price: Double
    let unit: String
    let emoji: String
    var brand: String? = nil
    var mrp: Double? = nil
    var discount: Int? = nil
    var stock: Int? = nil
    var rating: Double? = nil
}