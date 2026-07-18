import SwiftUI

struct SubscriptionDetailView: View {
    @Environment(AppState.self) private var appState
    let subscriptionID: Subscription.ID

    @State private var pendingAction: PendingAction?

    private enum PendingAction: Identifiable {
        case pause, resume, stop
        var id: Self { self }
    }

    private var subscription: Subscription? {
        appState.subscriptionStore.subscriptions.first { $0.id == subscriptionID }
    }

    var body: some View {
        Group {
            if let subscription {
                ScrollView {
                    VStack(spacing: 16) {
                        progressCard(for: subscription)
                        productsCard(for: subscription)
                        preferencesCard(for: subscription)
                        addressCard(for: subscription)
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
                .safeAreaInset(edge: .bottom) {
                    actionBar(for: subscription)
                }
                .navigationTitle(subscription.title)
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView("Subscription not found", systemImage: "questionmark.circle")
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
                case .pause: appState.subscriptionStore.pause(subscriptionID)
                case .resume: appState.subscriptionStore.resume(subscriptionID)
                case .stop: appState.subscriptionStore.stop(subscriptionID)
                case .none: break
                }
                pendingAction = nil
            }
        } message: {
            Text(confirmMessage)
        }
    }

    private func progressCard(for subscription: Subscription) -> some View {
        SectionCard(title: "Delivery Progress") {
            HStack {
                SubscriptionStatusPill(status: subscription.status)
                Spacer()
                Text("\(subscription.frequency.summary) · \(subscription.slot.label)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: Double(subscription.deliveriesCompleted), total: Double(subscription.totalDeliveries))
                .tint(.green)

            Text("\(subscription.deliveriesCompleted) of \(subscription.totalDeliveries) deliveries completed")
                .font(.caption)
                .foregroundStyle(.secondary)

            if subscription.status == .active, let next = subscription.nextDeliveryDate {
                Text("Next delivery: \(next.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
            }

            Divider()

            HStack {
                Text("Started")
                Spacer()
                Text(subscription.startDate.formatted(date: .abbreviated, time: .omitted))
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack {
                Text("Ends")
                Spacer()
                Text(subscription.endDate.formatted(date: .abbreviated, time: .omitted))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private func productsCard(for subscription: Subscription) -> some View {
        SectionCard(title: "Products") {
            VStack(spacing: 0) {
                ForEach(subscription.items) { item in
                    ProductRow(
                        product: item.product,
                        subtitle: "Qty \(item.quantity) · ₹\(Int(item.product.price * Double(item.quantity)))/delivery"
                    )
                    if item.id != subscription.items.last?.id {
                        Divider()
                    }
                }
            }

            Divider()

            HStack {
                Text("Per-delivery amount")
                Spacer()
                Text("₹\(Int(subscription.perDeliveryAmount))")
            }
            .font(.caption.weight(.semibold))
        }
    }

    private func preferencesCard(for subscription: Subscription) -> some View {
        SectionCard(title: "Delivery Preferences") {
            preferenceRow("Don't ring the bell", isOn: subscription.preferences.doNotRingBell)
            preferenceRow("Leave at the door", isOn: subscription.preferences.leaveAtDoor)
            preferenceRow("Remind a day before delivery", isOn: subscription.preferences.remindDayBefore)
        }
    }

    private func preferenceRow(_ title: String, isOn: Bool) -> some View {
        HStack {
            Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isOn ? .green : .secondary)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(isOn ? .primary : .secondary)
                .multilineTextAlignment(.leading)
        }
    }

    private func addressCard(for subscription: Subscription) -> some View {
        SectionCard(title: "Delivery Address") {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(.green)
                Text(subscription.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
        }
    }

    @ViewBuilder
    private func actionBar(for subscription: Subscription) -> some View {
        if subscription.canManage {
            HStack(spacing: 12) {
                Button {
                    pendingAction = subscription.status == .active ? .pause : .resume
                } label: {
                    Label(
                        subscription.status == .active ? "Pause" : "Resume",
                        systemImage: subscription.status == .active ? "pause.fill" : "play.fill"
                    )
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                }
                .buttonStyle(.bordered)
                .tint(subscription.status == .active ? .orange : .green)

                Button {
                    pendingAction = .stop
                } label: {
                    Label("Stop", systemImage: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.white)
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
