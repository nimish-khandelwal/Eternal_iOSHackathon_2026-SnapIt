import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var isShowingFeaturePicker = false
    @State private var selectedFeature: LensFeature?
    @State private var selectedStoreCategory: StoreCategory?
    @State private var selectedHeaderTab = 0
    @State private var selectedBottomTab = 0
    @State private var lastSelecteBottomTab = 0
    @State private var searchText = ""
    @State private var speech = SpeechRecognizer()
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                if selectedBottomTab == 4 {
                    CartView()
                } else if selectedBottomTab == 1 {
                    SubscriptionsListView()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            header
                            grocerySection
                            snacksSection
                            breakfastSection
                        }
                        .padding(.bottom, 112)
                    }
                    .background(Color.white)
                    .ignoresSafeArea(edges: .top)
                    .scrollDismissesKeyboard(.immediately)
                    .onTapGesture {
                        isSearchFocused = false
                    }
                }

                floatingNavigation

                if isShowingFeaturePicker {
                    featurePickerOverlay
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedStoreCategory) { category in
                CategoryDetailView(category: category)
            }
            .navigationDestination(item: $selectedFeature) { feature in
                switch feature {
                case .snapProduct:
                    SnapProductView()
                case .shoppingList:
                    ShoppingListScanView()
                case .pantryScan:
                    PantryScanView()
                }
            }
        }.dynamicTypeSize(.medium)
    }

    private var header: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 18) {
                headerTopRow
                searchBar
            }
            .padding(.horizontal, 12)
            .padding(.top, 50)

            categoryTabs
                .padding(.top, 22)
        }
        .padding(.bottom, 0)
        .background {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 1, green: 1, blue: 1), // #ffe142
                        Color(red: 1, green: 0.882, blue: 0.259),
                        Color(red: 1, green: 0.882, blue: 0.259) // #ffe142
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                SunburstShape()
                    .stroke(.white.opacity(0.34), lineWidth: 1)
                    .frame(width: 150, height: 150)
                    .offset(x: 140, y: -72)
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.13))
                .frame(height: 1)
        }
    }

    private var headerTopRow: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Blinkit in")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.blinkitInk)

                HStack(alignment: .center, spacing: 7) {
                    Text("8 minutes")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(Color.blinkitInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.92)
                        .layoutPriority(2)

                    HStack(spacing: 5) {
                        Image(systemName: "storefront")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                        Text("650 m away")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(Color(red: 0.00, green: 0.48, blue: 0.50))
                    .padding(.horizontal, 8)
                    .frame(height: 24)
                    .background(Color(red: 0.70, green: 0.85, blue: 0.86), in: Capsule())
                    .padding(.top, 4)
                    .layoutPriority(1)
                }

                HStack(spacing: 4) {
                    Text("Zomato Farm")
                        .font(.system(size: 12, weight: .bold))
                    Text("- Chhatarpur far...")
                        .font(.system(size: 12))
                    Image(systemName: "arrowtriangle.down.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 6, height: 6)
                }
                .foregroundStyle(Color.blinkitInk)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 0)

            HStack(alignment: .top, spacing: 16) {
                WalletButton(count: appState.cartStore.totalCount)

                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(Color.blinkitInk)
            }
            .padding(.top, 14)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 13) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(Color.blinkitInk)

            TextField(
                "",
                text: $searchText,
                prompt: Text("Search \"birthday gift\"")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.black.opacity(0.9))
            )
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.black)
            .focused($isSearchFocused)
            .submitLabel(.search)
            .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.black.opacity(0.35))
                }
                .buttonStyle(.plain)
            }

            Rectangle()
                .fill(Color(red: 0.89, green: 0.91, blue: 0.94))
                .frame(width: 1, height: 32)

            Button {
                speech.toggle()
            } label: {
                Image(systemName: "mic.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(speech.isRecording ? .red : Color.blinkitInk)
                    .symbolEffect(.pulse, isActive: speech.isRecording)
            }
            .buttonStyle(.plain)
            .padding(.leading, 2)
        }
        .padding(.horizontal, 14)
        .frame(height: 50)
        .background(Color.white.opacity(0.78), in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.82), lineWidth: 1))
        .contentShape(Capsule())
        .onTapGesture {
            isSearchFocused = true
        }
        .onChange(of: speech.transcript) { _, transcript in
            guard !transcript.isEmpty else { return }
            searchText = transcript
        }
    }

    private static let headerTabs: [(imageName: String, title: String, sale: Bool)] = [
        ("BlinkitTabAll", "All", false),
        ("BlinkitTabMonsoon", "Monsoon", false),
        ("BlinkitTabElectronics", "Electronics", false),
        ("BlinkitTabBeauty", "Beauty", false),
        ("BlinkitTabPharmacy", "Pharmacy", false)
    ]

    private var categoryTabs: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(Array(Self.headerTabs.enumerated()), id: \.offset) { index, tab in
                HeaderCategory(
                    imageName: tab.imageName,
                    title: tab.title,
                    selected: selectedHeaderTab == index,
                    showsSaleBadge: tab.sale
                ) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                        selectedHeaderTab = index
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }

    private var grocerySection: some View {
        CategorySection(title: "Grocery & Kitchen", items: [
            StoreCategory(title: "Vegetables &\nFruits", imageName: "BlinkitVegetables"),
            StoreCategory(title: "Atta, Rice &\nDal", imageName: "BlinkitAtta"),
            StoreCategory(title: "Oil, Ghee &\nMasala", imageName: "BlinkitOil"),
            StoreCategory(title: "Dairy, Bread\n& Eggs", imageName: "BlinkitDairy"),
            StoreCategory(title: "Bakery &\nBiscuits", imageName: "BlinkitBakery"),
            StoreCategory(title: "Dry Fruits &\nCereals", imageName: "BlinkitCereal"),
            StoreCategory(title: "Chicken,\nMeat & Fish", imageName: "BlinkitMeat"),
            StoreCategory(title: "Kitchenware\n& Appliances", imageName: "BlinkitKitchenware")
        ]) { selectedStoreCategory = $0 }
    }

    private var snacksSection: some View {
        CategorySection(title: "Snacks & Drinks", items: [
            StoreCategory(title: "Chips &\nNamkeen", imageName: "BlinkitChips"),
            StoreCategory(title: "Sweets &\nChocolates", imageName: "BlinkitSweets"),
            StoreCategory(title: "Drinks &\nJuices", imageName: "BlinkitDrinks"),
            StoreCategory(title: "Tea, Coffee\n& Milk Drinks", imageName: "BlinkitTea")
        ]) { selectedStoreCategory = $0 }
    }

    private var breakfastSection: some View {
        CategorySection(title: "Breakfast & More", items: [
            StoreCategory(title: "Sauces &\nSpreads", imageName: "BlinkitDairy"),
            StoreCategory(title: "Noodles &\nPasta", imageName: "BlinkitAtta"),
            StoreCategory(title: "Frozen\nFoods", imageName: "BlinkitMeat"),
            StoreCategory(title: "Ice Creams\n& More", imageName: "BlinkitSweets")
        ]) { selectedStoreCategory = $0 }
    }

    private static let bottomTabs: [(defaultImageName: String, selectedImageName: String, title: String)] = [
        ("HomeDefault", "HomeSelected", "Home"),
        ("SubsDefault", "SubsSelected", "Subs"),
        ("ScanDefault", "ScanSelected", "Capture"),
        ("PrintDefault", "PrintSelected", "Print"),
        ("BasketDefault", "BasketSelected", "Cart")
    ]

    private var floatingNavigation: some View {
        HStack{
            HStack(spacing: 0) {
                ForEach(Array(Self.bottomTabs.enumerated()), id: \.offset) { index, tab in
                    FloatingTab(
                        defaultimageName: tab.defaultImageName,
                        selectedImageName: tab.selectedImageName,
                        title: tab.title,
                        selected: selectedBottomTab == index
                    ) {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                            if index == 2 {
                                selectedBottomTab = index
                                isShowingFeaturePicker = true
                            } else {
                                selectedBottomTab = index
                                lastSelecteBottomTab = index
                                isShowingFeaturePicker = false
                            }

                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .padding(.horizontal, 9)
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    private var cameraTab: some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                isShowingFeaturePicker = true
            }
        } label: {
            Image(systemName: "camera")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                
        }
        .frame(width: 52, height: 52)
        .buttonStyle(.plain)
        .background(.yellow, in: RoundedRectangle(cornerRadius: 28))
        
    }

    private var featurePickerOverlay: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.34)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.18)) {
                        isShowingFeaturePicker = false
                        selectedBottomTab = lastSelecteBottomTab
                    }
                }

            VStack(spacing: 14) {
                Capsule()
                    .fill(Color.black.opacity(0.12))
                    .frame(width: 48, height: 5)
                    .padding(.top, 6)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Blinkit Lens")
                        .font(.system(size: 24, weight: .black ))
                    Text("Choose what you want to scan")
                        .font(.system(size: 14, weight: .medium ))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                FeatureActionRow(
                    icon: "barcode.viewfinder",
                    title: "Snap Product",
                    subtitle: "Point at one item and add it instantly"
                ) {
                    open(.snapProduct)
                }

                FeatureActionRow(
                    icon: "list.clipboard",
                    title: "Shopping List",
                    subtitle: "Scan a handwritten list or receipt"
                ) {
                    open(.shoppingList)
                }

                FeatureActionRow(
                    icon: "refrigerator",
                    title: "Pantry Scan",
                    subtitle: "Find likely refills from fridge or shelf"
                ) {
                    open(.pantryScan)
                }
            }
            .padding(18)
            .padding(.bottom, 20)
            .background(.white, in: RoundedRectangle(cornerRadius: 28))
            .padding(.horizontal, 14)
            .padding(.bottom, 18)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .zIndex(2)
    }

    private func open(_ feature: LensFeature) {
        withAnimation(.easeOut(duration: 0.18)) {
            isShowingFeaturePicker = false
            selectedBottomTab = lastSelecteBottomTab
        }
        selectedFeature = feature
    }
}

private enum LensFeature: String, Identifiable {
    case snapProduct
    case shoppingList
    case pantryScan

    var id: String { rawValue }
}

private struct WalletButton: View {
    let count: Int
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: "wallet.bifold.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundStyle(Color.blinkitInk)
                .overlay(alignment: .topTrailing) {
                    if count > 0 {
                        Text("\(count)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Color(red: 0.86, green: 0.14, blue: 0.19), in: Circle())
                            .offset(x: 10, y: -8)
                    }
                }
        }
        .buttonStyle(PressScaleButtonStyle())
    }
}

private struct HeaderCategory: View {
    let imageName: String
    let title: String
    let selected: Bool
    var showsSaleBadge: Bool = false
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(PressScaleButtonStyle())
        .frame(maxWidth: .infinity)
    }

    private var content: some View {
        VStack(spacing: 7) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 20)
                .overlay(alignment: .topTrailing) {
                    if showsSaleBadge {
                        Text("Sale")
                            .font(.system(size: 10, weight: .heavy ))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2.5)
                            .background(Color(red: 0.86, green: 0.14, blue: 0.19), in: Capsule())
                            .offset(x: 18, y: -9)
                    }
                }

            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: selected ? .bold : .medium))
                    .foregroundStyle(Color.blinkitInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Rectangle()
                    .fill(selected ? Color.blinkitInk : .clear)
                    .frame(height: 2.5)
            }
            .fixedSize()
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CategorySection: View {
    let title: String
    let items: [StoreCategory]
    var onSelect: (StoreCategory) -> Void = { _ in }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.blinkitInk)
                .padding(.horizontal, 12)

            LazyVGrid(columns: columns, alignment: .center, spacing: 12) {
                ForEach(items) { item in
                    CategoryTile(item: item, onSelect: onSelect)
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.top, 12)
        .padding(.bottom, 18)
        .background(.white)
    }
}

struct StoreCategory: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let imageName: String

    var displayTitle: String {
        title.replacingOccurrences(of: "\n", with: " ")
    }
}

private struct CategoryTile: View {
    let item: StoreCategory
    var onSelect: (StoreCategory) -> Void = { _ in }

    var body: some View {
        Button {
            onSelect(item)
        } label: {
            content
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private var content: some View {
        VStack(spacing: 4) {
            Image(item.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 74, height: 74)

            Text(item.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.blinkitInk)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

private struct FloatingTab: View {
    let defaultimageName: String
    let selectedImageName: String
    let title: String
    let selected: Bool
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(PressScaleButtonStyle())
        .frame(maxWidth: .infinity)
    }

    private var content: some View {
        ZStack {
            VStack(spacing: 6) {
                Image(selected ? selectedImageName : defaultimageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: selected ? 24 : 22, height: selected ? 24 : 22)

                Text(title)
                    .font(.system(size: 11, weight: selected ? .bold : .medium))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .padding(.top, selected ? 4 : 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
        .padding(.bottom, 4)
        .background(selected ? .black.opacity(0.08) : .clear)
    }
}

private struct FeatureActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 48, height: 48)
                    .background(Color(red: 1.00, green: 0.86, blue: 0.24), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 18, weight: .black ))
                        .foregroundStyle(.black)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium ))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(Color(red: 0.96, green: 0.97, blue: 0.97), in: RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }
}

private struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

private struct SunburstShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        for angle in stride(from: 0.0, to: 360.0, by: 16.0) {
            let radians = angle * .pi / 180
            let inner = CGPoint(
                x: center.x + cos(radians) * rect.width * 0.12,
                y: center.y + sin(radians) * rect.height * 0.12
            )
            let outer = CGPoint(
                x: center.x + cos(radians) * rect.width * 0.58,
                y: center.y + sin(radians) * rect.height * 0.58
            )
            path.move(to: inner)
            path.addLine(to: outer)
        }
        return path
    }
}

private extension Color {
    static let blinkitInk = Color(red: 0.19, green: 0.20, blue: 0.21)
}

#Preview {
    HomeView().environment(AppState())
}
