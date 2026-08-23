# TV Inspiro

Aplikace pro Apple TV s tipy na kvalitní seriály (data z [TMDB](https://www.themoviedb.org)), s českými popisky, řádkovým UI podobným Netflixu, trailery a seznamem oblíbených.

## Požadavky

- Xcode 16+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- TMDB API klíč (v3 auth) — zdarma na [themoviedb.org](https://www.themoviedb.org/settings/api)

## Nastavení

```bash
cd TVInspiro
cp Sources/App/Secrets.swift.example Sources/App/Secrets.swift
# vlož svůj TMDB API klíč do Secrets.swift
xcodegen generate
open TVInspiro.xcodeproj
```

Spusť schéma `TVInspiro` na Apple TV simulátoru nebo zařízení.

## Architektura

- `Networking/TMDBClient.swift` — TMDB API klient (async/await, čeština `cs-CZ`)
- `ViewModels/HomeViewModel.swift` — načítání řad seriálů (trending, top, žánry)
- `Persistence/FavoritesStore.swift` — lokální seznam oblíbených (`UserDefaults`)
- `Views/` — Netflix-styl UI (řady, detail, přehrávač trailerů)

Trailery se přehrávají přímo v appce přes [YouTubeKit](https://github.com/alexeichhorn/YouTubeKit), protože tvOS nemá webový prohlížeč pro embed YouTube přehrávače. Určeno pro osobní/vývojářské použití (ne pro distribuci přes App Store — extrakce YouTube streamů není oficiálně podporovaný postup).
