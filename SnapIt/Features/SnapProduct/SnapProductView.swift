import SwiftUI

struct SnapProductView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: SnapProductViewModel?

    var body: some View {
        Group {
            switch viewModel?.phase ?? .capture {
            case .capture:
                ScanCaptureScreen(title: "Snap Product", subtitle: "Packaged or loose — we'll recognize it") { image in
                    Task { await viewModel?.analyze(image: image) }
                }
            case .analyzing:
                if let image = viewModel?.capturedImage {
                    ScanningOverlay(image: image, captions: [
                        "Reading the label…",
                        "Checking shape & color…",
                        "Matching to catalog…"
                    ])
                }
            case .results:
                resultCard
            case .error(let message):
                ErrorStateView(message: message) { viewModel?.retry() }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = SnapProductViewModel(
                    visionService: appState.visionService,
                    catalogService: appState.catalogService
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var resultCard: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let image = viewModel?.capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }

                if let detected = viewModel?.detectedProduct {
                    SectionCard(title: detected.matchedProduct != nil ? "Detected Product" : "Couldn't Match") {
                        detectionSummary(for: detected)
                    }

                    if let candidates = viewModel?.candidateProducts, !candidates.isEmpty {
                        ManualMatchPicker(candidates: candidates)
                    }
                }

                Button("Scan Again") { viewModel?.retry() }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private func detectionSummary(for detected: DetectedProduct) -> some View {
        if let product = detected.matchedProduct {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(product.categoryColor.opacity(0.15))
                    .frame(width: 64, height: 64)
                    .overlay(Text(product.emoji).font(.system(size: 30)))

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name).font(.headline)
                    Text("\(product.unit) · ₹\(Int(product.price))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                ConfidenceBadge(confidence: detected.confidence)
            }

            AddToCartButton(title: "Add to Cart", systemImage: "cart.badge.plus") {
                appState.cartStore.add([product])
            }
        } else {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundStyle(.orange)
                Text("We saw \"\(detected.name)\" but couldn't match it to a catalog product.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
