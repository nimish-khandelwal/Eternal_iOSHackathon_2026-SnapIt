import Foundation

enum Weekday: Int, CaseIterable, Identifiable, Hashable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    var id: Int { rawValue }

    var shortLabel: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }

    var fullLabel: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
}

enum DeliveryFrequency: Hashable {
    case daily
    case specificDays(Set<Weekday>)
    case weekly(Weekday)
    case monthly(dayOfMonth: Int)

    var summary: String {
        switch self {
        case .daily:
            return "Every day"
        case .specificDays(let days):
            guard !days.isEmpty else { return "Select delivery days" }
            let sorted = days.sorted { $0.rawValue < $1.rawValue }
            return sorted.map(\.shortLabel).joined(separator: ", ")
        case .weekly(let day):
            return "Every \(day.fullLabel)"
        case .monthly(let day):
            return "Monthly on day \(day)"
        }
    }
}

struct DeliverySlot: Identifiable, Hashable {
    let startHour: Int
    let endHour: Int

    var id: Int { startHour }

    var label: String {
        let startPeriod = period(for: startHour)
        let endPeriod = period(for: endHour)
        if startPeriod == endPeriod {
            return "\(hourLabel(startHour)) – \(hourLabel(endHour)) \(endPeriod)"
        }
        return "\(hourLabel(startHour)) \(startPeriod) – \(hourLabel(endHour)) \(endPeriod)"
    }

    private func period(for hour: Int) -> String {
        (hour % 24) < 12 ? "AM" : "PM"
    }

    private func hourLabel(_ hour24: Int) -> String {
        let h = hour24 % 24
        let h12 = h % 12 == 0 ? 12 : h % 12
        return "\(h12)"
    }

    static let all: [DeliverySlot] = [
        DeliverySlot(startHour: 06, endHour: 08),
        DeliverySlot(startHour: 08, endHour: 10),
        DeliverySlot(startHour: 10, endHour: 12),
        DeliverySlot(startHour: 12, endHour: 14),
        DeliverySlot(startHour: 14, endHour: 16),
        DeliverySlot(startHour: 16, endHour: 18),
        DeliverySlot(startHour: 18, endHour: 20),
        DeliverySlot(startHour: 20, endHour: 22)
    ]
}

enum SubscriptionStatus: String {
    case active = "Active"
    case paused = "Paused"
    case stopped = "Stopped"
    case finished = "Finished"
}

struct SubscriptionItem: Identifiable {
    let id = UUID()
    let product: Product
    var quantity: Int
}

struct SubscriptionPreferences {
    var doNotRingBell = false
    var leaveAtDoor = false
    var remindDayBefore = true
}

struct Subscription: Identifiable {
    let id = UUID()
    var items: [SubscriptionItem]
    var frequency: DeliveryFrequency
    var slot: DeliverySlot
    var totalDeliveries: Int
    var deliveriesCompleted: Int
    var startDate: Date
    var address: String
    var preferences: SubscriptionPreferences
    var status: SubscriptionStatus

    static let subscriptionDiscountRate: Double = 0.10

    var title: String {
        let names = items.map(\.product.name)
        guard names.count > 2 else { return names.joined(separator: " & ") }
        return "\(names[0]) & \(names.count - 1) more"
    }

    var perDeliveryAmount: Double {
        items.reduce(0) { $0 + $1.product.price * Double($1.quantity) }
    }

    var itemsTotal: Double { perDeliveryAmount * Double(totalDeliveries) }
    var discountAmount: Double { itemsTotal * Self.subscriptionDiscountRate }
    var finalAmount: Double { itemsTotal - discountAmount }

    var deliveryDates: [Date] {
        DeliveryScheduler.dates(start: startDate, frequency: frequency, count: totalDeliveries)
    }

    var endDate: Date { deliveryDates.last ?? startDate }

    /// Pause/resume/stop only make sense while a subscription is still running.
    var canManage: Bool { status == .active || status == .paused }

    var nextDeliveryDate: Date? {
        let today = Calendar.current.startOfDay(for: Date())
        return deliveryDates.first { $0 >= today }
    }
}

/// Turns a frequency + start date into the concrete calendar dates deliveries
/// will land on — used for the end-date summary and (eventually) reminders.
enum DeliveryScheduler {
    static func dates(start: Date, frequency: DeliveryFrequency, count: Int) -> [Date] {
        guard count > 0 else { return [] }
        let calendar = Calendar.current
        var results: [Date] = []

        switch frequency {
        case .daily:
            for i in 0..<count {
                if let date = calendar.date(byAdding: .day, value: i, to: start) {
                    results.append(date)
                }
            }

        case .weekly(let weekday):
            var current = nextOrSame(weekday: weekday, from: start, calendar: calendar)
            for _ in 0..<count {
                results.append(current)
                current = calendar.date(byAdding: .day, value: 7, to: current) ?? current
            }

        case .specificDays(let days):
            guard !days.isEmpty else { return [] }
            var current = start
            var safety = 0
            while results.count < count && safety < count * 14 {
                if days.contains(where: { $0.rawValue == calendar.component(.weekday, from: current) }) {
                    results.append(current)
                }
                current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
                safety += 1
            }

        case .monthly(let dayOfMonth):
            for i in 0..<count {
                var components = calendar.dateComponents([.year, .month], from: start)
                components.day = dayOfMonth
                components.month = (components.month ?? 1) + i
                if let date = calendar.date(from: components) {
                    results.append(date)
                }
            }
        }

        return results
    }

    private static func nextOrSame(weekday: Weekday, from date: Date, calendar: Calendar) -> Date {
        var current = date
        var safety = 0
        while calendar.component(.weekday, from: current) != weekday.rawValue && safety < 8 {
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
            safety += 1
        }
        return current
    }
}
