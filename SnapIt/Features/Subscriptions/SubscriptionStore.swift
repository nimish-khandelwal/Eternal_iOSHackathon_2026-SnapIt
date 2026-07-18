import Foundation

@Observable
final class SubscriptionStore {
    private(set) var subscriptions: [Subscription]

    init(subscriptions: [Subscription] = SubscriptionStore.dummySubscriptions()) {
        self.subscriptions = subscriptions
    }

    func add(_ subscription: Subscription) {
        subscriptions.insert(subscription, at: 0)
    }

    func pause(_ id: Subscription.ID) { setStatus(id, to: .paused) }
    func resume(_ id: Subscription.ID) { setStatus(id, to: .active) }
    func stop(_ id: Subscription.ID) { setStatus(id, to: .stopped) }

    private func setStatus(_ id: Subscription.ID, to status: SubscriptionStatus) {
        guard let index = subscriptions.firstIndex(where: { $0.id == id }) else { return }
        subscriptions[index].status = status
    }
}

extension SubscriptionStore {
    private static let demoAddress = "Zomato Office Farmhouse, Chhatarpur Farms, DLF Farms, New Delhi, Delhi 110030"

    static func dummySubscriptions() -> [Subscription] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        func daysAgo(_ n: Int) -> Date {
            calendar.date(byAdding: .day, value: -n, to: today) ?? today
        }

        let milk = Product(id: "milk-500ml", name: "Milk", synonyms: ["milk carton", "toned milk"], category: "Dairy", price: 33, unit: "500 ml", emoji: "🥛")
        let eggs = Product(id: "eggs-6pk", name: "Eggs", synonyms: ["egg tray"], category: "Eggs & Meat", price: 42, unit: "6 pcs", emoji: "🥚")
        let bread = Product(id: "bread-400g", name: "Bread", synonyms: ["white bread"], category: "Bakery", price: 45, unit: "400 g", emoji: "🍞")
        let onion = Product(id: "onion-1kg", name: "Onions", synonyms: ["pyaz"], category: "Vegetables", price: 35, unit: "1 kg", emoji: "🧅")
        let tomato = Product(id: "tomato-1kg", name: "Tomatoes", synonyms: ["tomato"], category: "Vegetables", price: 40, unit: "1 kg", emoji: "🍅")
        let potato = Product(id: "potato-1kg", name: "Potatoes", synonyms: ["aloo"], category: "Vegetables", price: 30, unit: "1 kg", emoji: "🥔")
        let lays = Product(id: "lays-classic-52g", name: "Lay's Classic Salted Chips", synonyms: ["lays"], category: "Snacks", price: 20, unit: "52 g", emoji: "🍟")
        let oreo = Product(id: "oreo-120g", name: "Oreo Biscuits", synonyms: ["oreo"], category: "Snacks", price: 30, unit: "120 g", emoji: "🍪")
        let coke = Product(id: "coke-750ml", name: "Coca-Cola", synonyms: ["coke"], category: "Beverages", price: 40, unit: "750 ml", emoji: "🥤")
        let atta = Product(id: "wheat-atta-5kg", name: "Wheat Atta", synonyms: ["atta"], category: "Staples", price: 250, unit: "5 kg", emoji: "🌾")
        let sugar = Product(id: "sugar-1kg", name: "Sugar", synonyms: ["white sugar"], category: "Staples", price: 48, unit: "1 kg", emoji: "🧂")
        let salt = Product(id: "salt-1kg", name: "Iodised Salt", synonyms: ["salt"], category: "Staples", price: 24, unit: "1 kg", emoji: "🧂")

        let dailyEssentials = Subscription(
            items: [
                SubscriptionItem(product: milk, quantity: 1),
                SubscriptionItem(product: eggs, quantity: 1),
                SubscriptionItem(product: bread, quantity: 1)
            ],
            frequency: .daily,
            slot: DeliverySlot.all[0],
            totalDeliveries: 30,
            deliveriesCompleted: 12,
            startDate: daysAgo(12),
            address: demoAddress,
            preferences: SubscriptionPreferences(doNotRingBell: true, leaveAtDoor: true, remindDayBefore: true),
            status: .active
        )

        let weekendGrocery = Subscription(
            items: [
                SubscriptionItem(product: onion, quantity: 1),
                SubscriptionItem(product: tomato, quantity: 1),
                SubscriptionItem(product: potato, quantity: 1)
            ],
            frequency: .weekly(.saturday),
            slot: DeliverySlot.all[1],
            totalDeliveries: 8,
            deliveriesCompleted: 3,
            startDate: daysAgo(21),
            address: demoAddress,
            preferences: SubscriptionPreferences(),
            status: .active
        )

        let snackBox = Subscription(
            items: [
                SubscriptionItem(product: lays, quantity: 2),
                SubscriptionItem(product: oreo, quantity: 1),
                SubscriptionItem(product: coke, quantity: 2)
            ],
            frequency: .specificDays([.tuesday, .friday]),
            slot: DeliverySlot.all[5],
            totalDeliveries: 12,
            deliveriesCompleted: 5,
            startDate: daysAgo(28),
            address: demoAddress,
            preferences: SubscriptionPreferences(leaveAtDoor: true),
            status: .paused
        )

        let monthlyStaples = Subscription(
            items: [
                SubscriptionItem(product: atta, quantity: 1),
                SubscriptionItem(product: sugar, quantity: 1),
                SubscriptionItem(product: salt, quantity: 1)
            ],
            frequency: .monthly(dayOfMonth: 1),
            slot: DeliverySlot.all[2],
            totalDeliveries: 6,
            deliveriesCompleted: 2,
            startDate: daysAgo(58),
            address: demoAddress,
            preferences: SubscriptionPreferences(),
            status: .stopped
        )

        let rice = Product(id: "rice-basmati-1kg", name: "Basmati Rice", synonyms: ["rice"], category: "Staples", price: 120, unit: "1 kg", emoji: "🍚")
        let toorDal = Product(id: "toor-dal-1kg", name: "Toor Dal", synonyms: ["dal"], category: "Staples", price: 140, unit: "1 kg", emoji: "🫘")

        let festiveStaples = Subscription(
            items: [
                SubscriptionItem(product: rice, quantity: 1),
                SubscriptionItem(product: toorDal, quantity: 1)
            ],
            frequency: .weekly(.sunday),
            slot: DeliverySlot.all[2],
            totalDeliveries: 8,
            deliveriesCompleted: 8,
            startDate: daysAgo(64),
            address: demoAddress,
            preferences: SubscriptionPreferences(),
            status: .finished
        )

        return [dailyEssentials, weekendGrocery, snackBox, monthlyStaples, festiveStaples]
    }
}
