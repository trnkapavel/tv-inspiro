import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var favorites: FavoritesStore

    var body: some View {
        NavigationStack {
            ScrollView {
                if favorites.shows.isEmpty {
                    Text("Zatím nemáš žádné oblíbené seriály.")
                        .font(.title3)
                        .padding(.top, 100)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 32)], spacing: 32) {
                        ForEach(favorites.shows) { show in
                            NavigationLink {
                                DetailView(show: show)
                            } label: {
                                PosterCard(show: show)
                            }
                            .buttonStyle(.card)
                        }
                    }
                    .padding(60)
                }
            }
        }
    }
}
