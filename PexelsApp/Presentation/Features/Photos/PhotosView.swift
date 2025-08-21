import ComposableArchitecture
import SwiftUI

struct PhotosView: View {
    let store: StoreOf<PhotosFeature>

    var body: some View {
        NavigationStack {
            listContent
                .overlay { progressView }
                .navigationTitle(Text("Photos"))
                .onAppear {
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
            // TODO: リスト表示とグリッド表示を切り替えられるようにする予定
            LazyVStack(spacing: 0) {
                ForEach(Array(store.displayRows.enumerated()), id: \.element.id) { index, photo in
                    NavigationLink(value: photo.urls.original) {
                        PhotoRowView(photo: photo)
                            .background(Color(.systemBackground))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onAppear {
                        if index >= store.displayRows.count - 3 {
                            store.send(.loadMorePhotos)
                        }
                    }
                }
            }
//            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 2), spacing: 4) {
//                ForEach(Array(store.displayRows.enumerated()), id: \.element.id) { index, photo in
//                    NavigationLink(value: photo.urls.original) {
//                        GridRow {
//                            PhotoRowView(photo: photo)
//                                .background(Color.white)
//                                .cornerRadius(8)
//                        }
//                    }
//                    .onAppear {
//                        if index >= store.displayRows.count - 3 {
//                            store.send(.loadMorePhotos)
//                        }
//                    }
//                }
//            }
        }
    }

    @ViewBuilder
    private var progressView: some View {
        if store.isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
