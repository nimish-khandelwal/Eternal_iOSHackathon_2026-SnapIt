import SwiftUI

/// Confidence as a filled ring rather than a bare number — reads as more
/// considered for the same underlying value.
struct ConfidenceBadge: View {
    let confidence: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: 3)
            Circle()
                .trim(from: 0, to: confidence)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(confidence * 100))%")
                .font(.system(size: 9, weight: .semibold))
        }
        .frame(width: 32, height: 32)
    }
}
