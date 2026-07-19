import PhotosUI
import SwiftUI

/// Gallery fallback for the camera — also what keeps the simulator usable
/// during development, since it has no real camera.
struct PhotoPickerButton: View {
    var onPick: (UIImage) -> Void

    @State private var selection: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selection, matching: .images) {
            Image(systemName: "photo.on.rectangle")
        }
        .onChange(of: selection) { _, newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    onPick(image)
                }
                selection = nil
            }
        }
    }
}
