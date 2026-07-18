import SwiftUI

struct ProductRow<Trailing: View>: View {

    let product: Product
    var subtitle: String?
    var trailing: Trailing

    init(
        product: Product,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.product = product
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {

        HStack(alignment: .top, spacing: 12) {

            RoundedRectangle(cornerRadius: 14)
                .fill(product.categoryColor.opacity(0.12))
                .frame(width: 70, height: 70)
                .overlay {
                    Text(product.emoji)
                        .font(.system(size: 30))
                }

            VStack(alignment: .leading, spacing: 5) {

                Text(product.name)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(2)

//                Text(subtitle ?? "Quantity: \(product.unit)")
//                    .font(.system(size: 13))
//                    .foregroundStyle(.secondary)

                Text("Move to wishlist")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .underline()
            }

            Spacer()

            trailing
        }
        .padding(12)
    }
}

extension ProductRow where Trailing == EmptyView {

    init(product: Product, subtitle: String? = nil) {
        self.init(product: product, subtitle: subtitle) {
            EmptyView()
        }
    }
}
