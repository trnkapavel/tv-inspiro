import SwiftUI

struct PosterCard: View {
    let show: TVShow

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: show.posterURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        Rectangle().fill(Color.gray.opacity(0.3))
                    }
                }
                .frame(width: 260, height: 390)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                RatingBadge(rating: show.voteAverage)
                    .padding(8)
            }

            Text(show.name)
                .font(.callout)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(width: 260, height: 84, alignment: .topLeading)
                .padding(.top, 4)
        }
    }
}

private struct RatingBadge: View {
    let rating: Double

    var body: some View {
        Label(String(format: "%.1f", rating), systemImage: "star.fill")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.yellow)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.black.opacity(0.6), in: Capsule())
    }
}
