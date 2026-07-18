import Foundation

/// Bridges free-text vision output ("coke bottle") to fixed catalog SKUs, using
/// normalized string + synonym overlap — no embeddings needed for a few dozen SKUs.
struct ProductMatcher {
    let catalog: [Product]

    /// Below this, `match(_:)`'s pick is shown to the user as provisional —
    /// screens pair it with `candidates(for:)` so a wrong guess is one tap to fix.
    static let lowConfidenceThreshold: Double = 0.75

    func match(_ detected: DetectedProduct) -> Product? {
        let needle = normalize(detected.name)
        guard !needle.isEmpty else { return nil }

        if let exact = catalog.first(where: { product in
            normalize(product.name) == needle || product.synonyms.contains { normalize($0) == needle }
        }) {
            return exact
        }

        let needleTokens = tokens(of: needle)
        guard !needleTokens.isEmpty else { return nil }

        let candidates = catalog.filter { product in
            let haystack = haystackString(for: product)
            if !tokens(of: haystack).isDisjoint(with: needleTokens) { return true }
            // Catches compound/descriptive names token-splitting can still miss,
            // e.g. "Colgate MaxFresh" containing "colgate" as a substring of a longer word.
            return haystack.contains(needle) || needle.contains(normalize(product.name))
        }

        return candidates.max { lhs, rhs in
            overlapScore(lhs, needleTokens) < overlapScore(rhs, needleTokens)
        }
    }

    /// A ranked shortlist for manual correction — used wherever `match(_:)` came
    /// back nil or under-confident, so the user can pick the right SKU instead of
    /// trusting a single silent guess.
    func candidates(for detected: DetectedProduct, limit: Int = 10) -> [Product] {
        let needle = normalize(detected.name)
        let needleTokens = tokens(of: needle)

        guard !needleTokens.isEmpty else {
            return Array(catalog.prefix(limit))
        }

        let scored: [(product: Product, score: Int)] = catalog.compactMap { product in
            let haystack = haystackString(for: product)
            let score = overlapScore(product, needleTokens)
            let looseMatch = score > 0 || haystack.contains(needle) || needle.contains(normalize(product.name))
            guard looseMatch else { return nil }
            return (product, score)
        }

        let ranked = scored.sorted { $0.score > $1.score }.map(\.product)
        return ranked.isEmpty ? Array(catalog.prefix(limit)) : Array(ranked.prefix(limit))
    }

    private func overlapScore(_ product: Product, _ needleTokens: Set<String>) -> Int {
        tokens(of: haystackString(for: product)).intersection(needleTokens).count
    }

    private func haystackString(for product: Product) -> String {
        ([product.name] + product.synonyms).map(normalize).joined(separator: " ")
    }

    /// Splits on anything that isn't a letter or digit, so punctuation in a vision
    /// model's free-text output ("Milk, 500ml (Amul)") can't silently break a match.
    /// Also adds a naive singular form per token, so "Onions" still lines up with
    /// a catalog synonym written as "onion".
    private func tokens(of string: String) -> Set<String> {
        let base = string
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .map(String.init)
            .filter { !$0.isEmpty }

        var expanded = Set(base)
        for token in base {
            if token.hasSuffix("es"), token.count > 3 {
                expanded.insert(String(token.dropLast(2)))
            } else if token.hasSuffix("s"), token.count > 2 {
                expanded.insert(String(token.dropLast()))
            }
        }
        return expanded
    }

    private func normalize(_ s: String) -> String {
        s.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
