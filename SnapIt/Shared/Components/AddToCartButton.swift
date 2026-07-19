import SwiftUI

/// The add-to-cart action on every scan result screen (Snap Product, Shopping
/// List, Pantry Scan). Plays a quick confirm bounce so the tap register is
/// felt before `onFinished` hands off to the caller (typically: pop back to
/// Home and switch to the Cart tab).
struct AddToCartButton: View {
    let title: String
    let systemImage: String
    var isDisabled: Bool = false
    let onAdd: () -> Void
    var onFinished: (() -> Void)?

    @State private var isConfirming = false

    var body: some View {
        Button {
            guard !isDisabled, !isConfirming else { return }
            onAdd()
            withAnimation(.spring(response: 0.32, dampingFraction: 0.55)) {
                isConfirming = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeOut(duration: 0.2)) {
                    isConfirming = false
                }
                onFinished?()
            }
        } label: {
            Label(isConfirming ? "Added to Cart" : title, systemImage: isConfirming ? "checkmark.circle.fill" : systemImage)
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .scaleEffect(isConfirming ? 1.04 : 1)
        }
        .buttonStyle(.borderedProminent)
        .tint(isConfirming ? .accent : .accentColor)
        .disabled(isDisabled || isConfirming)
        .animation(.spring(response: 0.32, dampingFraction: 0.55), value: isConfirming)
    }
}
