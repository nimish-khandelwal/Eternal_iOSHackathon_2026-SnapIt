import SwiftUI

/// Masks the 1-4s vision API call as perceived progress rather than dead time.
struct ScanningOverlay: View {
    let image: UIImage
    var captions: [String] = ["Reading labels…", "Recognizing products…"]

    @State private var captionIndex = 0
    @State private var shimmerUp = false

    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.35))

            GeometryReader { geo in
                LinearGradient(
                    colors: [.clear, .white.opacity(0.35), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 160)
                .offset(y: shimmerUp ? -geo.size.height : geo.size.height)
                .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: shimmerUp)
            }
            .ignoresSafeArea()

            VStack {
                Spacer()
                ProgressView()
                    .tint(.white)
                    .padding(.bottom, 12)
                Text(captions[captionIndex])
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(.black.opacity(0.4), in: Capsule())
                    .padding(.bottom, 90)
            }
        }
        .onAppear { shimmerUp = true }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                captionIndex = (captionIndex + 1) % captions.count
            }
        }
    }
}
