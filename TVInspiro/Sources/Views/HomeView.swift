import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var favorites: FavoritesStore

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 48) {
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.title3)
                            .padding(.horizontal, 60)
                            .padding(.top, 60)
                    }
                    ForEach(viewModel.rows) { row in
                        ShowRowView(row: row)
                    }
                }
                .padding(.top, 40)
            }
            .overlay {
                if viewModel.isLoading && viewModel.rows.isEmpty {
                    ProgressView("Načítám tipy…")
                }
            }
            .task {
                await viewModel.load(favorites: favorites.shows)
            }
            .onChange(of: favorites.shows) { _, newFavorites in
                Task { await viewModel.load(favorites: newFavorites) }
            }
        }
    }
}
