import SwiftUI

/// Same browse-and-quantity pattern as `BrowseView`, scoped to a local
/// selection rather than the live cart — used while assembling a subscription.
struct SubscriptionProductPickerSheet: View {
    let catalog: [Product]
    @Binding var selectedQuantities: [String: Int]

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: String?

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                categoryChips

                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredProducts) { product in
                        ProductCard(
                            product: product,
                            quantityInCart: selectedQuantities[product.id] ?? 0,
                            onIncrement: {
                                selectedQuantities[product.id, default: 0] += 1
                            },
                            onDecrement: {
                                let current = selectedQuantities[product.id] ?? 0
                                selectedQuantities[product.id] = current <= 1 ? nil : current - 1
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .navigationTitle("Select Products")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search milk, atta, chips…")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var categories: [String] {
        Array(Set(catalog.map(\.category))).sorted()
    }

    private var filteredProducts: [Product] {
        catalog.filter { product in
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
                SelectableChip(label: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(categories, id: \.self) { category in
                    SelectableChip(label: category, isSelected: selectedCategory == category) {
                        selectedCategory = (selectedCategory == category) ? nil : category
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}
