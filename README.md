# SnapIt 📸🛒

**Shop with your camera, not a search bar.**

SnapIt is a native iOS app made for **Blinkit**. Point your phone at a product, a handwritten shopping list, or your open fridge — the app sees it and builds your Blinkit cart for you. No typing needed.

Built by team **Async Legion** at the **Eternal iOS Hackathon 2026** (Blinkit track).

---

## The idea

Why type "milk" or "atta 5kg" when the item is right in front of you? Just point your camera at it. SnapIt has three camera modes:

| Mode | Point your camera at | What the app does |
|------|----------------------|-------------------|
| **Snap Product** | Any one item | Finds it in the catalog |
| **Shopping List** | A handwritten list or a receipt | Turns every line into a product |
| **Pantry Scan** | Your fridge or shelf | Tells you what is **running low**, **out of stock**, or **still there** |

Besides the camera, it is also a normal shopping app — browse ~5,000 products, add to cart, checkout, and set repeat orders with **subscriptions** (daily, weekly, monthly, or on days you pick).

Two simple rules:

1. **The AI never adds items by itself.** It shows you matching options — you tap to confirm. A wrong guess is one tap to fix.
2. **The app learns what you buy.** It remembers your usual quantity of each product and suggests it next time — the **Recommended Quantity** feature. All of this stays on your phone.

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

- **Vision AI** — the part that looks at your photo. Default is **Gemini**. You can switch to **GPT-4o**, or to a **mock version** that works without internet (handy when demo wifi fails). Switching is one line in `AppState`.
- **ProductMatcher** — the AI only returns text, like "coke bottle". This part finds the real catalog product that matches the text. If it is not sure, the app asks you to pick from a list instead of guessing.
- **ComparisonEngine** — powers Pantry Scan. It compares what the camera saw with what you bought before, and tells you what is running low, out of stock, or still there.
- **LocalOrderHistoryStore** — saves your order history on your phone only. This is how the app knows how much you usually buy. No account, no server.
- **Mock catalog** — a JSON file with ~5,000 products. It acts as Blinkit's product API, so the app runs without any backend.

## Demo

Screen recordings of each feature, in [`Screen Recordings/`](<Screen Recordings>):

- 📷 [Snap Product](<Screen Recordings/Snap Product.mp4>)
- 📝 [Shopping List](<Screen Recordings/Shopping List.mov>)
- 🧊 [Pantry Scan](<Screen Recordings/Pantry Scan.mov>)
- 🔁 [Recommended Quantity](<Screen Recordings/Recommended Quantity.MP4>)
- 📦 [Subscriptions](<Screen Recordings/Subscriptions.MP4>)

## Tech stack

- **SwiftUI**, native iOS, no third-party UI framework
- **AVFoundation** for the live camera capture
- **Google Gemini Vision API** for product/text recognition (OpenAI GPT-4o
  is a drop-in alternative — see [Setup](#how-to-run))
- A hand-rolled **product matcher** (fuzzy text matching + category
  fallback) that turns free-text AI guesses into real catalog products
- A mock ~5,000-SKU JSON catalog stands in for Blinkit's real product API —
  no backend required to run this

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
