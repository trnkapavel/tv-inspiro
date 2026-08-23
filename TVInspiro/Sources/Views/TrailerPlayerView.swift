import SwiftUI
import AVKit
import YouTubeKit

struct TrailerPlayerView: View {
    let youtubeID: String
    @State private var player: AVPlayer?
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if let player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .onAppear { player.play() }
            } else if let errorMessage {
                VStack(spacing: 16) {
                    Text(errorMessage)
                    Button("Zavřít") { dismiss() }
                }
            } else {
                ProgressView("Načítám trailer…")
            }
        }
        .task {
            await resolveStream()
        }
    }

    private func resolveStream() async {
        do {
            let streams = try await YouTube(videoID: youtubeID).streams
            guard let stream = streams
                .filterVideoAndAudio()
                .filter({ $0.isNativelyPlayable })
                .highestResolutionStream()
            else {
                errorMessage = "Trailer se nepodařilo přehrát."
                return
            }
            player = AVPlayer(url: stream.url)
        } catch {
            errorMessage = "Trailer se nepodařilo přehrát."
        }
    }
}
