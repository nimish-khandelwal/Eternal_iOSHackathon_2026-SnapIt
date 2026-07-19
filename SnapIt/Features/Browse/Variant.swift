//
//  Variant.swift
//  SnapIt
//
//  Created by Prince on 19/07/26.
//

import SwiftUI
import Combine

struct ProductOptionsSheet: View {

    let product: Product
    let onSelect: (Product) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var sheetHeight: CGFloat = 340

    var body: some View {

        VStack(spacing: 6) {

            VStack(alignment: .leading, spacing: 18) {

                HStack(alignment: .center, spacing: 8) {
                    Text(product.name)
                        .font(.system(size: 18, weight: .black))
                        .padding(.horizontal, 4)

                    Spacer(minLength: 8)

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(width: 38, height: 38)
                            .background(.white, in: Circle())
                            .shadow(color: .black.opacity(0.14), radius: 6, y: 2)
                    }
                    .buttonStyle(.plain)
                }

                if let recommended = product.recommendedQuantity(using: appState.localOrders),
                   recommended > 1 {

                    ProductOptionRow(
                        product: product,
                        quantity: recommended,
                        isRecommended: true
                    ) {
                        for _ in 0..<recommended {
                            appState.cartStore.add([product])
                        }
                        dismiss()
                    }
                }

                ProductOptionRow(
                    product: product,
                    quantity: 1,
                    isRecommended: false
                ) {
                    appState.cartStore.add([product])
                    dismiss()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { newHeight in
            sheetHeight = newHeight
        }
        .presentationDetents([.height(sheetHeight)])
        .presentationBackground(Color(.systemGroupedBackground))
        .presentationCornerRadius(28)
        .presentationDragIndicator(.hidden)
    }
}

struct ProductOptionRow: View {
    let product: Product
    let quantity: Int
    let isRecommended: Bool
    let onAdd: () -> Void
    
    @State private var isShowingRecommendationInfo = false


    private var totalPrice: Double {
        product.price * Double(quantity)
    }

    private var totalMRP: Double {
        (product.mrp ?? product.price * 1.2) * Double(quantity)
    }

    private var discountPercent: Int {
        Int(round((1 - totalPrice / totalMRP) * 100))
    }

    var body: some View {
        HStack(spacing: 14) {

            // MARK: Image

            ZStack(alignment: .topLeading) {

                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
                    .frame(width: 45, height: 45)

                Text(product.emoji)
                    .font(.system(size: 32))
                    .frame(width: 42, height: 42)

                if discountPercent > 0 {
                    Text("\(discountPercent)%\nOFF")
                        .font(.system(size: 6, weight: .black))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 3)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .offset(x: -4, y: -4)
                }
            }

            // MARK: Details

            VStack(alignment: .leading, spacing: 4) {
                
                if isRecommended {
                    HStack(spacing: 4) {
                        Text("Recommended Quantity")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.accent)
                        
                        
                        Button {
                            isShowingRecommendationInfo = true
                        } label: {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.accent)
                        }
                        .buttonStyle(.plain)
                    }
                    
                }

                Text(quantity == 1
                     ? product.unit
                     : "\(quantity) × \(product.unit)")
                    .font(.system(size: 12, weight: .medium))

                HStack(spacing: 6) {

                    Text("₹\(Int(totalPrice.rounded()))")
                        .font(.system(size: 12, weight: .bold))

                    Text("₹\(Int(totalMRP.rounded()))")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .strikethrough()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // MARK: Add button

            Button(action: onAdd) {

                Text("ADD")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(.accent)
                    .frame(width: 64, height: 32)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.accent, lineWidth: 2)
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .alert("Recommended quantity", isPresented: $isShowingRecommendationInfo) {
            Button("Got it", role: .cancel) { }
        } message: {
            Text("""
            You usually order \(quantity) × \(product.name).

            Adding the recommended quantity helps reduce the chance of running out and needing to reorder sooner.
            """)
        }
    }
}

#Preview("Options sheet") {

    let appState = AppState()

    let product = Product(
        id: "amul-dishwash-gel-1",
        name: "Amul Dishwash Gel",
        synonyms: [],
        category: "Cleaning",
        price: 24,
        unit: "500 g",
        emoji: "🧴",
        mrp: 25
    )

    // Seed one past order so the "Recommended Quantity" row appears
    // (history store is in-memory during previews).
    appState.localOrders.recordOrder(items: [
        CartItem(product: product, quantity: 5)
    ])

    return PreviewSheetHost(product: product)
        .environment(appState)
}

/// Presents the sheet the same way CategoryDetailView does, so the
/// self-sizing detent and ✕ button render true to life in the canvas.
private struct PreviewSheetHost: View {
    let product: Product
    @State private var isPresented = true

    var body: some View {
        Color(.systemGray5)
            .ignoresSafeArea()
            .sheet(isPresented: $isPresented) {
                ProductOptionsSheet(product: product) { _ in }
            }
    }
}
