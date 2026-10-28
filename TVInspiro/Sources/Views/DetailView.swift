import SwiftUI

struct DetailView: View {
    let show: TVShow
    @EnvironmentObject private var favorites: FavoritesStore
    @State private var trailerKey: String?
    @State private var isTrailerLoading = false
    @State private var showingTrailer = false
    @State private var trailerErrorMessage: String?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: show.backdropURL) { phase in
                if case .success(let image) = phase {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Rectangle().fill(Color.gray.opacity(0.3))
                }
            }
            .ignoresSafeArea()

            LinearGradient(
                colors: [.black.opacity(0.9), .black.opacity(0.2), .clear],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text(show.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                HStack(spacing: 12) {
                    Label(String(format: "%.1f", show.voteAverage), systemImage: "star.fill")
                }
                .font(.headline)
                .foregroundStyle(.yellow)

                Text(show.overview)
                    .font(.body)
                    .lineLimit(5)
                    .frame(maxWidth: 900, alignment: .leading)

                HStack(spacing: 24) {
                    Button {
                        Task { await loadAndPlayTrailer() }
                    } label: {
                        if isTrailerLoading {
                            ProgressView()
                        } else {
                            Label("Přehrát trailer", systemImage: "play.fill")
                        }
                    }
                    .disabled(isTrailerLoading)

                    if let trailerErrorMessage {
                        Text(trailerErrorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Button {
                        favorites.toggle(show)
                    } label: {
                        Label(
                            favorites.isFavorite(show) ? "Odebrat z oblíbených" : "Přidat do oblíbených",
                            systemImage: favorites.isFavorite(show) ? "checkmark" : "plus"
                        )
                    }
                }
            }
            .padding(60)
        }
        .fullScreenCover(isPresented: $showingTrailer) {
            if let trailerKey {
                TrailerPlayerView(youtubeID: trailerKey)
            }
        }
    }

    private func loadAndPlayTrailer() async {
        isTrailerLoading = true
        trailerErrorMessage = nil
        defer { isTrailerLoading = false }
        do {
            if trailerKey == nil {
                trailerKey = try await TMDBClient.shared.trailerKey(forShow: show.id)
            }
            if trailerKey != nil {
                showingTrailer = true
            } else {
                trailerErrorMessage = "Pro tento seriál nemá TMDB žádný trailer."
            }
        } catch {
            trailerErrorMessage = "Nepodařilo se načíst trailer."
        }
    }
}
