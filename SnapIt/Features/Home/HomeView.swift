import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var isShowingFeaturePicker = false
    @State private var selectedFeature: LensFeature?
    @State private var selectedHeaderTab = 0
    @State private var selectedBottomTab = 0
    @State private var searchText = ""
    @State private var speech = SpeechRecognizer()
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
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

                floatingNavigation

                if isShowingFeaturePicker {
                    featurePickerOverlay
                }
            }
            .toolbar(.hidden, for: .navigationBar)
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
        }
    }

    private var header: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 18) {
                headerTopRow
                searchBar
            }
            .padding(.horizontal, 12)
            .padding(.top, 74)

            categoryTabs
                .padding(.top, 22)
        }
        .padding(.bottom, 0)
        .background {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.70, blue: 0.84),
                        Color(red: 0.99, green: 0.82, blue: 0.79),
                        Color(red: 0.96, green: 0.86, blue: 0.86)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
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
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(Color.blinkitInk)

                HStack(alignment: .center, spacing: 7) {
                    Text("8 minutes")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(Color.blinkitInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.92)
                        .layoutPriority(2)

                    HStack(spacing: 5) {
                        Image("BlinkitLocationStore")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("650 m away")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                    }
                    .foregroundStyle(Color(red: 0.00, green: 0.48, blue: 0.50))
                    .padding(.horizontal, 8)
                    .frame(height: 24)
                    .background(Color(red: 0.70, green: 0.85, blue: 0.86), in: Capsule())
                    .padding(.top, 4)
                    .layoutPriority(1)
                }

                HStack(spacing: 4) {
                    Text("NH2 STAYS PG...")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                    Text("- NH2 Stays PG")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                    Image("BlinkitChevron")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 13)
                }
                .foregroundStyle(Color.blinkitInk)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 0)

            HStack(alignment: .top, spacing: 7) {
                WalletButton(count: appState.cartStore.totalCount)

                Image("BlinkitProfile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
            }
            .padding(.top, 14)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 13) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.blinkitInk)

            TextField(
                "",
                text: $searchText,
                prompt: Text("Search \"birthday gift\"")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.9))
            )
            .font(.system(size: 22, weight: .semibold, design: .rounded))
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
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(speech.isRecording ? .red : Color.blinkitInk)
                    .symbolEffect(.pulse, isActive: speech.isRecording)
            }
            .buttonStyle(.plain)
            .padding(.leading, 2)
        }
        .padding(.horizontal, 16)
        .frame(height: 55)
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
        ("BlinkitTabBeauty", "Beauty", true),
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
        ])
    }

    private var snacksSection: some View {
        CategorySection(title: "Snacks & Drinks", items: [
            StoreCategory(title: "Chips &\nNamkeen", imageName: "BlinkitChips"),
            StoreCategory(title: "Sweets &\nChocolates", imageName: "BlinkitSweets"),
            StoreCategory(title: "Drinks &\nJuices", imageName: "BlinkitDrinks"),
            StoreCategory(title: "Tea, Coffee\n& Milk Drinks", imageName: "BlinkitTea")
        ])
    }

    private var breakfastSection: some View {
        CategorySection(title: "Breakfast & More", items: [
            StoreCategory(title: "Sauces &\nSpreads", imageName: "BlinkitDairy"),
            StoreCategory(title: "Noodles &\nPasta", imageName: "BlinkitAtta"),
            StoreCategory(title: "Frozen\nFoods", imageName: "BlinkitMeat"),
            StoreCategory(title: "Ice Creams\n& More", imageName: "BlinkitSweets")
        ])
    }

    private static let bottomTabs: [(imageName: String, title: String)] = [
        ("BlinkitBottomHome", "Home"),
        ("BlinkitBottomOrder", "Order Again"),
        ("BlinkitBottomCategories", "Categories"),
        ("BlinkitBottomPrint", "Print")
    ]

    private var floatingNavigation: some View {
        HStack(spacing: 0) {
            ForEach(Array(Self.bottomTabs.enumerated()), id: \.offset) { index, tab in
                FloatingTab(
                    imageName: tab.imageName,
                    title: tab.title,
                    selected: selectedBottomTab == index
                ) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                        selectedBottomTab = index
                    }
                }
            }
            cameraTab
        }
        .frame(maxWidth: .infinity)
        .frame(height: 82)
        .padding(.horizontal, 9)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.14), radius: 18, y: 7)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private var cameraTab: some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                isShowingFeaturePicker = true
            }
        } label: {
            Image("BlinkitCameraButton")
                .resizable()
                .scaledToFit()
                .frame(width: 58, height: 58)
                .clipShape(Circle())
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
    }

    private var featurePickerOverlay: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.34)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.18)) {
                        isShowingFeaturePicker = false
                    }
                }

            VStack(spacing: 14) {
                Capsule()
                    .fill(Color.black.opacity(0.12))
                    .frame(width: 48, height: 5)
                    .padding(.top, 6)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Blinkit Lens")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                    Text("Choose what you want to scan")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
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
            .padding(.horizontal, 16)
            .padding(.bottom, 18)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .zIndex(2)
    }

    private func open(_ feature: LensFeature) {
        withAnimation(.easeOut(duration: 0.18)) {
            isShowingFeaturePicker = false
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

    var body: some View {
        Image("BlinkitWallet")
            .resizable()
            .scaledToFit()
            .frame(width: 47, height: 49)
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
                .frame(height: 25)
                .overlay(alignment: .topTrailing) {
                    if showsSaleBadge {
                        Text("Sale")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2.5)
                            .background(Color(red: 0.86, green: 0.14, blue: 0.19), in: Capsule())
                            .offset(x: 18, y: -9)
                    }
                }

            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: selected ? .heavy : .medium, design: .rounded))
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

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(Color.blinkitInk)
                .padding(.horizontal, 12)

            LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                ForEach(items) { item in
                    CategoryTile(item: item)
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.top, 12)
        .padding(.bottom, 18)
        .background(.white)
    }
}

private struct StoreCategory: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
}

private struct CategoryTile: View {
    let item: StoreCategory

    var body: some View {
        Button {
        } label: {
            content
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private var content: some View {
        VStack(spacing: 7) {
            Image(item.imageName)
                .resizable()
                .aspectRatio(216.0 / 236.0, contentMode: .fit)
                .frame(maxWidth: .infinity)

            Text(item.title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.blinkitInk)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

private struct FloatingTab: View {
    let imageName: String
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
            if selected {
                Circle()
                    .fill(.white.opacity(0.72))
                    .frame(width: 58, height: 58)
                    .blur(radius: 1)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
            }

            VStack(spacing: 4) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: selected ? 34 : 33, height: selected ? 34 : 33)

                Text(title)
                    .font(.system(size: selected ? 13 : 12.5, weight: selected ? .black : .medium, design: .rounded))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .padding(.top, selected ? 4 : 2)
        }
        .frame(maxWidth: .infinity)
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
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
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
