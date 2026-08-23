import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 48) {
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.title3)
                            .padding(.horizontal, 60)
                            .padding(.top, 60)
                    }
                    ForEach(viewModel.rows) { row in
                        ShowRowView(row: row)
                    }
                }
                .padding(.top, 40)
            }
            .overlay {
                if viewModel.isLoading && viewModel.rows.isEmpty {
                    ProgressView("Načítám tipy…")
                }
            }
            .task {
                await viewModel.load()
            }
        }
    }
}
