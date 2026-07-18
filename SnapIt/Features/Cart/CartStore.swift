import Foundation

@Observable
final class CartStore {
     var items: [CartItem] = []

    var totalCount: Int { items.reduce(0) { $0 + $1.quantity } }
    var totalPrice: Double { items.reduce(0) { $0 + $1.product.price * Double($1.quantity) } }

    func add(_ products: [Product]) {
        for product in products {
            if let index = items.firstIndex(where: { $0.product.id == product.id }) {
                items[index].quantity += 1
            } else {
                items.append(CartItem(product: product, quantity: 1))
            }
        }
    }

    func updateQuantity(for item: CartItem, to quantity: Int) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        if quantity <= 0 {
            items.remove(at: index)
        } else {
            items[index].quantity = quantity
        }
    }

    func quantity(for product: Product) -> Int {
        items.first(where: { $0.product.id == product.id })?.quantity ?? 0
    }

    func decrement(_ product: Product) {
        guard let index = items.firstIndex(where: { $0.product.id == product.id }) else { return }
        if items[index].quantity <= 1 {
            items.remove(at: index)
        } else {
            items[index].quantity -= 1
        }
    }
}
