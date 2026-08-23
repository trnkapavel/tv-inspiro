import SwiftUI

@main
struct TVInspiroApp: App {
    @StateObject private var favorites = FavoritesStore()

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem { Text("Domů") }
                FavoritesView()
                    .tabItem { Text("Oblíbené") }
            }
            .environmentObject(favorites)
        }
    }
}
