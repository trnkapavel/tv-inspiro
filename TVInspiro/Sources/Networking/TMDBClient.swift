import Foundation

enum TMDBError: Error {
    case invalidURL
    case requestFailed
}

final class TMDBClient {
    static let shared = TMDBClient()

    private let baseURL = "https://api.themoviedb.org/3"
    private let language = "cs-CZ"
    private let session = URLSession.shared

    private func get<T: Decodable>(_ type: T.Type, path: String, extraParams: [String: String] = [:], language overrideLanguage: String? = nil) async throws -> T {
        var components = URLComponents(string: baseURL + path)
        var items = [
            URLQueryItem(name: "api_key", value: Secrets.tmdbAPIKey),
            URLQueryItem(name: "language", value: overrideLanguage ?? language)
        ]
        items += extraParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        components?.queryItems = items

        guard let url = components?.url else { throw TMDBError.invalidURL }

        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw TMDBError.requestFailed
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    func trending() async throws -> [TVShow] {
        try await get(TVShowPage.self, path: "/trending/tv/week").results
    }

    func topRated() async throws -> [TVShow] {
        try await get(TVShowPage.self, path: "/tv/top_rated").results
    }

    func popular() async throws -> [TVShow] {
        try await get(TVShowPage.self, path: "/tv/popular").results
    }

    func byGenre(_ genreId: Int) async throws -> [TVShow] {
        try await get(TVShowPage.self, path: "/discover/tv", extraParams: [
            "with_genres": String(genreId),
            "sort_by": "popularity.desc"
        ]).results
    }

    func recommendations(forShow id: Int) async throws -> [TVShow] {
        try await get(TVShowPage.self, path: "/tv/\(id)/recommendations").results
    }

    func genres() async throws -> [Genre] {
        try await get(GenreList.self, path: "/genre/tv/list").genres
    }

    func videos(forShow id: Int) async throws -> [VideoResult] {
        let czechVideos = try await get(VideoResponse.self, path: "/tv/\(id)/videos").results
        if !czechVideos.isEmpty { return czechVideos }
        // Trailery na TMDB skoro vždy existují jen v angličtině, čeština bývá prázdná.
        return try await get(VideoResponse.self, path: "/tv/\(id)/videos", language: "en-US").results
    }

    func trailerKey(forShow id: Int) async throws -> String? {
        let videos = try await videos(forShow: id)
        let trailer = videos.first { $0.site == "YouTube" && $0.type == "Trailer" }
            ?? videos.first { $0.site == "YouTube" }
        return trailer?.key
    }
}
