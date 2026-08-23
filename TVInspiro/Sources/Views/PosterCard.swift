import SwiftUI

struct PosterCard: View {
    let show: TVShow

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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

            Text(show.name)
                .font(.callout)
                .lineLimit(1)
                .frame(width: 260, alignment: .leading)
        }
    }
}
