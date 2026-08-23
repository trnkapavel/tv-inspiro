import Foundation

struct TVShow: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let genreIds: [Int]?

    enum CodingKeys: String, CodingKey {
        case id, name, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case genreIds = "genre_ids"
    }

    var posterURL: URL? {
        posterPath.flatMap { URL(string: "https://image.tmdb.org/t/p/w500\($0)") }
    }

    var backdropURL: URL? {
        backdropPath.flatMap { URL(string: "https://image.tmdb.org/t/p/w1280\($0)") }
    }
}

struct TVShowPage: Codable {
    let results: [TVShow]
}

struct Genre: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
}

struct GenreList: Codable {
    let genres: [Genre]
}

struct VideoResult: Codable, Identifiable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
}

struct VideoResponse: Codable {
    let results: [VideoResult]
}
