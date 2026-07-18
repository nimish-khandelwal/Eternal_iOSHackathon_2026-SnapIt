import SwiftUI

/// Shown beneath a detection the vision model wasn't confident about (or
/// couldn't match to the catalog at all). A horizontal shortlist beats a
/// single silent guess — wrong AI picks become a one-tap fix instead of a
/// wrong item quietly riding along to checkout.
struct ManualMatchPicker: View {
    @Environment(AppState.self) private var appState
    let candidates: [Product]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Not quite right? Pick the actual product")
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(candidates) { product in
                        ProductCard(
                            product: product,
                            quantityInCart: appState.cartStore.quantity(for: product),
                            onIncrement: { appState.cartStore.add([product]) },
                            onDecrement: { appState.cartStore.decrement(product) }
                        )
                        .frame(width: 128)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
            }
        }
    }
}
