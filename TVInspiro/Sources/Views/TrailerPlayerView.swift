import SwiftUI
import AVKit
import AVFoundation
import Combine
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
                        .frame(maxWidth: 1200)
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
            let combined = streams.filterVideoAndAudio()

            let item: AVPlayerItem
            if let progressive = combined.filter({ $0.isNativelyPlayable }).highestResolutionStream()
                ?? combined.highestResolutionStream() {
                item = AVPlayerItem(url: progressive.url)
            } else if let composed = try await composeVideoAndAudio(from: streams) {
                item = composed
            } else {
                errorMessage = "Nenalezen přehratelný stream (\(streams.count) streamů celkem)."
                return
            }

            let newPlayer = AVPlayer(playerItem: item)
            player = newPlayer

            for await status in item.publisher(for: \.status).values {
                if status == .failed {
                    errorMessage = "Přehrávač selhal: \(item.error?.localizedDescription ?? "neznámá chyba")"
                    player = nil
                    return
                } else if status == .readyToPlay {
                    return
                }
            }
        } catch {
            errorMessage = "Chyba extrakce: \(error)"
        }
    }

    /// YouTube dnes u řady videí nenabízí kombinovaný video+audio stream —
    /// spojíme tedy nejlepší video-only a audio-only stream do jedné kompozice.
    private func composeVideoAndAudio(from streams: [YouTubeKit.Stream]) async throws -> AVPlayerItem? {
        guard let videoStream = streams.filterVideoOnly().filter({ $0.isNativelyPlayable }).highestResolutionStream()
            ?? streams.filterVideoOnly().highestResolutionStream(),
              let audioStream = streams.filterAudioOnly().filter({ $0.isNativelyPlayable }).highestAudioBitrateStream()
            ?? streams.filterAudioOnly().highestAudioBitrateStream()
        else {
            return nil
        }

        let videoAsset = AVURLAsset(url: videoStream.url)
        let audioAsset = AVURLAsset(url: audioStream.url)

        let composition = AVMutableComposition()
        guard let videoTrack = try await videoAsset.loadTracks(withMediaType: .video).first,
              let audioTrack = try await audioAsset.loadTracks(withMediaType: .audio).first else {
            return nil
        }

        let duration = try await videoAsset.load(.duration)
        let range = CMTimeRange(start: .zero, duration: duration)

        let compVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        try compVideoTrack?.insertTimeRange(range, of: videoTrack, at: .zero)

        let compAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        try compAudioTrack?.insertTimeRange(range, of: audioTrack, at: .zero)

        return AVPlayerItem(asset: composition)
    }
}
