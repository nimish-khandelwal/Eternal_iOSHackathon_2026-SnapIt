import SwiftUI

struct ShoppingListScanView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: ShoppingListViewModel?

    var body: some View {
        Group {
            switch viewModel?.phase ?? .capture {
            case .capture:
                ScanCaptureScreen(title: "Shopping List", subtitle: "Text only — photograph a list or receipt") { image in
                    Task { await viewModel?.analyze(image: image) }
                }
            case .analyzing:
                if let image = viewModel?.capturedImage {
                    ScanningOverlay(image: image, captions: [
                        "Reading your list…",
                        "Transcribing items…",
                        "Matching to catalog…"
                    ])
                }
            case .results:
                resultList
            case .error(let message):
                ErrorStateView(message: message) { viewModel?.retry() }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ShoppingListViewModel(
                    visionService: appState.visionService,
                    catalogService: appState.catalogService
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var resultList: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel?.items ?? []) { item in
                        itemCard(for: item)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))

            Button {
                appState.requestedTabAfterAction = 4
            } label: {
                Text("Done")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.white)
        }
    }

    private func itemCard(for item: ShoppingListViewModel.ChecklistItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "text.viewfinder")
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\"\(item.detected.name)\"")
                        .font(.subheadline.weight(.medium))
                    Text("Pick the actual product below")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                ConfidenceBadge(confidence: item.detected.confidence)
            }

            if !item.candidateProducts.isEmpty {
                ManualMatchPicker(candidates: item.candidateProducts)
            } else {
                Text("No close matches in the Blinkit catalog yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
