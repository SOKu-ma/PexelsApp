import ComposableArchitecture
import SwiftUI

struct PhotosView: View {
    let store: StoreOf<PhotosFeature>

    var body: some View {
        NavigationStack {
            listContent
                .overlay { progressView }
                .navigationTitle(Text("Photos"))
                .padding(.top, 8)
                .padding(.bottom, 8)
                .task {
                    store.send(.onAppear)
                }
                .navigationDestination(for: URL.self) { url in
                    FullScreenImageView(
                        store: Store(
                            initialState: FullScreenImageFeature.State(url: url))
                        {
                            FullScreenImageFeature()
                        }
                    )
                }
                .searchable(
                    text: Binding(
                        get: { store.searchText },
                        set: { store.send(.searchPhotos($0)) }
                    ),
                    prompt: "Search photos"
                )
        }
    }

    @ViewBuilder
    private var listContent: some View {
        ScrollView {
            // TODO リスト表示とグリッド表示を切り替えられるようにする
//            LazyVStack {
//                ForEach(store.photos) { photo in
//                    PhotoRowView(photo: photo)
//                        .background(Color.white)
//                        .cornerRadius(8)
//                }
//            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 2), spacing: 4) {
                ForEach(store.photos) { photo in
                    NavigationLink(value: photo.urls.original) {
                        GridRow {
                            PhotoRowView(photo: photo)
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var progressView: some View {
        if store.isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
