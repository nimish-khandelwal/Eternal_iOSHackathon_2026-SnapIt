import SwiftUI

struct SubscriptionStatusPill: View {
    let status: SubscriptionStatus

    private var tint: Color {
        switch status {
        case .active: return .green
        case .paused: return .orange
        case .stopped: return .gray
        case .finished: return .blue
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

/// A single tappable pill used for weekday pickers, delivery slots, and
/// delivery-count presets throughout the subscription flow.
struct SelectableChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(minWidth: 40)
                .background(isSelected ? Color.black : Color(.secondarySystemBackground), in: Capsule())
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

/// White rounded card shell shared by every section of the subscription
/// screens — matches the card style already established in CartView.
struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
            content
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.gray.opacity(0.08))
        }
    }
}
