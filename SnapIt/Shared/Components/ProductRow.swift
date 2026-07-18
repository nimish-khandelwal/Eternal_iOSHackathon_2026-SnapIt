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

        VStack(alignment: .leading, spacing: 10) {

            HStack(alignment: .top, spacing: 12) {

                RoundedRectangle(cornerRadius: 14)
                    .fill(product.categoryColor.opacity(0.12))
                    .frame(width: 56, height: 56)
                    .overlay {
                        Text(product.emoji)
                            .font(.system(size: 26))
                    }

                VStack(alignment: .leading, spacing: 7) {
                    Text(product.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.black)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    } else {
                        Text("Move to wishlist")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .underline()
                    }
                }
                .layoutPriority(1)

                Spacer(minLength: 8)

                trailing
            }

            if showsRecommendation {
                Button {
                    isShowingRecommendationInfo = true
                } label: {
                    HStack(spacing: 5) {
                        Text("Recommended quantity: \"\(recommendedQuantity ?? 0)\"")
                            .font(.system(size: 12, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)

                        Image(systemName: "info.circle")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.12), in: Capsule())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
        .alert("Running low soon?", isPresented: $isShowingRecommendationInfo) {
            Button("Got it", role: .cancel) {}
        } message: {
            Text("You usually order \(recommendedQuantity ?? 0) × \(product.name) — right now you've added \(cartQuantity ?? 0). Topping up to your usual amount means fewer reorders later.")
        }
    }
}

extension ProductRow where Trailing == EmptyView {

    init(product: Product, subtitle: String? = nil) {
        self.init(product: product, subtitle: subtitle) {
            EmptyView()
        }
    }
}
