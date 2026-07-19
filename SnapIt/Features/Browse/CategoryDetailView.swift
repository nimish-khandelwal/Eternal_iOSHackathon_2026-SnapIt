import SwiftUI

/// Blinkit-style category browse screen: left subcategory rail, filter chips,
/// promo banner, 2-column product grid, floating view-cart bar.
struct CategoryDetailView: View {
    let category: StoreCategory

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var allProducts: [Product] = []
    @State private var selectedRailIndex = 0
    @State private var selectedProduct: Product?

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 0) {
            topBar

            Divider()

            HStack(spacing: 0) {
                subcategoryRail
                productContent
            }
        }
        .background(Color.white)
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .bottom) {
            if appState.cartStore.totalCount > 0 {
                viewCartBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.86), value: appState.cartStore.totalCount)
        .task {
            allProducts = (try? await appState.catalogService.allProducts()) ?? []
        }
        .sheet(item: $selectedProduct) { product in
            ProductOptionsSheet(
                product: product,
                onSelect: { selected in
                    appState.cartStore.add([selected])
                    selectedProduct = nil
                }
            )
            .presentationDetents([.large])
            .presentationCornerRadius(28)
            .presentationDragIndicator(.hidden)
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.black)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(category.displayTitle)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .lineLimit(1)

                HStack(spacing: 3) {
                    Text("Delivering to :")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundStyle(Color(red: 0.00, green: 0.42, blue: 0.44))
                    Text("Zomato Farm")
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(Color(red: 0.00, green: 0.42, blue: 0.44))
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.black.opacity(0.7))
                }
            }

            Spacer()

            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(.black)

            Image(systemName: "magnifyingglass")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.black)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.white)
    }

    // MARK: - Left rail

    private var railEntries: [String] {
        ["All"] + Array(Set(allProducts.map(\.category))).sorted()
    }

    private var subcategoryRail: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                ForEach(Array(railEntries.enumerated()), id: \.element) { index, entry in
                    RailItem(
                        title: entry,
                        emoji: railEmoji(for: entry),
                        selected: selectedRailIndex == index
                    ) {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                            selectedRailIndex = index
                        }
                    }
                }
            }
            .padding(.vertical, 14)
            .padding(.bottom, 90)
        }
        .frame(width: 92)
        .background(Color.white)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Color.black.opacity(0.07))
                .frame(width: 1)
        }
    }

    private func railEmoji(for entry: String) -> String {
        if entry == "All" { return "🧺" }
        return allProducts.first(where: { $0.category == entry })?.emoji ?? "🛒"
    }

    // MARK: - Right content

    private var visibleProducts: [Product] {
        guard selectedRailIndex > 0, railEntries.indices.contains(selectedRailIndex) else {
            return allProducts
        }
        let category = railEntries[selectedRailIndex]
        return allProducts.filter { $0.category == category }
    }

    private var productContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                promoBanner

                LazyVGrid(columns: gridColumns, spacing: 10) {
                    ForEach(visibleProducts) { product in
                        BlinkitProductCard(
                            product: product,
                            quantityInCart: appState.cartStore.quantity(for: product),
                            onIncrement: {
                                if product.recommendedQuantity(using: appState.localOrders) ?? 0 > 1 {
                                    selectedProduct = product        // show bottom sheet
                                } else {
                                    appState.cartStore.add([product])
                                }
                            },
                            onDecrement: {
                                appState.cartStore.decrement(product)
                            }
                        )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 16)
                .padding(.bottom, 110)
            }
        }
        .background(Color(red: 0.95, green: 0.97, blue: 0.90))
    }

    private var promoBanner: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Best picks")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("Only best options available for you")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.black.opacity(0.85))
            }

            Spacer(minLength: 4)

            Text(railEmoji(for: railEntries.indices.contains(selectedRailIndex) ? railEntries[selectedRailIndex] : "All"))
                .font(.system(size: 40))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(Color(red: 0.91, green: 0.95, blue: 0.82))
    }

    // MARK: - View cart bar

    private var viewCartBar: some View {
        NavigationLink {
            CartView()
        } label: {
            HStack(spacing: 10) {
                HStack(spacing: -8) {
                    ForEach(appState.cartStore.items.prefix(2)) { item in
                        Text(item.product.emoji)
                            .font(.system(size: 20))
                            .frame(width: 36, height: 36)
                            .background(.white, in: Circle())
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                    }
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("View cart")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                    Text("\(appState.cartStore.totalCount) Item\(appState.cartStore.totalCount == 1 ? "" : "s")")
                        .font(.system(size: 12, weight: .semibold))
                        .opacity(0.9)
                }
                .padding(.leading, 2)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.18), in: Circle())
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(Color(red: 0.20, green: 0.53, blue: 0.15), in: Capsule())
            .shadow(color: .black.opacity(0.22), radius: 14, y: 6)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 34)
        .padding(.bottom, 12)
    }
}

// MARK: - Rail item

private struct RailItem: View {
    let title: String
    let emoji: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(selected ? Color(red: 0.89, green: 0.95, blue: 0.86) : Color(red: 0.96, green: 0.96, blue: 0.96))
                        .frame(width: 58, height: 58)

                    if selected {
                        Circle()
                            .stroke(Color(red: 0.20, green: 0.53, blue: 0.15).opacity(0.5), lineWidth: 1.5)
                            .frame(width: 58, height: 58)
                    }

                    Text(emoji)
                        .font(.system(size: 30))
                }

                Text(title)
                    .font(.system(size: 11, weight: selected ? .heavy : .medium, design: .rounded))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .overlay(alignment: .trailing) {
                if selected {
                    UnevenRoundedRectangle(topLeadingRadius: 3, bottomLeadingRadius: 3)
                        .fill(Color(red: 0.20, green: 0.53, blue: 0.15))
                        .frame(width: 4, height: 58)
                        .offset(y: -14)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Product card

private struct BlinkitProductCard: View {
    let product: Product
    let quantityInCart: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    @State private var isFavorite = false
    @Environment(AppState.self) private var appState

    private var mrp: Double {
        product.mrp ?? (product.price * 1.2)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageBlock

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("₹\(Int(product.price.rounded()))")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(.black)

                    Text("₹\(Int(mrp.rounded()))")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.gray)
                        .strikethrough()
                }
                .padding(.top, 8)

                Text(product.name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 3) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 9))
                    Text("15 mins")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(.black.opacity(0.72))
                .padding(.top, 3)

                Spacer(minLength: 0)
            }
            .frame(height: 76, alignment: .top)
        }
    }

    private var imageBlock: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                }

            VStack(spacing: 0) {
                Text(product.emoji)
                    .font(.system(size: 58))
                    .frame(maxWidth: .infinity)
                    .frame(height: 118)

                HStack(spacing: 3) {
                    ForEach(0..<4, id: \.self) { dot in
                        Circle()
                            .fill(dot == 0 ? Color.black.opacity(0.55) : Color.black.opacity(0.15))
                            .frame(width: 5, height: 5)
                    }
                }
                .padding(.bottom, 50)
            }
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(product.unit)
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(.black)
                }
                .padding(.leading, 10)
                .padding(.bottom, 14)

                Spacer()

                addControl
                    .padding(.trailing, 6)
                    .padding(.bottom, 8)
            }
        }
        .frame(height: 168)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(alignment: .topTrailing) {
            Button {
                isFavorite.toggle()
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(isFavorite ? .red : .gray.opacity(0.6))
            }
            .buttonStyle(.plain)
            .padding(9)
        }
    }

    private static let brandGreen = Color(red: 0.20, green: 0.53, blue: 0.15)

    @ViewBuilder
    private var addControl: some View {
        if quantityInCart == 0 {
            Button(action: onIncrement) {
                VStack(spacing: 0) {
                    
                    let showOptions = product.recommendedQuantity(using: appState.localOrders) ?? 0 > 1
                    
                    // Top button
                    Text("ADD")
                        .font(.system(size: 13.5, weight: .black, design: .rounded))
                        .foregroundStyle(Self.brandGreen)
                        .frame(maxWidth: .infinity)
                        .frame(height: showOptions ? 22 : 32)
                        .background(Color.white)
                    
                    // Bottom options bar
                    if showOptions {
                        Text("2 options")
                            .font(.system(size: 6, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 10)
                            .background(Self.brandGreen)
                    }
                }
                .frame(width: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Self.brandGreen, lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.08), radius: 5, y: 2)
            }
            .buttonStyle(.plain)
        } else {
            HStack(spacing: 0) {
                Button(action: onDecrement) {
                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 22, height: 32)
                        .contentShape(Rectangle())
                }

                Text("\(quantityInCart)")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .frame(width: 20)

                Button(action: onIncrement) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 22, height: 32)
                        .contentShape(Rectangle())
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .frame(width: 64, height: 32)
            .background(Self.brandGreen, in: RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.12), radius: 5, y: 2)
        }
    }
}

#Preview {
    NavigationStack {
        CategoryDetailView(
            category: StoreCategory(title: "Vegetables &\nFruits", imageName: "BlinkitVegetables")
        )
    }
    .environment(AppState())
}
