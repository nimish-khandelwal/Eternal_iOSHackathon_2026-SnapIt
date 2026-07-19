import SwiftUI

/// Maps catalog categories to a tile color, shared by `ProductRow` and `ProductCard`
/// so the emoji "photo" always sits on the same colored card wherever it appears.
extension Product {
    var categoryColor: Color {
        switch category {
        case "Dairy": return .blue
        case "Eggs & Meat": return .red
        case "Bakery": return .orange
        case "Beverages": return .pink
        case "Instant Food": return .yellow
        case "Frozen Food": return .cyan
        case "Snacks": return .mint
        case "Staples": return .brown
        case "Vegetables": return .accent
        case "Fruits": return .red
        case "Personal Care": return .purple
        case "Cleaning": return .teal
        case "Tea & Coffee": return .brown
        case "Spices": return .orange
        case "Baby Care": return .indigo
        case "Sweets": return .pink
        default: return .gray
        }
    }
}
