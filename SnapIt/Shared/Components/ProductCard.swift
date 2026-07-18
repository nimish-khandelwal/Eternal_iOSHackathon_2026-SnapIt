import SwiftUI

/// Blinkit-style browse tile: emoji "photo" on a category-tinted card, name,
/// unit, price, and an inline +/- stepper that appears once it's in the cart.
struct ProductCard: View {
    let product: Product
    let quantityInCart: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(product.categoryColor.opacity(0.16))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(Text(product.emoji).font(.system(size: 38)))

                addControl
                    .padding(6)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.caption.weight(.medium))
                    .lineLimit(2)
                    .frame(height: 30, alignment: .top)
                Text(product.unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("₹\(Int(product.price))")
                    .font(.subheadline.weight(.semibold))
            }
        }
    }

    @ViewBuilder
    private var addControl: some View {
        if quantityInCart == 0 {
            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(.caption.weight(.bold))
                    .frame(width: 26, height: 26)
                    .background(Color.accentColor, in: Circle())
                    .foregroundStyle(.white)
            }
        } else {
            HStack(spacing: 8) {
                Button(action: onDecrement) {
                    Image(systemName: "minus")
                }
                Text("\(quantityInCart)")
                    .frame(minWidth: 12)
                Button(action: onIncrement) {
                    Image(systemName: "plus")
                }
            }
            .font(.caption.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.accentColor, in: Capsule())
            .foregroundStyle(.white)
        }
    }
}
