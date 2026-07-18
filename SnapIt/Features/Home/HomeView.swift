import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header

                    NavigationLink {
                        SnapProductView()
                    } label: {
                        ModeTile(icon: "camera.viewfinder", title: "Snap Product", subtitle: "Point at one item, add it instantly")
                    }

                    NavigationLink {
                        ShoppingListScanView()
                    } label: {
                        ModeTile(icon: "list.bullet.rectangle", title: "Shopping List", subtitle: "Photograph a list or receipt")
                    }

                    NavigationLink {
                        PantryScanView()
                    } label: {
                        ModeTile(icon: "cabinet", title: "Pantry Scan", subtitle: "See what's running low")
                    }

                    Divider().padding(.vertical, 4)

                    NavigationLink {
                        BrowseView()
                    } label: {
                        ModeTile(icon: "square.grid.2x2", title: "Browse Catalog", subtitle: "Search and add without a photo")
                    }
                }
                .padding(20)
            }
            .navigationTitle("SnapIt")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        CartView()
                    } label: {
                        Image(systemName: "cart")
                            .overlay(alignment: .topTrailing) {
                                if appState.cartStore.totalCount > 0 {
                                    Text("\(appState.cartStore.totalCount)")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.white)
                                        .padding(4)
                                        .background(Color.red, in: Circle())
                                        .offset(x: 10, y: -10)
                                }
                            }
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Point. Detect. Refill.")
                .font(.title2.weight(.semibold))
            Text("Anything you can see becomes your Blinkit cart.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }
}

private struct ModeTile: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 48, height: 48)
                .background(Color.accentColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .foregroundStyle(.primary)
    }
}

#Preview {
    HomeView().environment(AppState())
}
