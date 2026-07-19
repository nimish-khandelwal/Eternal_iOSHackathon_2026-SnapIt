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
                    SectionCard(title: "What We Saw") {
                        detectionSummary(for: detected)
                    }

                    if let candidates = viewModel?.candidateProducts, !candidates.isEmpty {
                        ManualMatchPicker(candidates: candidates)
                    } else {
                        Text("No close matches in the Blinkit catalog yet.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
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

    private func detectionSummary(for detected: DetectedProduct) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "text.viewfinder")
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text("\"\(detected.name)\"")
                    .font(.subheadline.weight(.medium))
                Text("Pick the actual product below")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ConfidenceBadge(confidence: detected.confidence)
        }
    }
}
