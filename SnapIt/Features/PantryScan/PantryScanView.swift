import SwiftUI

struct PantryScanView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: PantryScanViewModel?

    var body: some View {
        Group {
            switch viewModel?.phase ?? .capture {
            case .capture:
                ScanCaptureScreen(title: "Pantry Scan", subtitle: "Show us your fridge or shelf") { image in
                    Task { await viewModel?.analyze(image: image) }
                }
            case .analyzing:
                if let image = viewModel?.capturedImage {
                    ScanningOverlay(image: image)
                }
            case .results:
                if let viewModel {
                    PantryResultView(viewModel: viewModel)
                }
            case .error(let message):
                ErrorStateView(message: message) { viewModel?.retry() }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = PantryScanViewModel(
                    visionService: appState.visionService,
                    catalogService: appState.catalogService,
                    purchaseHistoryService: appState.purchaseHistoryService
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
