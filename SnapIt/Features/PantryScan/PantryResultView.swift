import SwiftUI

struct PantryResultView: View {
    @Environment(AppState.self) private var appState
    var viewModel: PantryScanViewModel

    @State private var showNotDetected = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    if !viewModel.likelyRunningLow.isEmpty {
                        resultSection(title: "Likely Running Low", results: viewModel.likelyRunningLow)
                    }

                    if !viewModel.stillAvailable.isEmpty {
                        resultSection(title: "Still Available", results: viewModel.stillAvailable)
                    }

                    if !viewModel.notDetected.isEmpty {
                        notDetectedSection
                    }

                    if !viewModel.unrecognizedDetections.isEmpty {
                        unrecognizedSection
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))

            AddToCartButton(
                title: "Add Missing Items (\(viewModel.likelyRunningLow.count))",
                systemImage: "cart.badge.plus",
                isDisabled: viewModel.likelyRunningLow.isEmpty
            ) {
                appState.cartStore.add(viewModel.likelyRunningLow.map(\.product))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.white)
        }
    }

    private func resultSection(title: String, results: [PantryComparisonResult]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(title)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(results) { result in
                    VStack(alignment: .leading, spacing: 10) {
                        ProductRow(product: result.product, subtitle: subtitle(for: result)) {
                            StatusPill(status: result.status)
                        }

                        if let candidates = viewModel.candidates(forMatchedProductID: result.product.id), !candidates.isEmpty {
                            ManualMatchPicker(candidates: candidates)
                                .padding(.bottom, 8)
                        }
                    }
                    if result.id != results.last?.id {
                        Divider().padding(.leading, 12)
                    }
                }
            }
            .padding(12)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.gray.opacity(0.08))
            }
        }
    }

    private var notDetectedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation { showNotDetected.toggle() }
            } label: {
                HStack {
                    sectionHeader("Not Detected (\(viewModel.notDetected.count))")
                    Spacer()
                    Image(systemName: showNotDetected ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if showNotDetected {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.notDetected) { result in
                        ProductRow(product: result.product, subtitle: subtitle(for: result)) {
                            StatusPill(status: result.status)
                        }
                        if result.id != viewModel.notDetected.last?.id {
                            Divider().padding(.leading, 12)
                        }
                    }
                }
                .padding(12)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.gray.opacity(0.08))
                }
            }
        }
    }

    private var unrecognizedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Seen but Unrecognized (\(viewModel.unrecognizedDetections.count))")

            VStack(alignment: .leading, spacing: 14) {
                ForEach(viewModel.unrecognizedDetections) { item in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.orange.opacity(0.15))
                                .frame(width: 44, height: 44)
                                .overlay(Image(systemName: "questionmark").foregroundStyle(.orange))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.detected.name)
                                    .font(.subheadline.weight(.medium))
                                Text("\(Int(item.detected.confidence * 100))% confidence · not in the Blinkit catalog yet")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        if !item.candidates.isEmpty {
                            ManualMatchPicker(candidates: item.candidates)
                        }
                    }
                    if item.id != viewModel.unrecognizedDetections.last?.id {
                        Divider()
                    }
                }
            }
            .padding(12)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.gray.opacity(0.08))
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.secondary)
            .tracking(0.5)
    }

    private func subtitle(for result: PantryComparisonResult) -> String {
        switch result.status {
        case .likelyRunningLow:
            if let days = result.daysSinceLastOrder, let usual = result.usualFrequencyDays {
                return "last ordered \(days)d ago · usually every \(usual)d"
            }
            return "usually in your cart"
        case .stillAvailable:
            if let confidence = result.detectionConfidence {
                return "detected · \(Int(confidence * 100))% confidence"
            }
            return "detected in frame"
        case .notDetected:
            if let days = result.daysSinceLastOrder {
                return "last ordered \(days)d ago"
            }
            return "not seen this scan"
        }
    }
}
