import SwiftUI

struct PantryResultView: View {
    @Environment(AppState.self) private var appState
    var viewModel: PantryScanViewModel

    @State private var showNotDetected = false

    var body: some View {
        VStack(spacing: 0) {
            List {
                if !viewModel.likelyRunningLow.isEmpty {
                    Section("Likely Running Low") {
                        ForEach(viewModel.likelyRunningLow) { result in
                            ProductRow(product: result.product, subtitle: subtitle(for: result)) {
                                StatusPill(status: result.status)
                            }
                        }
                    }
                }

                if !viewModel.stillAvailable.isEmpty {
                    Section("Still Available") {
                        ForEach(viewModel.stillAvailable) { result in
                            ProductRow(product: result.product, subtitle: subtitle(for: result)) {
                                StatusPill(status: result.status)
                            }
                        }
                    }
                }

                if !viewModel.notDetected.isEmpty {
                    Section {
                        if showNotDetected {
                            ForEach(viewModel.notDetected) { result in
                                ProductRow(product: result.product, subtitle: subtitle(for: result)) {
                                    StatusPill(status: result.status)
                                }
                            }
                        }
                    } header: {
                        Button {
                            withAnimation { showNotDetected.toggle() }
                        } label: {
                            HStack {
                                Text("Not Detected (\(viewModel.notDetected.count))")
                                Spacer()
                                Image(systemName: showNotDetected ? "chevron.up" : "chevron.down")
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.insetGrouped)

            Button {
                appState.cartStore.add(viewModel.likelyRunningLow.map(\.product))
            } label: {
                Label("Add Missing Items (\(viewModel.likelyRunningLow.count))", systemImage: "cart.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.likelyRunningLow.isEmpty)
            .padding()
        }
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
