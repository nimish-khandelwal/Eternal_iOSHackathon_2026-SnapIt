import SwiftUI

/// The Blinkit-style browse/search experience — a scrollable, filterable grid
/// sitting alongside the three camera-driven modes, so the catalog feels real
/// even when you're not pointing a camera at anything.
struct BrowseView: View {
    @Environment(AppState.self) private var appState

    @State private var allProducts: [Product] = []
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var isLoading = true

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredProducts.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                ScrollView {
                    categoryChips

                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredProducts) { product in
                            ProductCard(
                                product: product,
                                quantityInCart: appState.cartStore.quantity(for: product),
                                onIncrement: { appState.cartStore.add([product]) },
                                onDecrement: { appState.cartStore.decrement(product) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Browse")
        .searchable(text: $searchText, prompt: "Search milk, atta, chips…")
        .task {
            allProducts = (try? await appState.catalogService.allProducts()) ?? []
            isLoading = false
        }
    }

    private var categories: [String] {
        Array(Set(allProducts.map(\.category))).sorted()
    }

    private var filteredProducts: [Product] {
        allProducts.filter { product in
            let matchesCategory = selectedCategory == nil || product.category == selectedCategory
            let matchesSearch = searchText.isEmpty
                || product.name.localizedCaseInsensitiveContains(searchText)
                || product.synonyms.contains { $0.localizedCaseInsensitiveContains(searchText) }
            return matchesCategory && matchesSearch
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryChip(title: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(categories, id: \.self) { category in
                    CategoryChip(title: category, isSelected: selectedCategory == category) {
                        selectedCategory = (selectedCategory == category) ? nil : category
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}

private struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground), in: Capsule())
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}
