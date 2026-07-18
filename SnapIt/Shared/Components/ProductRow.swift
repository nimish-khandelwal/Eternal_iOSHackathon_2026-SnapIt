import SwiftUI

struct ProductRow<Trailing: View>: View {
    let product: Product
    var subtitle: String?
    var trailing: Trailing

    init(product: Product, subtitle: String? = nil, @ViewBuilder trailing: () -> Trailing) {
        self.product = product
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 12) {
            iconTile
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.subheadline.weight(.medium))
                Text(subtitle ?? "\(product.unit) · ₹\(Int(product.price))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            trailing
        }
        .padding(.vertical, 4)
    }

    private var iconTile: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(product.categoryColor.opacity(0.15))
            .frame(width: 44, height: 44)
            .overlay(Text(product.emoji).font(.system(size: 20)))
    }
}

extension ProductRow where Trailing == EmptyView {
    init(product: Product, subtitle: String? = nil) {
        self.init(product: product, subtitle: subtitle) { EmptyView() }
    }
}
