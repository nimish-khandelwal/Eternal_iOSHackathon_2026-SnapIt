# SnapIt

**Point. Detect. Refill.**
*Anything you can see becomes your Blinkit cart.*

An AI camera lens for Blinkit, built during the **Eternal iOS Hackathon 2026**
(Blinkit track). Point your camera at a product, a shopping list, or your
fridge — skip typing into a search bar entirely.

## Team

**Async Legion**

- Prince — [built.by.prince@gmail.com](mailto:built.by.prince@gmail.com)
- Nimish — [nimishkhandelwal2503@gmail.com](mailto:nimishkhandelwal2503@gmail.com)

## Features

- **Snap Product** — point at any item, packaged or loose, and add it to
  your cart in seconds.
- **Shopping List** — photograph a handwritten list or a receipt; every line
  gets read and matched.
- **Pantry Scan** — photograph your fridge or shelf. The app compares what
  it sees against what you usually buy and sorts everything into
  **Likely Running Low**, **Out of Stock**, or **Still Available**.
- **Browse Catalog** — a normal searchable product grid for when you're not
  using the camera.
- **Cart & Subscriptions** — checkout, plus recurring orders on a schedule
  you set (daily, weekly, monthly, or specific days).
- **Recommended Quantity** — the app remembers how much of each product you
  usually order (from your own on-device order history) and suggests that
  amount next time, right when you add it to your cart.

Every AI guess — confident or not — is shown as a row of candidate products
you tap to confirm. Nothing is ever added to the cart silently.

## Demo

Screen recordings of each feature, in [`Screen Recordings/`](<Screen Recordings>):

- 📷 [Snap Product](<Screen Recordings/Snap Product.mov>)
- 📝 [Shopping List](<Screen Recordings/Shopping List.mov>)
- 🧊 [Pantry Scan](<Screen Recordings/Pantry Scan.mov>)
- 🔁 [Recommended Quantity](<Screen Recordings/Recommended Quantity.MP4>)
- 📦 [Subscriptions](<Screen Recordings/Subscriptions.MP4>)

## Tech stack

- **SwiftUI**, native iOS, no third-party UI framework
- **AVFoundation** for the live camera capture
- **Google Gemini Vision API** for product/text recognition (OpenAI GPT-4o
  is a drop-in alternative — see [Setup](#setup))
- A hand-rolled **product matcher** (fuzzy text matching + category
  fallback) that turns free-text AI guesses into real catalog products
- A mock ~5,000-SKU JSON catalog stands in for Blinkit's real product API —
  no backend required to run this

## Setup

1. Open `SnapIt.xcodeproj` in Xcode 26.5+.
2. Add your API key in `SnapIt/Core/Networking/Secrets.swift`:
   ```swift
   enum Secrets {
       static let openAIAPIKey = "..."
       static let geminiAPIKey = "..."
   }
   ```
   This file is gitignored — it's never committed. Get a Gemini key at
   [aistudio.google.com/apikey](https://aistudio.google.com/apikey) (no
   billing setup required to start).
3. In `SnapIt/App/AppState.swift`, `visionService` picks the active
   provider — defaults to `GeminiVisionService()`. Swap in
   `OpenAIVisionService()` or `MockVisionService()` (a canned offline
   fallback, handy if wifi is unreliable mid-demo) on that one line.
4. Build and run on a simulator or device. The camera modes need a real
   device or the Photos-picker fallback (simulators have no camera).
