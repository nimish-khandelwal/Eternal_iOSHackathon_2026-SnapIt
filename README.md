# SnapIt 📸🛒

**Shop with your camera, not a search bar.**

SnapIt is a native iOS prototype of an AI camera lens for **Blinkit**: point your phone at a product, a handwritten shopping list, or the inside of your fridge, and the app turns what it sees into a ready-to-confirm Blinkit cart. Built by team **Async Legion** for the **Eternal iOS Hackathon 2026** (Blinkit track).

> 🎥 **Demo recordings** of every feature are in [`Screen Recordings/`](<Screen Recordings>):
> 📷 [Snap Product](<Screen Recordings/Snap Product.mov>) · 📝 [Shopping List](<Screen Recordings/Shopping List.mov>) · 🧊 [Pantry Scan](<Screen Recordings/Pantry Scan.mov>) · 🔁 [Recommended Quantity](<Screen Recordings/Recommended Quantity.MP4>) · 📦 [Subscriptions](<Screen Recordings/Subscriptions.MP4>)

---

## The idea

Typing "atta 5kg", "milk", "coriander" into a search bar is friction — especially when the thing you want is sitting right in front of you. SnapIt replaces that with three camera modes:

| Mode | What you point at | What happens |
|------|-------------------|--------------|
| **Snap Product** | Any single item — packaged or loose | Recognized and matched to a catalog SKU in seconds |
| **Shopping List** | A handwritten list or receipt | Every line is read, parsed, and matched to products |
| **Pantry Scan** | Your fridge or shelf | Compared against your usual orders, then sorted into **Likely Running Low**, **Out of Stock**, and **Still Available** |

Around the camera, it's a full shopping app: a browsable ~5,000-SKU catalog across 10 categories, a cart with checkout, and **subscriptions** for recurring orders (daily, weekly, monthly, or specific weekdays).

Two principles drove the design:

1. **The AI never acts silently.** Every recognition — confident or not — is shown as a row of candidate products you tap to confirm. A wrong guess is one tap to fix, never a surprise in your cart.
2. **Learn from your own history.** The app tracks how much of each product you usually order (entirely on-device) and pre-fills that quantity the next time you add it — the **Recommended Quantity** feature.

## How it works

```
Camera frame ──▶ Vision LLM (Gemini) ──▶ free-text guesses ("coke bottle")
                                              │
                                              ▼
                                        ProductMatcher
                              (normalization + synonym/token overlap)
                                              │
                                              ▼
                              ranked catalog candidates ──▶ user confirms ──▶ cart
```

- **Vision layer** — a `VisionService` protocol with three interchangeable implementations: `GeminiVisionService` (default), `OpenAIVisionService` (GPT-4o drop-in), and `MockVisionService` (canned offline responses — a lifesaver when demo-venue wifi dies). Swapping providers is a one-line change in `AppState`.
- **ProductMatcher** — a hand-rolled fuzzy matcher that bridges free-text model output to fixed catalog SKUs using normalized-string and synonym/token overlap. No embeddings, no network. Matches below a 0.75 confidence threshold are flagged as provisional so the UI can emphasize the candidate picker.
- **ComparisonEngine** — powers Pantry Scan: diffs what the camera sees against your purchase history to produce the running-low / out-of-stock / available buckets.
- **LocalOrderHistoryStore** — on-device order history that feeds Recommended Quantity. No account, no server.
- **Mock catalog** — a 5,003-product JSON catalog stands in for Blinkit's real product API, so the whole app runs with zero backend.

## Project layout

```
SnapIt/
├── App/                AppState — dependency wiring, service selection
├── Core/
│   ├── Models/         Product, CartItem, Subscription, DetectedProduct, …
│   └── Services/       VisionService (+ Gemini/OpenAI/Mock), ProductMatcher,
│                       ComparisonEngine, CatalogService, LocalOrderHistoryStore
├── Features/
│   ├── Home/           Landing screen + voice search (SpeechRecognizer)
│   ├── SnapProduct/    Single-item camera mode
│   ├── ShoppingList/   List/receipt scanning
│   ├── PantryScan/     Fridge scan + comparison results
│   ├── Browse/         Searchable catalog grid
│   ├── Cart/           Cart + checkout
│   └── Subscriptions/  Recurring-order scheduling
└── Resources/          MockCatalog.json, MockPurchaseHistory.json
```

100% **SwiftUI** with **AVFoundation** for live capture — no third-party dependencies.

## Running it

1. Open `SnapIt.xcodeproj` in Xcode 26.5+.
2. Create `SnapIt/Core/Services/Secrets.swift` (gitignored, never committed):
   ```swift
   enum Secrets {
       static let openAIAPIKey = ""
       static let geminiAPIKey = ""
   }
   ```
   A free Gemini key from [aistudio.google.com/apikey](https://aistudio.google.com/apikey) is enough.
3. (Optional) Change the active provider in `SnapIt/App/AppState.swift` — `visionService` defaults to `GeminiVisionService()`; swap in `OpenAIVisionService()` or `MockVisionService()` to run fully offline.
4. Build and run. Camera modes need a physical device; on the simulator, use the Photos-picker fallback.

## Team

**Async Legion** — Eternal iOS Hackathon 2026

- **Nimish Khandelwal** — [nimishkhandelwal2503@gmail.com](mailto:nimishkhandelwal2503@gmail.com)
- **Prince** — [built.by.prince@gmail.com](mailto:built.by.prince@gmail.com) · [team repo](https://github.com/XOPRINCEXO/Eternal_iOSHackathon_2026-SnapIt)
