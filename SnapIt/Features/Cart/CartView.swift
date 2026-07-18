import SwiftUI

struct CartView: View {
    @Environment(AppState.self) private var appState
    @State private var showCheckoutAlert = false

    var body: some View {
        Group {
            if appState.cartStore.items.isEmpty {
                ContentUnavailableView(
                    "Your cart is empty",
                    systemImage: "cart",
                    description: Text("Scan a product, list, or your pantry to get started.")
                )
            } else {
                List {
                    ForEach(appState.cartStore.items) { item in
                        HStack {
                            ProductRow(product: item.product)
                            Stepper(
                                value: Binding(
                                    get: { item.quantity },
                                    set: { appState.cartStore.updateQuantity(for: item, to: $0) }
                                ),
                                in: 0...20
                            ) {
                                Text("\(item.quantity)")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(minWidth: 20)
                            }
                            .fixedSize()
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Total")
                            Spacer()
                            Text("₹\(Int(appState.cartStore.totalPrice))")
                                .font(.headline)
                        }
                        Button {
                            showCheckoutAlert = true
                        } label: {
                            Text("Checkout")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding()
                    .background(.bar)
                }
            }
        }
        .navigationTitle("Cart")
        .alert("This is a hackathon demo", isPresented: $showCheckoutAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Checkout isn't wired to a real payment flow.")
        }
    }
}
