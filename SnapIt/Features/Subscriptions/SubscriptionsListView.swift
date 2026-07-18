import SwiftUI

struct SubscriptionsListView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                startNewCard

                if appState.subscriptionStore.subscriptions.isEmpty {
                    ContentUnavailableView(
                        "No subscriptions yet",
                        systemImage: "arrow.triangle.2.circlepath",
                        description: Text("Start a subscription to get your essentials delivered automatically.")
                    )
                    .padding(.top, 40)
                } else {
                    ForEach(appState.subscriptionStore.subscriptions) { subscription in
                        SubscriptionRow(
                            subscription: subscription,
                            onPause: { appState.subscriptionStore.pause(subscription.id) },
                            onResume: { appState.subscriptionStore.resume(subscription.id) },
                            onStop: { appState.subscriptionStore.stop(subscription.id) }
                        )
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Subscriptions")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var startNewCard: some View {
        NavigationLink {
            NewSubscriptionView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Start New Subscription")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
            }
            .foregroundStyle(.white)
            .padding(16)
            .background(Color.green, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

private struct SubscriptionRow: View {
    let subscription: Subscription
    let onPause: () -> Void
    let onResume: () -> Void
    let onStop: () -> Void

    @State private var pendingAction: PendingAction?

    private enum PendingAction: Identifiable {
        case pause, resume, stop
        var id: Self { self }
    }

    var body: some View {
        NavigationLink {
            SubscriptionDetailView(subscriptionID: subscription.id)
        } label: {
            content
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            if subscription.canManage {
                Menu {
                    if subscription.status == .active {
                        Button("Pause Subscription", systemImage: "pause.circle") {
                            pendingAction = .pause
                        }
                    } else {
                        Button("Resume Subscription", systemImage: "play.circle") {
                            pendingAction = .resume
                        }
                    }
                    Button("Stop Subscription", systemImage: "xmark.circle", role: .destructive) {
                        pendingAction = .stop
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .padding(8)
            }
        }
        .alert(
            confirmTitle,
            isPresented: Binding(
                get: { pendingAction != nil },
                set: { if !$0 { pendingAction = nil } }
            )
        ) {
            Button("Cancel", role: .cancel) { pendingAction = nil }
            Button(confirmButtonLabel, role: pendingAction == .stop ? .destructive : nil) {
                switch pendingAction {
                case .pause: onPause()
                case .resume: onResume()
                case .stop: onStop()
                case .none: break
                }
                pendingAction = nil
            }
        } message: {
            Text(confirmMessage)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(subscription.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Spacer(minLength: 12)
                SubscriptionStatusPill(status: subscription.status)
            }
            // Reserves room for the topTrailing "⋯" overlay so the pill
            // never sits underneath its tap target.
            .padding(.trailing, subscription.canManage ? 32 : 0)

            HStack(spacing: 6) {
                ForEach(subscription.items.prefix(4)) { item in
                    Text(item.product.emoji)
                        .font(.system(size: 18))
                        .frame(width: 30, height: 30)
                        .background(item.product.categoryColor.opacity(0.15), in: Circle())
                }
                if subscription.items.count > 4 {
                    Text("+\(subscription.items.count - 4)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            Text("\(subscription.frequency.summary) · \(subscription.slot.label)")
                .font(.caption)
                .foregroundStyle(.secondary)

            ProgressView(value: Double(subscription.deliveriesCompleted), total: Double(subscription.totalDeliveries))
                .tint(.green)

            Text("\(subscription.deliveriesCompleted) of \(subscription.totalDeliveries) deliveries")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.gray.opacity(0.08))
        }
    }

    private var confirmTitle: String {
        switch pendingAction {
        case .pause: return "Pause this subscription?"
        case .resume: return "Resume this subscription?"
        case .stop: return "Stop this subscription?"
        case .none: return ""
        }
    }

    private var confirmMessage: String {
        switch pendingAction {
        case .pause: return "Deliveries will stop until you resume it. You can resume anytime."
        case .resume: return "Deliveries will continue on the existing schedule."
        case .stop: return "This can't be undone — you'll need to start a new subscription to resume this plan."
        case .none: return ""
        }
    }

    private var confirmButtonLabel: String {
        switch pendingAction {
        case .pause: return "Pause"
        case .resume: return "Resume"
        case .stop: return "Stop"
        case .none: return ""
        }
    }
}
