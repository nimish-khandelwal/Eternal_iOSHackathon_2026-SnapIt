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
                if let viewModel {
                    appState.cartStore.add(viewModel.selectedProducts)
                }
            } label: {
                Label("Add All (\(viewModel?.selectedProducts.count ?? 0))", systemImage: "cart.badge.plus")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
            }
            .buttonStyle(.borderedProminent)
            .disabled((viewModel?.selectedProducts.isEmpty) ?? true)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.white)
        }
    }

    private func itemCard(for item: ShoppingListViewModel.ChecklistItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                if let product = item.detected.matchedProduct {
                    ProductRow(product: product, subtitle: subtitle(for: item.detected))
                } else {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 44, height: 44)
                            .overlay(Image(systemName: "questionmark").foregroundStyle(.orange))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.detected.name).font(.subheadline.weight(.medium))
                            Text("not in the Blinkit catalog yet")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer(minLength: 8)

                Button {
                    toggleIncluded(item)
                } label: {
                    Image(systemName: item.isIncluded ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(item.isIncluded ? Color.green : .secondary)
                }
                .buttonStyle(.plain)
            }
            .opacity(item.isIncluded ? 1 : 0.4)

            if !item.candidateProducts.isEmpty {
                ManualMatchPicker(candidates: item.candidateProducts)
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

    private func subtitle(for detected: DetectedProduct) -> String {
        detected.confidence < ProductMatcher.lowConfidenceThreshold
            ? "detected as \"\(detected.name)\" · \(Int(detected.confidence * 100))% confidence"
            : "detected as \"\(detected.name)\""
    }

    private func toggleIncluded(_ item: ShoppingListViewModel.ChecklistItem) {
        guard let index = viewModel?.items.firstIndex(where: { $0.id == item.id }) else { return }
        viewModel?.items[index].isIncluded.toggle()
    }
}
