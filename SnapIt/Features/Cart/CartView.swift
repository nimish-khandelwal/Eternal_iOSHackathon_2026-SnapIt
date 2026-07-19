import SwiftUI

struct CartView: View {
    @Environment(AppState.self) private var appState
    @State private var isProcessingPayment = false
    @State private var showOrderSuccess = false

    // Single source of truth for all money shown on this screen.
    private var subtotal: Double { appState.cartStore.totalPrice }
    private var discount: Double { subtotal > 200 ? 50 : 0 }
    private var deliveryCharge: Double { subtotal < 200 ? 20 : 0 }
    private var handlingCharge: Double { 12 }
    private var grandTotal: Double { max(0, subtotal - discount + deliveryCharge + handlingCharge) }

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
                            
                                HStack(spacing: 2) {
                                    Image(systemName: "clock.circle")
                                        .foregroundStyle(.green)
                                        .scaledToFill()
                                        .imageScale(.large)
                                        .frame(width: 50, height: 50)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        
                                        Text("\((appState.cartStore.totalPrice < 200) ? "" : "Free ")Delivery in 15 mins")
                                            .font(.headline)
                                        
                                        Text("Shipment of \(appState.cartStore.items.count) items")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.top, 12)

                            Divider()
                                .padding(.horizontal, 12)
                                .padding(.top, 10)

                            ForEach(appState.cartStore.items) { item in
                                
                                ProductRow(product: item.product, cartQuantity: item.quantity) {
                                    QuantityControl(item: item)
                                }
                                
                                if item.id != appState.cartStore.items.last?.id {
                                    Divider()
                                        .padding(.leading, 80)
                                }
                            }
                        }
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(.gray.opacity(0.08))
                        }
                        .disabled(isProcessingPayment)

                        // MARK: - Bill Details
                        
                        BillDetailsCard(
                            subtotal: subtotal,
                            discount: discount,
                            delivery: deliveryCharge,
                            handling: handlingCharge
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
                        
                        
                        VStack(spacing: 12) {
                            HStack {
                                
                                Text("Grand Total")
                                    .font(.system(size: 16, weight: .bold))
                                
                                Spacer()
                                
                                Text("₹\(Int(grandTotal.rounded()))")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            
                            Button {
                                placeOrder()
                            } label: {
                                Group {
                                    if isProcessingPayment {
                                        HStack(spacing: 10) {
                                            ProgressView()
                                                .tint(.white)
                                            Text("Processing payment…")
                                        }
                                    } else {
                                        Text("Place Order")
                                    }
                                }
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.green.opacity(isProcessingPayment ? 0.7 : 1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .disabled(isProcessingPayment)
                            
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .background(.white)
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
            }
        }
        .navigationTitle("Checkout")
        .alert("Order placed 🎉", isPresented: $showOrderSuccess) {
            Button("Done") { appState.requestedTabAfterAction = 0 }
        } message: {
            Text("Delivery in 15 mins. We've saved this order so future quantity recommendations match how you actually shop.")
        }
    }

    private func placeOrder() {
        isProcessingPayment = true
        // Snapshot now so mid-payment cart edits don't change what gets recorded.
        let orderedItems = appState.cartStore.items

        Task { @MainActor in
            // Simulated payment gateway round-trip.
            try? await Task.sleep(for: .seconds(1.4))

            appState.localOrders.recordOrder(items: orderedItems)
            // Clear here (not in the alert) so leaving the screen mid-payment
            // can't leave a stale cart that would double-record on retry.
            appState.cartStore.items = []
            isProcessingPayment = false
            showOrderSuccess = true
        }
    }
}

struct BillDetailsCard: View {

    let subtotal: Double
    let discount: Double
    let delivery: Double
    let handling: Double

    var total: Double {
        max(0, subtotal - discount + delivery + handling)
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 14) {

            Text("Bill Details")
                .font(.system(size: 17, weight: .bold))

            billRow("Items total", "₹\(Int(subtotal.rounded()))")

            if discount > 0 {
                billRow("Flat ₹50 OFF", "-₹\(Int(discount.rounded()))", valueColor: .green)
            }

            billRow(
                "Delivery charge",
                delivery == 0 ? "FREE" : "₹\(Int(delivery.rounded()))",
                valueColor: delivery == 0 ? .green : .primary
            )

            billRow("Handling charge", "₹\(Int(handling.rounded()))")

            Divider()

            HStack {

                Text("Grand total")
                    .font(.system(size: 16, weight: .bold))

                Spacer()

                Text("₹\(Int(total.rounded()))")
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
        VStack(alignment: .trailing, spacing: 8) {

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
            .frame(width: 84, height: 34)
            .background(.green)
            .clipShape(Capsule())
            .animation(.easeInOut(duration: 0.18), value: item.quantity)

            HStack(spacing: 5) {
                if let mrp = item.product.mrp, mrp > item.product.price {
                    Text("₹\(Int(mrp.rounded()))")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                        .strikethrough()
                }

                Text("₹\(Int(item.product.price.rounded()))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
    }
}

#Preview("Cart with items") {

    let appState = AppState()

    let sampleProducts = [
        Product(
            id: "yummiez-nuggets",
            name: "Godrej Yummiez Chicken Nuggets",
            synonyms: [],
            category: "Frozen",
            price: 269,
            unit: "400 g",
            emoji: "🍗",
            mrp: 319
        ),
        Product(
            id: "mccain-potato-bites",
            name: "McCain Chilli Garlic Potato Bites",
            synonyms: [],
            category: "Frozen",
            price: 218,
            unit: "420 g",
            emoji: "🥔",
            mrp: 249
        ),
        Product(
            id: "amul-taaza-milk",
            name: "Amul Taaza Toned Milk",
            synonyms: [],
            category: "Dairy",
            price: 74,
            unit: "1 L",
            emoji: "🥛",
            mrp: 78
        )
    ]

    appState.cartStore.items = [
        CartItem(product: sampleProducts[0], quantity: 1),
        CartItem(product: sampleProducts[1], quantity: 2),
        CartItem(product: sampleProducts[2], quantity: 1)
    ]

    // Fake one past order so the recommendation chip and orange stepper
    // are visible in the canvas (store is in-memory during previews).
    appState.localOrders.recordOrder(items: [
        CartItem(product: sampleProducts[0], quantity: 4)
    ])

    return NavigationStack {
        CartView()
    }
    .environment(appState)
}

#Preview("Empty cart") {
    NavigationStack {
        CartView()
    }
    .environment(AppState())
}
