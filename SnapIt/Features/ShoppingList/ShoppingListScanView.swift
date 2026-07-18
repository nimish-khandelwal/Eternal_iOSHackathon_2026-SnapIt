import SwiftUI

struct ShoppingListScanView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: ShoppingListViewModel?

    var body: some View {
        Group {
            switch viewModel?.phase ?? .capture {
            case .capture:
                ScanCaptureScreen(title: "Shopping List", subtitle: "Photograph a list or receipt") { image in
                    Task { await viewModel?.analyze(image: image) }
                }
            case .analyzing:
                if let image = viewModel?.capturedImage {
                    ScanningOverlay(image: image)
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
            List {
                ForEach(viewModel?.items ?? []) { item in
                    row(for: item)
                }
            }
            .listStyle(.plain)

            Button {
                if let viewModel {
                    appState.cartStore.add(viewModel.selectedProducts)
                }
            } label: {
                Label("Add All (\(viewModel?.selectedProducts.count ?? 0))", systemImage: "cart.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled((viewModel?.selectedProducts.isEmpty) ?? true)
            .padding()
        }
    }

    private func row(for item: ShoppingListViewModel.ChecklistItem) -> some View {
        HStack {
            if let product = item.detected.matchedProduct {
                ProductRow(product: product, subtitle: "detected as \"\(item.detected.name)\"")
            } else {
                Text(item.detected.name)
            }
            Spacer()
            Image(systemName: item.isIncluded ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(item.isIncluded ? Color.accentColor : .secondary)
        }
        .contentShape(Rectangle())
        .opacity(item.isIncluded ? 1 : 0.4)
        .onTapGesture {
            guard let index = viewModel?.items.firstIndex(where: { $0.id == item.id }) else { return }
            viewModel?.items[index].isIncluded.toggle()
        }
    }
}
