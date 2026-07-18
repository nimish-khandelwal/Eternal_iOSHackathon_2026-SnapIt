import Foundation

/// Shared state machine every capture-driven feature (Snap Product, Shopping
/// List, Pantry Scan) walks through, so their views can switch on one enum.
enum ScanPhase {
    case capture
    case analyzing
    case results
    case error(String)
}
