import Foundation

/// Bridges free-text vision output ("coke bottle") to fixed catalog SKUs, using
/// normalized string + synonym overlap — no embeddings needed for a few dozen SKUs.
struct ProductMatcher {
    let catalog: [Product]

    func match(_ detected: DetectedProduct) -> Product? {
        let needle = normalize(detected.name)
        guard !needle.isEmpty else { return nil }

        if let exact = catalog.first(where: { product in
            normalize(product.name) == needle || product.synonyms.contains { normalize($0) == needle }
        }) {
            return exact
        }

        let needleTokens = tokens(of: needle)
        let candidates = catalog.filter { product in
            let haystack = tokens(of: haystackString(for: product))
            return !haystack.isDisjoint(with: needleTokens)
        }

        return candidates.max { lhs, rhs in
            overlapScore(lhs, needleTokens) < overlapScore(rhs, needleTokens)
        }
    }

    private func overlapScore(_ product: Product, _ needleTokens: Set<String>) -> Int {
        tokens(of: haystackString(for: product)).intersection(needleTokens).count
    }

    private func haystackString(for product: Product) -> String {
        ([product.name] + product.synonyms).map(normalize).joined(separator: " ")
    }

    private func tokens(of string: String) -> Set<String> {
        Set(string.split(separator: " ").map(String.init))
    }

    private func normalize(_ s: String) -> String {
        s.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
