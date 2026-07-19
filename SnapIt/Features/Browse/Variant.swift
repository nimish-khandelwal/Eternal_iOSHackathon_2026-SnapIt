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

    var body: some View {

        NavigationStack {
            ScrollView {

                VStack(alignment: .leading, spacing: 18) {

                    Text(product.name)
                        .font(.system(size: 16, weight: .black))
                        .padding(.horizontal)

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
            }
            .background(Color(.systemGroupedBackground))
        }
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
