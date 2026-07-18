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
                ScrollView {
                    LazyVStack(spacing: 16) {

                        // MARK: - Cart Products
                        VStack(spacing: 0) {

                            ForEach(appState.cartStore.items) { item in
                                
                                ProductRow(product: item.product) {
                                    QuantityControl(item: item)
                                }

                                if item.id != appState.cartStore.items.last?.id {
                                    Divider()
                                        .padding(.leading, 94)
                                }
                            }
                        }
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(.gray.opacity(0.08))
                        }

                        // MARK: - Bill Details

                        BillDetailsCard(
                            subtotal: appState.cartStore.totalPrice,
                            discount: 50,
                            delivery: appState.cartStore.totalPrice < 200 ? 20 : 0,
                            handling: 12
                        )

                        // MARK: - Cancellation Policy

                        VStack(alignment: .leading, spacing: 10) {

                            Text("Cancellation Policy")
                                .font(.headline)

                            Text("Once your order is placed, cancellation may result in a fee. In case of unexpected delays leading to order cancellation, a complete refund will be provided.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
                .safeAreaInset(edge: .bottom) {

                    VStack(spacing: 12) {

                        HStack {

                            Text("Grand Total")
                                .font(.system(size: 16, weight: .bold))

                            Spacer()

                            Text("₹\(Int(appState.cartStore.totalPrice - 50 + 2))")
                                .font(.system(size: 18, weight: .bold))
                        }

                        Button {

                            showCheckoutAlert = true

                        } label: {

                            Text("Add payment method")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .background(.white)
                }
            }
        }
        .navigationTitle("Checkout")
        .alert("This is a hackathon demo", isPresented: $showCheckoutAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Checkout isn't wired to a real payment flow.")
        }
    }
}

struct BillDetailsCard: View {

    let subtotal: Double
    let discount: Double
    let delivery: Double
    let handling: Double

    var total: Double {
        subtotal - discount + delivery + handling
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 14) {

            Text("Bill Details")
                .font(.system(size: 17, weight: .bold))

            billRow("Items total", "₹\(Int(subtotal))")

            billRow("Flat ₹50 OFF", "-₹50", valueColor: .green)
            
            billRow("Delivery charge", "\(self.delivery == 0 ? "FREE" : "10")", valueColor: .green)

            billRow("Handling charge", "₹12")

            Divider()

            HStack {

                Text("Grand total")
                    .font(.system(size: 16, weight: .bold))

                Spacer()

                Text("₹\(Int(total))")
                    .font(.system(size: 16, weight: .bold))
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.gray.opacity(0.08))
        }
    }

    @ViewBuilder
    private func billRow(
        _ title: String,
        _ value: String,
        valueColor: Color = .primary
    ) -> some View {

        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 15))
                .foregroundStyle(valueColor)
        }
    }
}

struct QuantityControl: View {
    @Environment(AppState.self) private var appState

    let item: CartItem

    var body: some View {
        VStack(spacing: 6) {

            HStack(spacing: 14) {

                Button {
                    appState.cartStore.updateQuantity(
                        for: item,
                        to: max(0, item.quantity - 1)
                    )
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 11, weight: .bold))
                }

                Text("\(item.quantity)")
                    .font(.system(size: 15, weight: .bold))
                    .frame(minWidth: 16)

                Button {
                    appState.cartStore.updateQuantity(
                        for: item,
                        to: item.quantity + 1
                    )
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                }
            }
            .foregroundStyle(.white)
            .frame(width: 76, height: 34)
            .background(.green)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            HStack(spacing: 4) {
                Text("₹\(Int(item.product.price + 40))")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
                    .strikethrough()

                Text("₹\(Int(item.product.price))")
                    .font(.system(size: 15, weight: .bold))
            }
        }
    }
}

#Preview("Checkout") {

    let appState = AppState()

    // Sample Products
    let nuggets = Product(
        id: "123",
        name: "Godrej Yummiez Chicken Nuggets",
        synonyms: [],
        category: "Godrej",
        price: 269,
        unit: "1",
        emoji: "/"
    )
    
    let potato = Product(
        id: "123",
        name: "McCain Chilli Garlic Potato Bite Nuggets",
        synonyms: [],
        category: "McCain",
        price: 218,
        unit: "1",
        emoji: "-"
    )

    appState.cartStore.items = [
        CartItem(product: nuggets, quantity: 1),
        CartItem(product: potato, quantity: 1)
    ]

   return NavigationStack {
        CartView()
    }
    .environment(appState)
}
