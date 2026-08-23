import Foundation

@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var shows: [TVShow] = []

    private let key = "favorite_shows"
    private let defaults = UserDefaults.standard

    init() {
        load()
    }

    func isFavorite(_ show: TVShow) -> Bool {
        shows.contains { $0.id == show.id }
    }

    func toggle(_ show: TVShow) {
        if isFavorite(show) {
            shows.removeAll { $0.id == show.id }
        } else {
            shows.append(show)
        }
        save()
    }

    private func load() {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([TVShow].self, from: data) else { return }
        shows = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(shows) else { return }
        defaults.set(data, forKey: key)
    }
}
