import SwiftUI

/// Status carried as color AND shape/label, never color alone.
struct StatusPill: View {
    let status: RefillStatus

    private var tint: Color {
        switch status {
        case .likelyRunningLow: return .red
        case .stillAvailable: return .green
        case .notDetected: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(tint).frame(width: 6, height: 6)
            Text(status.rawValue)
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(tint.opacity(0.15), in: Capsule())
        .foregroundStyle(tint)
    }
}
