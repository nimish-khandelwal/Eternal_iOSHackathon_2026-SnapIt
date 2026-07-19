import SwiftUI

struct ProductRow<Trailing: View>: View {

    let product: Product
    var subtitle: String?
    var cartQuantity: Int?
    var trailing: Trailing

    @Environment(AppState.self) private var appState
    @State private var isShowingRecommendationInfo = false

    init(
        product: Product,
        subtitle: String? = nil,
        cartQuantity: Int? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.product = product
        self.subtitle = subtitle
        self.cartQuantity = cartQuantity
        self.trailing = trailing()
    }

    private var recommendedQuantity: Int? {
        product.recommendedQuantity(using: appState.localOrders)
    }

    private var showsRecommendation: Bool {
        guard let cartQuantity, let recommendedQuantity else { return false }
        return cartQuantity < recommendedQuantity
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

                Text(subtitle ?? "Quantity: \(product.unit)")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
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
