import SwiftUI

struct SnapProductView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: SnapProductViewModel?

    var body: some View {
        Group {
            switch viewModel?.phase ?? .capture {
            case .capture:
                ScanCaptureScreen(title: "Snap Product", subtitle: "Point at a single item") { image in
                    Task { await viewModel?.analyze(image: image) }
                }
            case .analyzing:
                if let image = viewModel?.capturedImage {
                    ScanningOverlay(image: image)
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
        VStack(spacing: 20) {
            if let image = viewModel?.capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            if let detected = viewModel?.detectedProduct {
                if let product = detected.matchedProduct {
                    VStack(spacing: 8) {
                        Text(product.name).font(.title3.weight(.semibold))
                        Text("\(product.unit) · ₹\(Int(product.price))").foregroundStyle(.secondary)
                        ConfidenceBadge(confidence: detected.confidence)
                    }

                    Button {
                        appState.cartStore.add([product])
                    } label: {
                        Label("Add to Cart", systemImage: "cart.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                } else {
                    Text("Detected \"\(detected.name)\" but couldn't match it to a Blinkit product.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
            }

            Button("Scan Again") { viewModel?.retry() }
                .buttonStyle(.bordered)
        }
        .padding(24)
    }
}
