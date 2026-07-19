import SwiftUI

/// Shared capture screen for all three modes — a live camera preview with a
/// corner-bracket viewfinder, mode label, shutter, and a gallery fallback.
struct ScanCaptureScreen: View {
    let title: String
    let subtitle: String
    let onCapture: (UIImage) -> Void

    @StateObject private var camera = CameraModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            CameraPreviewLayer(session: camera.session)
                .ignoresSafeArea()

            VStack {
                modeLabel
                Spacer()
                CornerBrackets()
                    .frame(width: 280, height: 280)
                Spacer()
                controls
            }
        }
        .onAppear { camera.configure() }
        .onDisappear { camera.stop() }
    }

    private var modeLabel: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .foregroundStyle(.white)
        .padding(.top, 24)
    }

    private var controls: some View {
        HStack(spacing: 44) {
            PhotoPickerButton(onPick: onCapture)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)

            Button {
                camera.capturePhoto { image in
                    if let image { onCapture(image) }
                }
            } label: {
                Circle()
                    .fill(.white)
                    .frame(width: 68, height: 68)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.6), lineWidth: 3)
                            .frame(width: 80, height: 80)
                    )
            }

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.bottom, 36)
    }
}

/// Four L-shaped corner marks — a lighter-weight, more camera-native
/// viewfinder cue than a plain rounded rectangle outline.
private struct CornerBrackets: View {
    var body: some View {
        GeometryReader { geo in
            let length: CGFloat = 28
            let w = geo.size.width
            let h = geo.size.height

            Path { path in
                path.move(to: CGPoint(x: 0, y: length))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: length, y: 0))

                path.move(to: CGPoint(x: w - length, y: 0))
                path.addLine(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w, y: length))

                path.move(to: CGPoint(x: w, y: h - length))
                path.addLine(to: CGPoint(x: w, y: h))
                path.addLine(to: CGPoint(x: w - length, y: h))

                path.move(to: CGPoint(x: length, y: h))
                path.addLine(to: CGPoint(x: 0, y: h))
                path.addLine(to: CGPoint(x: 0, y: h - length))
            }
            .stroke(Color.white.opacity(0.85), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        }
    }
}
