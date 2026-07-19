import SwiftUI

struct NewSubscriptionView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var catalog: [Product] = []
    @State private var selectedQuantities: [String: Int] = [:]
    @State private var isShowingProductPicker = false

    @State private var frequencyMode: FrequencyMode = .daily
    @State private var selectedSpecificDays: Set<Weekday> = []
    @State private var selectedWeeklyDay: Weekday = .monday
    @State private var monthlyDay: Int = 1

    @State private var selectedSlot: DeliverySlot = DeliverySlot.all[0]
    @State private var totalDeliveries: Int = 8

    @State private var doNotRingBell = false
    @State private var leaveAtDoor = false
    @State private var remindDayBefore = true

    @State private var showAddressAlert = false
    @State private var showStartedAlert = false

    private static let hardcodedAddress = "Zomato Office Farmhouse, Chhatarpur Farms, DLF Farms, New Delhi, Delhi 110030"

    private enum FrequencyMode: String, CaseIterable, Identifiable {
        case daily = "Daily"
        case specificDays = "WeekDays"
        case weekly = "Weekly"
        case monthly = "Monthly"
        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                productsSection
                frequencySection
                slotSection
                deliveriesSection
                addressSection
                preferencesSection
                billSection
                summarySection
            }
            .padding()
        }
        .tint(.black)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("New Subscription")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button(action: startSubscription) {
                Text("Start Subscription")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(canStart ? Color.accent : Color.gray.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(!canStart)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.white)
        }
        .sheet(isPresented: $isShowingProductPicker) {
            SubscriptionProductPickerSheet(catalog: catalog, selectedQuantities: $selectedQuantities)
        }
        .task {
            catalog = (try? await appState.catalogService.allProducts()) ?? []
        }
        .alert("This is a hackathon demo", isPresented: $showAddressAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Address editing isn't wired up — delivery address is fixed for this demo.")
        }
        .alert("Subscription started", isPresented: $showStartedAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your subscription is now active. Manage it anytime from the Subs tab.")
        }
    }

    // MARK: - Sections

    private var productsSection: some View {
        SectionCard(title: "Products") {
            if selectedItems.isEmpty {
                Text("No products selected yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 0) {
                    ForEach(selectedItems) { item in
                        ProductRow(
                            product: item.product,
                            subtitle: "₹\(Int(item.product.price * Double(item.quantity)))/delivery"
                        ) {
                            quantityStepper(for: item.product)
                        }
                        if item.id != selectedItems.last?.id {
                            Divider()
                        }
                    }
                }
            }

            Button {
                isShowingProductPicker = true
            } label: {
                Label(selectedItems.isEmpty ? "Select Products" : "Edit Products", systemImage: "cart.badge.plus")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.bordered)
            .tint(.black)
        }
    }

    private func quantityStepper(for product: Product) -> some View {
        HStack(spacing: 14) {
            Button {
                decrementQuantity(for: product)
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 11, weight: .bold))
            }

            Text("\(selectedQuantities[product.id] ?? 0)")
                .font(.subheadline.weight(.semibold))
                .frame(minWidth: 16)
            Button {
                incrementQuantity(for: product)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .bold))
            }
        }
        .foregroundStyle(.white)
        .frame(width: 76, height: 34)
        .background(.accent)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func incrementQuantity(for product: Product) {
        selectedQuantities[product.id, default: 0] += 1
    }

    private func decrementQuantity(for product: Product) {
        let current = selectedQuantities[product.id] ?? 0
        selectedQuantities[product.id] = current <= 1 ? nil : current - 1
    }

    private var frequencySection: some View {
        SectionCard(title: "Delivery Frequency") {
            Picker("Frequency", selection: $frequencyMode) {
                ForEach(FrequencyMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .tint(.black)

            switch frequencyMode {
            case .daily:
                Text("A delivery every day at your selected slot.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            case .specificDays:
                weekdayChips(selection: Binding(
                    get: { selectedSpecificDays },
                    set: { selectedSpecificDays = $0 }
                ))
                if selectedSpecificDays.isEmpty {
                    Text("Pick at least one day.")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

            case .weekly:
                weekdaySingleChips
                Text("A delivery every \(selectedWeeklyDay.fullLabel).")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            case .monthly:
                Stepper("Day \(monthlyDay) of every month", value: $monthlyDay, in: 1...28)
                    .font(.subheadline)
                    .tint(.black)
            }
        }
    }

    private func weekdayChips(selection: Binding<Set<Weekday>>) -> some View {
        HStack(spacing: 2) {
            ForEach(Weekday.allCases) { day in
                SelectableChip(label: day.shortLabel, isSelected: selection.wrappedValue.contains(day)) {
                    if selection.wrappedValue.contains(day) {
                        selection.wrappedValue.remove(day)
                    } else {
                        selection.wrappedValue.insert(day)
                    }
                }
            }
        }
    }

    private var weekdaySingleChips: some View {
        HStack(spacing: 2) {
            ForEach(Weekday.allCases) { day in
                SelectableChip(label: day.shortLabel, isSelected: selectedWeeklyDay == day) {
                    selectedWeeklyDay = day
                }
            }
        }
    }

    private var slotSection: some View {
        SectionCard(title: "Delivery Slot") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                ForEach(DeliverySlot.all) { slot in
                    SelectableChip(label: slot.label, isSelected: selectedSlot == slot) {
                        selectedSlot = slot
                    }
                }
            }
        }
    }

    private var deliveriesSection: some View {
        SectionCard(title: "Number of Deliveries") {
            HStack(spacing: 8) {
                ForEach([4, 8, 12, 24], id: \.self) { preset in
                    SelectableChip(label: "\(preset)", isSelected: totalDeliveries == preset) {
                        totalDeliveries = preset
                    }
                }
            }
            Stepper("\(totalDeliveries) deliveries", value: $totalDeliveries, in: 2...60)
                .font(.subheadline)
                .tint(.black)
        }
    }

    private var addressSection: some View {
        SectionCard(title: "Delivery Address") {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Home").font(.subheadline.weight(.semibold))
                    Text(Self.hardcodedAddress).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button("Change") { showAddressAlert = true }
                    .font(.caption.weight(.semibold))
                    .tint(.black)
            }
        }
    }

    private var preferencesSection: some View {
        SectionCard(title: "Delivery Preferences") {
            Toggle("Don't ring the bell", isOn: $doNotRingBell)
            Toggle("Leave at the door", isOn: $leaveAtDoor)
            Toggle("Remind me a day before delivery", isOn: $remindDayBefore)
        }
    }

    private var billSection: some View {
        SectionCard(title: "Bill Details") {
            if let draft = draftSubscription {
                billRow("Per-delivery amount", "₹\(Int(draft.perDeliveryAmount))")
                billRow("No. of deliveries", "× \(draft.totalDeliveries)")
                Divider()
                billRow("Items total", "₹\(Int(draft.itemsTotal))")
                billRow("Subscription savings (10%)", "-₹\(Int(draft.discountAmount))", valueColor: .accent)
                Divider()
                HStack {
                    Text("Total payable").font(.subheadline.weight(.bold))
                    Spacer()
                    Text("₹\(Int(draft.finalAmount))").font(.subheadline.weight(.bold))
                }
            } else {
                Text("Select products to see pricing.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var summarySection: some View {
        SectionCard(title: "Summary") {
            if let draft = draftSubscription {
                summaryRow("Start date", draft.startDate.formatted(date: .abbreviated, time: .omitted))
                summaryRow("End date", draft.endDate.formatted(date: .abbreviated, time: .omitted))
                summaryRow("Total deliveries", "\(draft.totalDeliveries)")
                summaryRow("Total amount", "₹\(Int(draft.finalAmount))")
            } else {
                Text("Complete the steps above to see your subscription summary.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func billRow(_ title: String, _ value: String, valueColor: Color = .primary) -> some View {
        HStack {
            Text(title).font(.system(size: 15)).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.system(size: 15)).foregroundStyle(valueColor)
        }
    }

    @ViewBuilder
    private func summaryRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline.weight(.semibold))
        }
    }

    // MARK: - Derived state

    private var selectedItems: [SubscriptionItem] {
        catalog.compactMap { product in
            guard let quantity = selectedQuantities[product.id], quantity > 0 else { return nil }
            return SubscriptionItem(product: product, quantity: quantity)
        }
    }

    private var resolvedFrequency: DeliveryFrequency {
        switch frequencyMode {
        case .daily: return .daily
        case .specificDays: return .specificDays(selectedSpecificDays)
        case .weekly: return .weekly(selectedWeeklyDay)
        case .monthly: return .monthly(dayOfMonth: monthlyDay)
        }
    }

    private var draftSubscription: Subscription? {
        guard !selectedItems.isEmpty else { return nil }
        return Subscription(
            items: selectedItems,
            frequency: resolvedFrequency,
            slot: selectedSlot,
            totalDeliveries: totalDeliveries,
            deliveriesCompleted: 0,
            startDate: Date(),
            address: Self.hardcodedAddress,
            preferences: SubscriptionPreferences(
                doNotRingBell: doNotRingBell,
                leaveAtDoor: leaveAtDoor,
                remindDayBefore: remindDayBefore
            ),
            status: .active
        )
    }

    private var canStart: Bool {
        guard !selectedItems.isEmpty else { return false }
        if frequencyMode == .specificDays && selectedSpecificDays.isEmpty { return false }
        return true
    }

    private func startSubscription() {
        guard let draft = draftSubscription else { return }
        appState.subscriptionStore.add(draft)
        showStartedAlert = true
    }
}
