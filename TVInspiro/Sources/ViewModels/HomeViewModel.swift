import Foundation

struct ShowRow: Identifiable {
    let id: String
    let title: String
    let shows: [TVShow]
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var rows: [ShowRow] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = TMDBClient.shared

    private let featuredGenres: [(id: Int, name: String)] = [
        (18, "Drama"),
        (35, "Komedie"),
        (10765, "Sci-Fi a fantasy"),
        (80, "Krimi")
    ]

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            async let trending = client.trending()
            async let topRated = client.topRated()
            async let popular = client.popular()

            var newRows: [ShowRow] = [
                ShowRow(id: "trending", title: "Populární tento týden", shows: try await trending),
                ShowRow(id: "top_rated", title: "Nejlépe hodnocené", shows: try await topRated),
                ShowRow(id: "popular", title: "Oblíbené u diváků", shows: try await popular)
            ]

            for genre in featuredGenres {
                let shows = try await client.byGenre(genre.id)
                newRows.append(ShowRow(id: "genre_\(genre.id)", title: genre.name, shows: shows))
            }

            rows = newRows
        } catch {
            errorMessage = "Nepodařilo se načíst tipy. Zkontroluj připojení k internetu."
        }
        isLoading = false
    }
}
