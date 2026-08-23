import SwiftUI

struct ShowRowView: View {
    let row: ShowRow

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(row.title)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal, 60)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 32) {
                    ForEach(row.shows) { show in
                        NavigationLink {
                            DetailView(show: show)
                        } label: {
                            PosterCard(show: show)
                        }
                        .buttonStyle(.card)
                    }
                }
                .padding(.horizontal, 60)
            }
        }
    }
}
