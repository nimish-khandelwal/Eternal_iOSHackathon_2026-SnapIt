# SnapIt 📸🛒

**Shop with your camera, not a search bar.**

SnapIt is a native iOS app made for **Blinkit**. Point your phone at a product, a handwritten shopping list, or your open fridge — the app sees it and builds your Blinkit cart for you. No typing needed.

Built by team **Async Legion** at the **Eternal iOS Hackathon 2026** (Blinkit track).

> 🎥 **Demo videos** of every feature are in [`Screen Recordings/`](<Screen Recordings>):
> 📷 [Snap Product](<Screen Recordings/Snap Product.mov>) · 📝 [Shopping List](<Screen Recordings/Shopping List.mov>) · 🧊 [Pantry Scan](<Screen Recordings/Pantry Scan.mov>) · 🔁 [Recommended Quantity](<Screen Recordings/Recommended Quantity.MP4>) · 📦 [Subscriptions](<Screen Recordings/Subscriptions.MP4>)

---

## The idea

Typing "atta 5kg", "milk", "coriander" into a search bar is slow — the thing you want is often right in front of you. So SnapIt gives you three camera modes:

| Mode | What you point at | What happens |
|------|-------------------|--------------|
| **Snap Product** | Any single item — packaged or loose | The app finds it in the catalog in seconds |
| **Shopping List** | A handwritten list or a receipt | Every line is read and matched to products |
| **Pantry Scan** | Your fridge or shelf | The app compares it with what you usually buy, and sorts items into **Likely Running Low**, **Out of Stock**, and **Still Available** |

Around the camera, it is a full shopping app: a searchable catalog of ~5,000 products in 10 categories, a cart with checkout, and **subscriptions** for repeat orders (daily, weekly, monthly, or on days you pick).

Two simple rules behind the design:

1. **The AI never adds anything on its own.** Every guess is shown as a row of matching products. You tap to confirm. A wrong guess takes one tap to fix — nothing lands in your cart silently.
2. **The app learns from your own orders.** It remembers how much of each product you usually buy (all on your device) and suggests that amount next time — the **Recommended Quantity** feature.

## How it works

```
Camera photo ──▶ Vision AI (Gemini) ──▶ text guesses ("coke bottle")
                                             │
                                             ▼
                                       ProductMatcher
                              (matches text to real products)
                                             │
                                             ▼
                             product options ──▶ you confirm ──▶ cart
```

- **Vision layer** — one `VisionService` protocol with three swappable options: `GeminiVisionService` (default), `OpenAIVisionService` (GPT-4o), and `MockVisionService` (works offline — very handy when demo wifi fails). Changing the provider is a one-line change in `AppState`.
- **ProductMatcher** — our own fuzzy matcher. It takes the AI's free text and finds the right catalog product using cleaned-up text and synonym matching. No embeddings, no network call. If the match score is below 0.75, the app treats it as a weak guess and pushes you to pick from the options.
- **ComparisonEngine** — runs Pantry Scan: it checks what the camera saw against your past orders and builds the running-low / out-of-stock / available lists.
- **LocalOrderHistoryStore** — your order history, saved only on your device. This powers Recommended Quantity. No account, no server.
- **Mock catalog** — a 5,003-product JSON file plays the role of Blinkit's real product API. The whole app runs with no backend at all.

## Project layout

```
SnapIt/
├── App/                AppState — wires up services
├── Core/
│   ├── Models/         Product, CartItem, Subscription, DetectedProduct, …
│   └── Services/       VisionService (+ Gemini/OpenAI/Mock), ProductMatcher,
│                       ComparisonEngine, CatalogService, LocalOrderHistoryStore
├── Features/
│   ├── Home/           Home screen + voice search (SpeechRecognizer)
│   ├── SnapProduct/    Single-item camera mode
│   ├── ShoppingList/   List/receipt scanning
│   ├── PantryScan/     Fridge scan + results
│   ├── Browse/         Searchable product grid
│   ├── Cart/           Cart + checkout
│   └── Subscriptions/  Repeat-order scheduling
└── Resources/          MockCatalog.json, MockPurchaseHistory.json
```

100% **SwiftUI**, with **AVFoundation** for the live camera. No third-party libraries.

## How to run

1. Open `SnapIt.xcodeproj` in Xcode 26.5+.
2. Create `SnapIt/Core/Services/Secrets.swift` (it is gitignored, so it never gets committed):
   ```swift
   enum Secrets {
       static let openAIAPIKey = ""
       static let geminiAPIKey = ""
   }
   ```
   A free Gemini key from [aistudio.google.com/apikey](https://aistudio.google.com/apikey) is enough.
3. (Optional) Pick the AI provider in `SnapIt/App/AppState.swift` — `visionService` defaults to `GeminiVisionService()`. Swap in `OpenAIVisionService()` or `MockVisionService()` to run fully offline.
4. Build and run. Camera modes need a real device — on the simulator, use the Photos-picker fallback.

## Team

**Async Legion** — Eternal iOS Hackathon 2026

- **Nimish Khandelwal** — [nimishkhandelwal2503@gmail.com](mailto:nimishkhandelwal2503@gmail.com)
- **Prince** — [built.by.prince@gmail.com](mailto:built.by.prince@gmail.com) · [team repo](https://github.com/XOPRINCEXO/Eternal_iOSHackathon_2026-SnapIt)
